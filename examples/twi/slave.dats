(*
  An example of an interrupt driven
  i2c slave device.
  
  Adapted from Atmel Application Note AVR311.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload TWI = "SATS/twi.sats"
staload USART = "SATS/usart.sats"

%{^
static unsigned char statmp0[5] = {'a','b','c','d','e'};
%}

local
  var information : @[uchar][5] with pfinfo = 
    $extval(@[uchar][5], "statmp0")
    
  viewdef info = @[uchar][5] @ information
in
  val information = &information
  prval ginfo = global_new {info} (pfinfo)
end

fun response {n:nat | n <= $TWI.buff_size} (
  src: &(@[uchar][$TWI.buff_size]), sz: uint8 n, m: $TWI.mode
) : void = {
  prval (pf) = global_get(ginfo)
  val curr = (int1) src.[0]
  val () =
    if curr >= 0 && curr < 5 then
      src.[0] := !information.[curr]
    else
      src.[0] := (uchar) '0'
  prval () = global_return(ginfo, pf)
}

(* ****** ****** *)

implement main (pf0 | (**)) = let
  val address = 0x2
  val (status | ()) =
    $TWI.slave_init(pf0 | address, true)
  val () = 
    $USART.atmega328p_init_stdio(9600)
  val (set | ()) = sei(pf0 | (**))
  val () =
    $TWI.start_server(set, status | response, 2)
  val () = while (true) {
    val () = sleep_enable()
    val () = sleep_cpu()
    val () = sleep_disable()
  }
  val (clear | ()) = cli(set | (**))
in pf0 := clear end
