(*
    An example of replacing stdio routines with an
    interrupt based solution for tx and rx.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"

(* ****** ****** *)

extern
castfn _8(c:char) : [n:nat | n < 256] int n

implement main (locked | (* *) ) = {
  val () = atmega328p_async_init(locked | uint16_of_int(9600))
  val (enabled | () ) = sei(locked | (* *) )
  val () = setbits(DDRB, DDB3)
  fun loop (pf: INT_SET | (* *)) : (INT_CLEAR | void) = let
      val c = char_of_int(getchar())
      val () = flipbits(PORTB, PORTB3)
//      val () = loop_until_bit_is_set(UCSR0A, UDRE0)
//      val () = setval(UDR0, _8(c))
      in
	loop(pf | (* *))
      end
  val (pf0 | () ) = loop(enabled | (* *))
  prval () = locked := pf0
}