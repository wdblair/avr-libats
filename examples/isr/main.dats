(*
    An example of replacing stdio routines with an
    interrupt based solution for tx and rx.
*)

staload "SATS/interrupt.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

implement main (locked | (* *) ) = {
  val () = atmega328p_async_init(locked | uint16_of_int(9600))
  val (enabled | () ) = sei(locked | (* *) )
  fun loop (pf: INT_SET | (* *)) : (INT_CLEAR | void) = let
      val c = char_of_int(getchar())
      val () =
	case+ c of 
	| _ when c = 't' => println! "Temp"
	| _ when c = 's' => println! "Speed"
	| _ when c = 'd' => println! "Depth"
	| _ => println! "Error"
      in
	loop(pf | (* *))
      end
  val (pf0 | () ) = loop(enabled | (* *))
  prval () = locked := pf0
}
