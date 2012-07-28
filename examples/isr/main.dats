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
#include <avr/sleep.h>

declare_isr(USART_RXC_vect);
declare_isr(USART_TXC_vect);

typedef cycbuf_t char*

static char rbuffer[25];
static char wbuffer[25];

typedef struct {
  ats_int_type w;
  ats_int_type r;
  ats_int_type size;
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

staload "SATS/interrupt.sats"

(* ****** ****** *)


(* An address int the .data section, cannot free it. *)
absview global(l:addr)

abst@ype cycbuf (a:t@ype, n: int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = int w,
      r = int r,
      size = int s,
      base = @[a][s]
  }

extern
fun {a:t@ype} get_read_buffer 
  () : [n,w,r:nat] [s:pos] [l:agz] (
  global(l), cycbuf(a,n,s,w,r) @ l | ptr l
) = "mac#get_read_buffer"
        
extern
fun {a:t@ype} get_write_buffer
  () : [n,w,r:nat] [s:pos] [l:agz] (
  global(l), cycbuf(a,n,s,w,r) @ l | ptr l
) = "mac#get_write_buffer"

extern
praxi {a:t@ype} return_global {n,s,w,r:nat} {l:agz} (
  pfg: global(l), pf: cycbuf(a,n,s,w,r) @ l | p: ptr l
) : void

extern
fun {a:t@ype} cycbuf_insert () : void

extern
fun {a:t@ype} cycbuf_remove () : void

extern
fun {a:t@ype} cycbuf_is_empty () : bool

extern
fun {a:t@ype} cycbuf_is_full () : bool

implement main () = ()