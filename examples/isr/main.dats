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

volatile char *rp = rbuffer;
volatile char *wp = wbuffer;
%}

staload "SATS/interrupt.sats"

(* ****** ****** *)

implement main () = ()
