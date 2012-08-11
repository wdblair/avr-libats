staload "SATS/io.sats"
staload "SATS/delay.sats"

fun init () : void = {
  val () = clear_and_setbits(DDRD, DDB3)
  val () = setbits(PORTD, PORTD3)
}

fun toggle_led () : void = {
  val () = flipbits(PORTD, PORTD3)
}

fun loop () : void = let
    val () = toggle_led()
    val () = delay_ms(1000.0)
  in loop() end
   
implement main () =
 let
  val () = init()
  val () = loop()
 in end
