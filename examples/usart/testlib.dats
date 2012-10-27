staload "SATS/io.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"

staload USART = "SATS/usart.sats"

implement main () = let
  val () = $USART.atmega328p_init(9600)
  fun loop () : void = let
    val c = getchar()
    val _ = putchar(char_of_int(c))
    val () = println! "Hello World!"
  in loop() end
in loop() end