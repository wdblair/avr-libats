staload "SATS/io.sats"
staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"

implement main () = let
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = setbits(DDRB, DDB3)
  val () = setbits(PORTB, PORTB3)
  fun loop () : void = let
    val _ = puts("Hey1")
    val () = delay_ms(250.0)
    val () = flipbits(PORTB, PORTB3)
  in loop() end
in loop() end

