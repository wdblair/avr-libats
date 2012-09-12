(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from Atmel Application Note AVR311.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"
staload USART = "SATS/usart.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

implement main (pf0 | (* *) ) = let
  val address = 0x2
  val () = setbits(DDRB, DDB3)
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = twi_slave_init(pf0 | address, true)
  val (pf1 | () ) = sei(pf0 | (* *) )
  val () = twi_start(pf1 | (* *) )
  var !buf with pfbuf =  @[uchar][4](_c(0))
  fun loop (enabled: INT_SET | buf: &(@[uchar][4]) ) : (INT_CLEAR | void) = let
//    val (locked | ()) = cli (enabled | (* *))
  in
    if twi_transceiver_busy () then let
        //val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
      in loop(enabled | buf) end
    else let
      //val (enabled | ()) = sei(locked | (* *))
     in
      if twi_last_trans_ok() then let
            val rx = twi_rx_data_in_buf()
          in
            if rx > 0 then let
                val _ = twi_get_data(enabled | buf, rx)
                val c = char_of_uchar(buf.[0])
                val () =
                  if (char_of_uchar(buf.[0]) = 'h') then
                    setbits(PORTB, PORTB3)
//                val () = !buf.[0] := uchar_of_int(int_of_uchar(!buf.[0]) + 0x1)
                val () = twi_start(enabled | (* *))
//                val () = twi_start_with_data(enabled | !buf, rx)
              in loop(enabled | buf) end
            else let
              val () = twi_start(enabled | (* *))
            in loop(enabled | buf) end
          end
      else let
        in loop(enabled | buf) end
     end
  end
  //loop never completes, but preserve pf0
  val (pf1 | () ) = loop(pf1 | !buf)
in pf0 := pf1 end