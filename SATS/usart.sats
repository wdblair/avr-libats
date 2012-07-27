(*
Note, this will only work on atmega328p, when specific template
implementation comes to ats, we can define init, tx, and rx 
using the arch sort to clean stuff up.
*)

staload "SATS/io.sats"

datasort arch = 
  | atmega328p

(* baud rate, bits per second *)
fun atmega328p_init (baud: uint16) : void

fun atmega328p_tx (s: char) : void

fun atmega328p_rx () : char