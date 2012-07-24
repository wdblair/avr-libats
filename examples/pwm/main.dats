//Do this by default
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include<ats.h>
#include<avr/io.h>
#include<util/delay.h>

%}

(* A simple example of Fast-PWM. Could use to glow an LED on and off. *)
abst@ype reg (n:int)

extern
praxi lemma_reg_int8 {n:nat} (r: reg(n) ) : [0 <= n; n < 256] void

val TCCR2A = $extval(reg(8),"TCCR2A")
val TCCR2B = $extval(reg(8),"TCCR2B")
val DDRB = $extval(reg(8),"DDRB")
val OCR2A = $extval(reg(8),"OCR2A")

val WGM20  = $extval(natLt(8), "WGM20")
val WGM21  = $extval(natLt(8), "WGM21")
val COM2A1 = $extval(natLt(8), "COM2A1")
val CS20 = $extval(natLt(8), "CS20")
val PB3 = $extval(natLt(8), "PB3")

symintr setbits

extern
fun setbits1 {n:nat}
  (r: !reg(n) >> reg(n'), b: natLt(8) ) : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits2 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(n), b1: natLt(n)) : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits3 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8))
   : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits4 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8))
   : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits5 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), 
                          b4: natLt(8)
   )
   : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits6 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8),
                          b4: natLt(8), b5: natLt(8)
   )
   : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits7 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8),
                          b4: natLt(8), b5: natLt(8), b6: natLt(8)
   )
   : #[n':nat; 0 <= n'; n' < 256] void

extern
fun setbits8 {n:nat}
  (r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8),
                          b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
   )
   : #[n':nat; 0 <= n'; n' < 256] void

overload setbits with setbits8
overload setbits with setbits7
overload setbits with setbits6
overload setbits with setbits5
overload setbits with setbits4 
overload setbits with setbits3  
overload setbits with setbits2
overload setbits with setbits1

extern
fun clearbits () : void

extern
fun maskbits () : void

(* Set a register to a particular value, data buffers need this. *)
extern
fun setval {n:nat}
  (r: !reg(n) >> reg(n'), n: natLt(256)) : #[n':nat | 0 <= n; n < 256] void

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