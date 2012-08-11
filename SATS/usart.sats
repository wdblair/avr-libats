(*
  Note, this will only work on atmega328p, when specific template
  implementation comes to ats, we can define init, tx, and rx 
  using the arch sort to clean stuff up.
*)

#define ATS_STALOADFLAG 0

%{#
#include "CATS/usart.cats"
%}

staload "SATS/io.sats"
staload "SATS/interrupt.sats"

datasort arch = 
  | atmega328p

(* baud rate, bits per second *)
fun atmega328p_init (baud: uint16) : void

fun ubrr_of_baud (baud: uint16) : uint16 = "mac#avr_libats_ubrr_of_baud"

(* ****** ****** *)

fun atmega328p_async_init(pf: !INT_CLEAR | baud: uint16) : void

fun atmega328p_async_flush (pf: !INT_SET | (* *)) : void