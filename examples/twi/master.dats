(*
  An example of an interrupt driven
  i2c master device.
  
  Constantly sends a byte, then requests a byte.
*)

(* ****** ****** *)

#include "HATS/twi.hats"

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload TWI = "SATS/twi.sats"

staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

implement main (pf0 | (* *) ) = {
  val () = $USART.atmega328p_init(9600)
  val () = setbits(DDRB, DDB3)
  val (status | ()) = $TWI.master_init(pf0 | 400)
  var tbuff : $TWI.transaction_t with tpf
  val trans = $TWI.transaction_init(tpf | &tbuff)
  val () = $TWI.add_msg(trans, 2)
  val () = $TWI.add_msg(trans, 2)
  val (set | ()) = sei(pf0 | (**))
//Our main buffer.
  var !buf = @[uchar][4](_c(0))
//A write, followed by a read
  val () = $TWI.setup_addr_byte(!buf, 0, 0x2, false)
  val () = $TWI.setup_addr_byte(!buf, 2, 0x2, true)
//OUr infinite loop
  fun loop {l:addr} {sz: pos | $TWI.transaction(4, sz, sz)} (
    set: INT_SET, rdy: !($TWI.TWI_READY) 
    | buf: &(@[uchar][4]), trans: $TWI.transaction(l, 4, sz, sz)
  ) : ($TWI.transaction_t @ l, INT_CLEAR | void) = let
    val () = println! 's'
    val c  = char_of_int(getchar())
    val () = buf.[1] := uchar_of_char(c)
  //Send the transaction
    val (busy | ()) =
      $TWI.start_transaction(set, rdy | buf, trans)
  //Sleep until ready
    val (status | ()) = $TWI.wait(set, busy | (* *))
    val _ = $TWI.get_data(set, status | buf, 4)
    val c = char_of_uchar(buf.[3])
    val () = println! ("resp: ", c)
    prval () = rdy := status
  in loop(set, rdy | buf, trans) end
  val (stack, clr | ()) = loop(set, status | !buf, trans)
  prval () = $TWI.disable(status)
  prval () = tpf := stack
  prval () = pf0 := clr
}