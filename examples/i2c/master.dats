(*
  An example of an interrupt driven
  i2c master device.
    
  Adapted from Atmel Application Note AVR315.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

implement main (pf0 | (* *) ) = let
    
  in end