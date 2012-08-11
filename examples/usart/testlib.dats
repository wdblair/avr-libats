staload "SATS/io.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"

staload USART = "SATS/usart.sats"

implement main () = let
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  fun loop () : void = let
    val c = getchar()
    val _ = putchar(char_of_int(c))
  in loop() end
in loop() end