(* An example of replacing stdio routines with an
   interrupt based equivalent.

   This approach is probably filled with race conditions.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#define declare_isr(vector, ...)                                        \
  void vector (void) __attribute__ ((signal,__INTR_ATTRS)) __VA_ARGS__

#include <ats/basics.h>
#include <avr/sleep.h>

#include <util/atomic.h>

declare_isr(USART_RXC_vect);
declare_isr(USART_TXC_vect);

typedef cycbuf_t char*

static char rbuffer[25];
static char wbuffer[25];

typedef struct {
  uint8_t w;
  uint8_t r;
  uint8_t size;
  ats_ptr_type base;
} cycbuf_t;

volatile char rbuffer[25];
volatile char wbuffer[25];

volatile cycbuf_t read = {0, 0, 25,(char*) rbuffer};
volatile cycbuf_t write = {0, 0, 25,(char*) wbuffer};

ATSinline()
ats_ptr_type get_read_buffer() {
  return &read;
}

ATSinline()
ats_ptr_type get_write_buffer() {
  return &write;
}
%}

staload "SATS/io.sats"
staload "SATS/interrupt.sats"

(* ****** ****** *)

val UDR0 = $extval(reg(8),"UDR0")

(* ****** ****** *)

(* An address int the .data section, cannot free it. *)
absview global(l:addr)

viewtypedef cycbuf (a:t@ype,n:int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = int w,
      r = int r,
      n = int n,
      size = int s,
      base = @[a][s]
    }

extern
fun get_read_buffer 
  () : [s:pos] [n,w,r:nat | n <= s; w < s; r < s] [l:agz] (
  global(l), cycbuf(char,n,s,w,r) @ l | ptr l
) = "mac#get_read_buffer"
        
extern
fun get_write_buffer
  () : [s:pos] [n,w,r:nat | n <= s; w < s; r < s]  [l:agz] (
  global(l), cycbuf(char,n,s,w,r) @ l | ptr l
) = "mac#get_write_buffer"

extern
praxi {a:t@ype} return_global {l:agz} (
  pfg: global(l), pf: a @ l | p: ptr l
) : void

fun {a:t@ype} cycbuf_insert {l:agz} {s:pos} {n:nat | n < s} {w, r: nat | n < s; w < s; r < s} (
    pf: !cycbuf(a, n, s, w, r) @ l >> cycbuf(a, n+1, s, w', r) @ l | p: ptr l, x: a
) : #[w':nat | w' < s] void = let 
    val () = p->n := p->n + 1
    val () = p->base.[p->w] := x
  in
    p->w := (p->w + 1) nmod1 p->size
  end

fun {a:t@ype} cycbuf_remove {l:agz} {s,n:pos} {w,r:nat | n <= s; w < s; r < s} (
    pf: !cycbuf(a, n, s, w, r) @ l >> cycbuf(a, n-1, s, w, r') @ l | p: ptr l, x: &a? >> a
) : #[r':nat | r' < s] void = let
    val () = p->n := p->n - 1
    val () = x := p->base.[p->r]
  in
    p->r := (p->r + 1) nmod1 p->size
  end

fun {a:t@ype} cycbuf_is_empty {l:agz} {s:pos} {n,w,r:nat | n <= s; w < s; r < s} (
    pf: !cycbuf(a,n,s,w,r) @ l | p: ptr l
) : bool(n == 0) = p->n = 0

fun {a:t@ype} cycbuf_is_full {l:agz} {s:pos} {n,w,r:nat | n <= s; w < s; r < s} (
    pf: !cycbuf(a,n,s,w,r) @ l | p: ptr l
) : bool(n >= s) = p->size = p->n

(* ****** ****** *)

extern
castfn char_of_reg(r:reg(8)) : char

extern
castfn uint8_of_char(c:char) : natLt(256)

(* ****** ****** *)

implement 
USART_TXC_vect () = let
  val (gpf, pf | p) = get_write_buffer()
 in 
  if cycbuf_is_empty<char>(pf | p) then {
     prval () = return_global(gpf, pf | p)
  } else {
   var tmp : char
   val () = cycbuf_remove<char>(pf | p , tmp)
   val () = setval(UDR0,uint8_of_char(tmp))
   prval () = return_global(gpf, pf | p)
  }
 end 

implement 
USART_RXC_vect () = let
  val contents = char_of_reg(UDR0)
  val (gpf, pf | p) = get_read_buffer()
  val full = cycbuf_is_full<char>(pf | p)
 in
   if full then {
      prval () = return_global(gpf, pf | p)
   } else {
      	val () = cycbuf_insert<char>(pf | p, contents)
	prval () = return_global(gpf, pf | p)
   }
 end

(* ****** ****** *)

extern
fun atmega328p_async_tx 
    (c:char, f:FILEref) : void = "atmega328p_async_tx"

extern
fun atmega328p_async_rx 
    (f:FILEref) : char = "atmega328p_async_rx"


(* ****** ****** *)

val UCSR0A = $extval(reg(8),"UCSR0A")
val UDRE0 = $extval(natLt(8),"UDRE0")

extern
fun sleep_mode () : void

implement
atmega328p_async_tx (c, f) = {
   val (gpf, pf | p) = get_write_buffer()
   fun loop {l:agz} {s:pos} {n,w,r:nat | n <= s; w < s; r < s}
       (g: global(l), pf: cycbuf(char,n,s,w,r) @ l | p: ptr l) : void =
       if cycbuf_is_full(pf | p) then let
       	  val () = sleep_mode()
	  in loop(g, pf | p) end
       else let
       	  val () = cycbuf_insert<char>(pf | p, c)
       in
	if bit_is_clear(UCSR0A,UDRE0) then {
	   var tmp : char
	   val () = cycbuf_remove<char>(pf | p, tmp)
	   val () = setval(UDR0, uint8_of_char(tmp))
           prval () = return_global(g, pf | p)
	} else {
          prval () = return_global(g, pf | p)
        }
       end
    val () = loop(gpf, pf | p)
  }

(* ****** ****** *)

implement main () = ()
