(*
  An example of an interrupt driven
  i2c slave device.
  
  Adapted from Atmel Application Note AVR311.
*)

#include "HATS/twi.hats"

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload TWI = "SATS/twi.sats"
staload USART = "SATS/usart.sats"

staload UNSAFE = "prelude/SATS/unsafe.sats"
staload _ = "prelude/DATS/unsafe.dats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

var previous_write : bool = false
val prevwrite = &previous_write

fun response {n:nat | n <= buff_size} (
  src: &(@[uchar][buff_size]), sz: int n, m: $TWI.mode
) : bool = let
  val prev = $UNSAFE.ptrget(&previous_write)
in
  //A write preceeded this
  if prev then
    //Good
    if m = $TWI.READ then let
        val () = $UNSAFE.ptrset(prevwrite, false)
        //Prepare the next message
        val () =
          if sz > 0 then {
            val resp =
              case+ char_of_uchar(src.[0]) of
               | '1' => 'a'
               | '2' => 'b'
               | '3' =>  'c'
               | _ => 'e'
            val () = src.[0] := uchar_of_char(resp)
          }
      in true end
    //Write + Write not allowed
    else
      false
  else
    //The first 
    if m = $TWI.WRITE then let
        val () = $UNSAFE.ptrset(prevwrite, true)
      in true end
    else
      false
end

implement main (pf0 | (* *) ) = let
  val address = 0x2
  val () = setbits(DDRB, DDB3)
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val (status | ()) = $TWI.slave_init(pf0 | address, true)
  val (pf1 | ()) = sei(pf0 | (* *))
  val () = $TWI.start_server(pf1, status | response)
  fun loop (pf: INT_SET, pf1: $TWI.TWI_BUSY | (* *)) : (INT_CLEAR | void) = let
      val () = sleep_enable()
      val () = sleep_cpu()
      val () = sleep_disable()
  in loop(pf, pf1 | (* *)) end
  val (pf | () ) = loop(pf1, status | (* *))
in pf0 := pf end