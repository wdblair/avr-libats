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
staload "SATS/char.sats"
staload TWI = "SATS/twi.sats"
staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

extern
castfn uint8_of_int(i:int) : uint8
  
implement main (pf0 | (* *) ) = {
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = setbits(DDRB, DDB3)
  //TODO: Generate TWBR from a frequency, maybe offer a couple of options.
  val () = $TWI.master_init(pf0 |  uint8_of_int(0x5C))
  val (set | ()) = sei(pf0 | (* *))
  var !buf = @[uchar][4](_c(0))
  val () = while (true) {
    val c  = char_of_int(getchar())
    val () = println! 's'
    val () = $TWI.setup_addr_byte(!buf, 0x2, false)
    val () = !buf.[1] := uchar_of_char(c)
    val () = $TWI.start_with_data(set | !buf, 2)
    val () = $TWI.setup_addr_byte(!buf, 0x2, true)
    val () = $TWI.start_with_data(set | !buf, 2)
    val _ = $TWI.get_data(set | !buf, 2)
    val c = char_of_uchar(!buf.[1])
    val () = println! ("resp: ", c)
  }
  val (pf | () ) = cli(set | (* *))
  prval () = pf0 := pf
}