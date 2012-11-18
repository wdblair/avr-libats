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
staload "SATS/fifo.sats"

(* baud rate in bits per second *)
fun atmega328p_init {n:nat} (
  baud: uint16 n
) : void

fun atmega328p_init_stdio {n:nat} (
  baud: uint16 n
) : void

(*  Polling Based *)


fun atmega328p_rx_stdio
  (f: FILEref) : int = "atmega328p_rx_stdio"

fun atmega328p_tx_stdio
  (c: char, f: FILEref) : int = "atmega328p_tx_stdio"
  
fun atmega328p_rx () : int

fun atmega328p_tx (c: char) : int

(* ****** ****** *)

fun ubrr_of_baud {n:nat} (
  baud: uint16 n
) : [p:nat] uint16 p = "mac#avr_libats_ubrr_of_baud"

typedef usart_callback =
  {n,p:pos | n <= p} (
    !INT_CLEAR | &fifo(char, n, p) >> fifo(char, n', p)
  ) -<fun1> #[n':nat | n' <= p] void
  
(* ****** ****** *)

symintr atmega328p_async_init

fun atmega328p_async_init_stdio {n:nat} (
  pf: !INT_CLEAR | baud: uint16 n
) : void

overload atmega328p_async_init with atmega328p_async_init_stdio

fun atmega328p_async_init_callback {n:nat} (
  pf: !INT_CLEAR | buad: uint16 n,
  callback: usart_callback
) : void

overload atmega328p_async_init with atmega328p_async_init_callback

fun atmega328p_async_tx 
  (pf: !INT_SET | c:char, f: FILEref) : int = "atmega328p_async_tx"

fun atmega328p_async_rx 
  (pf: !INT_SET | f:FILEref) : int = "atmega328p_async_rx"

fun atmega328p_async_flush (pf: !INT_SET | (* *)) : void