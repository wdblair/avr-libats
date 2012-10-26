(*
  An example of an interrupt driven
  i2c slave device.
  
  Adapted from Atmel Application Note AVR311.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload TWI = "SATS/twi.sats"

(* ****** ****** *)

fun response {n:nat | n <= $TWI.buff_size} (
  src: &(@[uchar][$TWI.buff_size]), sz: int n, m: $TWI.mode
) : bool = true where {
  //Increment whatever is stored in the buffer.
  val curr = int_of_uchar(src.[0])
  val () = src.[0] := uchar_of_int(curr + 1)
}

(* ****** ****** *)

implement main (pf0 | (**)) = let
  val address = 0x2
  val (status | ()) =
    $TWI.slave_init(pf0 | address, true)
  val (set | ()) = sei(pf0 | (**))
  val () =
    $TWI.start_server(set, status | response)
  val () = while (true) {
    val () = sleep_enable()
    val () = sleep_cpu()
    val () = sleep_disable()
  }
  val (clear | ()) = cli(set | (**))
in pf0 := clear end