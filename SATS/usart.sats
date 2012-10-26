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

(* baud rate in bits per second *)
fun atmega328p_init {n:nat | uint16(n)} (
  baud: int n
) : void

fun ubrr_of_baud {n:nat | uint16(n)} (
  baud: int n
) : uint16 = "mac#avr_libats_ubrr_of_baud"

(* ****** ****** *)

fun atmega328p_async_init {n:nat | uint16(n)} (
  pf: !INT_CLEAR | baud: int n
) : void

fun atmega328p_async_tx 
  (pf: !INT_SET | c:char, f: FILEref) : int = "atmega328p_async_tx"

fun atmega328p_async_rx 
  (pf: !INT_SET | f:FILEref) : int = "atmega328p_async_rx"

fun atmega328p_async_flush (pf: !INT_SET | (* *)) : void