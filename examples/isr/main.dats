(* An example of replacing stdio routines with an
   interrupt based equivalent.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#define declare_isr(vector, ...)                                        \
  void vector (void) __attribute__ ((signal,__INTR_ATTRS)) __VA_ARGS__

#include <ats/basics.h>

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

static FILE mystdio =
  FDEV_SETUP_STREAM(atmega328p_async_tx,
                    atmega328p_async_rx,
                    _FDEV_SETUP_RW
                    );

ATSinline()
ats_void_type redirect_stdio() {
  stdin = &mystdio;
  stdout = &mystdio;
}

%}

staload "libc/SATS/stdio.sats"

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"

(* ****** ****** *)

(* An address in the .data section, cannot free it. *)
absview global (l:addr)

viewtypedef cycbuf_array (a:t@ype, n:int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = int w,
      r = int r,
      n = int n,
      size = int s,
      base = @[a][s]
    }

viewtypedef cycbuf (a:t@ype, n:int) =
  [s,w,r:nat | n <= s; w < s; r < s] cycbuf_array(a,n,s,w,r)

extern
fun get_read_buffer 
  () : [s:pos; n:nat; l:agz] (
  global(l), cycbuf(char, n) @ l | ptr l
) = "mac#get_read_buffer"
        
extern
fun get_write_buffer
  () : [s:pos; n:nat; l:agz] (
  global(l), cycbuf(char,n) @ l | ptr l
) = "mac#get_write_buffer"

extern
praxi return_global {a:t@ype} {l:agz} (
  pfg: global(l), pf: a @ l
) : void

fun {a:t@ype} cycbuf_insert {l:agz} {s:pos} {n:nat | n < s} 
    {w, r: nat | n < s; w < s; r < s} (
    lpf: !INT_CLEAR,
    pf: !cycbuf_array(a, n, s, w, r) @ l >> cycbuf_array(a, n+1, s, w', r) @ l | 
    p: ptr l, x: a
) : #[w':nat | w' < s] void = let 
    val () = p->n := p->n + 1
    val () = p->base.[p->w] := x
  in
    p->w := (p->w + 1) nmod1 p->size
  end

fun {a:t@ype} cycbuf_remove {l:agz} {s,n:pos}
    {w,r:nat | n <= s; w < s; r < s} (
    lpf: !INT_CLEAR,
    pf: !cycbuf_array(a, n, s, w, r) @ l >> cycbuf_array(a, n-1, s, w, r') @ l | 
    p: ptr l, x: &a? >> a
) : #[r':nat | r' < s] void = let
    val () = p->n := p->n - 1
    val () = x := p->base.[p->r]
  in
    p->r := (p->r + 1) nmod1 p->size
  end

fun {a:t@ype} cycbuf_is_empty {l:addr} {n:nat} (
    pf: !cycbuf(a,n) @ l | p: ptr l
) : bool(n == 0) = p->n = 0

fun {a:t@ype} cycbuf_is_full {l:agz} {s:pos}
      {n,w,r:nat | n <= s; w < s; r < s} (
    pf: !cycbuf_array(a,n,s,w,r) @ l | p: ptr l
) : bool(n >= s) = p->size = p->n

(* ****** ****** *)

extern
castfn char_of_reg(r:reg(8)) : char

extern
castfn uint8_of_char(c:char) : natLt(256)

(* ****** ****** *)

implement 
USART_TXC_vect (locked | (* *) ) = let
  val (gpf, pf | p) = get_write_buffer()
 in 
  if cycbuf_is_empty<char>(pf | p) then {
     prval () = return_global(gpf, pf)
  } else {
   var tmp : char
   val () = cycbuf_remove<char>(locked, pf | p ,tmp)
   val () = setval(UDR0,uint8_of_char(tmp))
   prval () = return_global(gpf, pf)
  }
 end

implement
USART_RXC_vect (locked | (* *)) = let
  val contents = char_of_reg(UDR0)
  val (gpf, pf | p) = get_read_buffer()
  val full = cycbuf_is_full<char>(pf | p)
 in
   if full then {
      prval () = return_global(gpf, pf)
   } else {
      	val () = cycbuf_insert<char>(locked, pf | p, contents)
	prval () = return_global(gpf, pf)
   }
 end

(* ****** ****** *)

extern
fun redirect_stdio () : void = "mac#redirect_stdio"

extern
fun atmega328p_async_init
  (pf: !INT_CLEAR | baud: uint16) : void

extern
fun atmega328p_async_tx 
  (c:char, f:FILEref) : void = "atmega328p_async_tx"

extern
fun atmega328p_async_rx 
  (f:FILEref) : char = "atmega328p_async_rx"


(* ****** ****** *)

val F_CPU = $extval(lint, "F_CPU")

(* ****** ****** *)

extern
castfn uint16_of_long (x: lint) : uint16

extern
castfn uint8_of_uint16 (x: uint16) : [n: nat | n < 256] int n

extern
castfn int216 (x:int) : uint16

extern
castfn int2eight(x:int) : [n:nat | n < 256] int n

implement
atmega328p_async_init (locked | baud ) = {
  val vreg = uint8_of_uint16 (
              (uint16_of_long(F_CPU) / (baud * int216(16))) - int216(1)
             )
  val () = setval(UBRR0L, vreg)
  val high = int2eight(vreg >> 8)
  val () = setval(UBRR0H, high)
  //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
  val () = setbits(UCSR0C, UCSZ01, UCSZ00)
  //Enable TX and RX and interrupts
  val () = setbits(UCSR0B, RXEN0, TXEN0, RXCIE0, TXCIE0)
  //Enable the standard library
  val () = redirect_stdio()
}
  
implement
atmega328p_async_tx (c, f) = {
   val (gpf, pf | p) = get_write_buffer()
   fun loop {l:agz} {n:nat} ( 
      g: global(l), pf: cycbuf(char, n) @ l | p: ptr l, c: char
   ) : void = let
      val (locked | () ) = cli()
   in
      if cycbuf_is_full (pf | p) then let
          val () = sei_and_sleep_cpu(locked | (* *))
        in loop(g, pf | p, c) end
      else let
          val () = cycbuf_insert<char>(locked, pf | p, c)
       in
        if bit_is_clear(UCSR0A,UDRE0) then {
          var tmp : char
	  val () = cycbuf_remove<char>(locked, pf | p, tmp)
          val set = sei(locked | (* *))
	  val () = setval(UDR0, uint8_of_char(tmp))
          prval () = return_global(g, pf)
	} else {
           prval () = return_global(g, pf)
           val () = sei(locked | (* *))
        }
       end
   end
   val () = loop(gpf, pf | p, c)
}

implement
atmega328p_async_rx (f) = let
  val (gpf, pf | p) = get_read_buffer()
  fun loop {l:agz} {n:nat} (
    g: global(l), pf: cycbuf(char,n) @ l | p: ptr l
  ) : char = let
    val (locked | () ) = cli()
  in 
    if cycbuf_is_empty<char>(pf | p) then let
      val () = sei_and_sleep_cpu(locked | (* *) )
     in loop(g, pf | p) end
    else let
      var tmp : char
      val () = cycbuf_remove<char>(locked, pf | p, tmp)
      val () = sei(locked | (* *))
      prval () = return_global(g, pf)
    in tmp end
  end
in loop(gpf, pf | p) end

(* ****** ****** *)

implement main (locked | (* *) ) = let
  val () = atmega328p_async_init(locked | uint16_of_int(9800))
  val () = sei(locked | (* *) )
  fun loop () : void = let
      val c = char_of_int(getchar())
      val () =
	case+ c of 
	| _ when c = 'x' => println! "Temperature Read!"
	| _ when c = 'y' => println! "Accelerometer Read!"
	| _ when c = 'f' => println! "Message Sent!"
	| _ => println! "Error"
      in
	loop()
      end
  in loop() end
