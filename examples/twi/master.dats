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
staload "SATS/twi.sats"
staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

extern
castfn uint8_of_int (i:int) : uint8
  
implement main (pf0 | (* *) ) = {
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = setbits(DDRB, DDB3)
  //Set SCL to 400khz
  val (status | ()) = $TWI.master_init(pf0 |  400)
  var tbuff : transaction_t with tpf
  val trans = $TWI.transaction_init(tpf | &tbuff)
  val () = $TWI.add_msg(trans, 2)
  val () = $TWI.add_msg(trans, 2)
  val (set | ()) = sei(pf0 | (* *))
  var !buf = @[uchar][4](_c(0))
  val () = $TWI.start_transaction(set, status | !buf, trans, 4, 2)
  val _  = wait(set, status | (* *))
  val () = while (true) {
    val c  = char_of_int(getchar())
    val () = println! 's'
    val () = $TWI.setup_addr_byte(!buf, 0x2, false)
    val () = !buf.[1] := uchar_of_char(c)
    val () = $TWI.start_with_data(set, status | !buf, 2)
    val () = $TWI.wait(set, status | (* *))
    val () = $TWI.setup_addr_byte(!buf, 0x2, true)
    val () = $TWI.start_with_data(set, status | !buf, 2)
    val () = $TWI.wait(set, status | (* *))
    val _ = $TWI.get_data(set, status | !buf, 2)
    val c = char_of_uchar(!buf.[1])
    val () = println! ("resp: ", c)
  }
  prval () = tpf := $TWI.free_transaction(trans)
  prval () = $TWI.disable(status)
  val (locked | () ) = cli(set | (* *))
  prval () = pf0 := locked
}