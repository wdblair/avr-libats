staload "SATS/io.sats"
staload "SATS/delay.sats"

fun init_pwm () : void = {
  val () = setbits(TCCR2A, WGM20, WGM21, COM2A1)
  val () = setbits(TCCR2B, CS20)
  val () = setbits(DDRB, PINB3)
}

fun set_pwm_output(duty: natLt(256)) : void = {
  val () = setval(OCR2A,duty)
}

(* Glow the LED on and off indefinitely. *)
implement main () = loop(0,1) where {
  fun loop {d: int | d == 1 || d == ~1} 
    (brightness: natLt(256), delta: int d) : void = let
    val () = set_pwm_output(brightness)
    val () = delay_ms(10.0)
  in 
    if (brightness = 255 && delta = 1) ||
       (brightness = 0 && delta = ~1) then
      loop(brightness + ~delta,~delta)
    else
      loop(brightness+delta, delta)
  end
}
