(*
  An example of an interrupt driven
  i2c master device.
  
  Constantly sends a byte, then requests a byte.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

implement main (pf0 | (* *) ) = 

