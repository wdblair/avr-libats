(*
  An example of an interrupt driven
  i2c master device.
  
  Constantly sends a byte, then requests a byte.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload TWI = "SATS/twi.sats"

stadef TWI_READY = $TWI.TWI_READY

staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

implement main (pf0 | (* *) ) = {
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = setbits(DDRB, DDB3)
  val (status | ()) = $TWI.master_init(pf0 |  400)
  var tbuff : $TWI.transaction_t with tpf
  val trans = $TWI.transaction_init(tpf | &tbuff)
  val () = $TWI.add_msg(trans, 2)
  val () = $TWI.add_msg(trans, 2)
  val (set | ()) = sei(pf0 | (**))
//Our main buffer.
  var !buf = @[uchar][4](_c(0))
  val () = println! 's'
  val () = $TWI.setup_addr_byte(!buf, 0, 0x2, false)
  val () = $TWI.setup_addr_byte(!buf, 2, 0x2, true)
    val c  = char_of_int(getchar())
    val () = !buf.[1] := uchar_of_char(c)
    //Send the transaction
    val (busy | ()) =
      $TWI.start_transaction(set, status | !buf, trans, 4, 2)
    //Sleep until ready
    val (rdy | ()) = $TWI.wait(set, busy | (* *))
    val _ = $TWI.get_data(set, rdy | !buf, 4)
    val c = char_of_uchar(!buf.[3])
    val () = println! ("resp: ", c)
    prval () = status := rdy
  val () = while(true) {
    val () = ()
  }
  prval () = $TWI.disable(status)
  prval () = tpf := $TWI.free_transaction(trans)
  val (locked | () ) = cli(set | (* *))
  prval () = pf0 := locked
}