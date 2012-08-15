(*
    An example of using the asynchronous UART routines.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"

(* ****** ****** *)

implement main (locked | (* *) ) = {
  val () = atmega328p_async_init(locked | uint16_of_int(9600))
  val (enabled | () ) = sei(locked | (* *) )
  fun loop (pf: INT_SET | (* *)) : (INT_CLEAR | void) = let
      val c = char_of_int(getchar())
      val () = 
        case+ c of 
          | 't' => println! "Temperature"
          | 's' => println! "Speed"
          | 'd' => println! "Depth"
          | 'i' => println! 
            "hipsteripsumantebellumtightjeans8bitfrapacinooldcamera"
          | _ => println! "Error"
      in
	loop(pf | (* *))
      end
  val (pf0 | () ) = loop(enabled | (* *))
  prval () = locked := pf0
}