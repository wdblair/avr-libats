//This should be automatic
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include<ats/basics.h>
%}

staload "SATS/io.sats"
staload "SATS/delay.sats"

val TCCR2A = $extval(reg(8),"TCCR2A")
val TCCR2B = $extval(reg(8),"TCCR2B")
val DDRB = $extval(reg(8),"DDRB")
val OCR2A = $extval(reg(8),"OCR2A")

val WGM20  = $extval(natLt(8), "WGM20")
val WGM21  = $extval(natLt(8), "WGM21")
val COM2A1 = $extval(natLt(8), "COM2A1")
val CS20 = $extval(natLt(8), "CS20")
val PB3 = $extval(natLt(8), "PB3")

fun init_pwm () : void = {
  val () = setbits(TCCR2A, WGM20, WGM21, COM2A1)
  val () = setbits(TCCR2B, CS20)
  val () = setbits(DDRB, PB3)
}

fun set_pwm_output(duty: natLt(256)) : void = {
  val () = setval(OCR2A,duty)
}

extern
fun delay (t: double) : void = "mac#_delay_ms"

(* Glow the LED on and off indefinitely. *)
implement main () = loop(0,1) where {
  fun loop {d: int | d == 1 || d == ~1} 
    (brightness: natLt(256), delta: int d) : void = let
    val () = set_pwm_output(brightness)
    val () = delay(10.0)
  in 
    if (brightness = 255 && delta = 1) ||
       (brightness = 0 && delta = ~1) then
      loop(brightness + ~delta,~delta)
    else
      loop(brightness+delta, delta)
  end
}
