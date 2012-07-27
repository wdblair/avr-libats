(*
  An example of periodically polling an ADC.
  Uses a watchdog timer to wake up every second,
  collects 8 samples, sends the result over USART,
  then goes back to sleep.
  
  Most chips have multiple ADC channels,
  this is just an example from one
  application.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include <ats/basics.h>
#include <avr/wdt.h>
#include <avr/sleep.h>
%}

staload "SATS/io.sats"
staload USART = "SATS/usart.sats"

val baudrate = uint16_of_int(19200)

extern
fun wdt_enable (mode: int) : void = "mac#wdt_enable"

extern
fun set_sleep_mode (mode : int) : void = "mac#wdt_enable"

extern
fun sleep_mode () : void = "mac#sleep_mode"

val ADMUX = $extval(reg(8),"ADMUX")
val ADCSRA = $extval(reg(8),"ADCSRA")
val ADCH = $extval(reg(8),"ADCH")
val ADCL = $extval(reg(8),"ADCL")
val ADMUX = $extval(reg(8),"ADMUX")

val ADPS2 = $extval(natLt(8), "ADPS2")
val ADPS1 = $extval(natLt(8), "ADPS1")
val ADPS0 = $extval(natLt(8), "ADPS0")
val ADEN = $extval(natLt(8), "ADEN")
val ADSC = $extval(natLt(8), "ADSC")
val MUX1 = $extval(natLt(8), "MUX1")

val WDTO_1S = $extval(int, "WDTO_1S")
val SLEEP_MODE_PWR_DOWN = $extval(int, "SLEEP_MODE_PWR_DOWN")

//Turn on the ADC
fun init () : void = {
  val () = setbits(ADCSRA, ADPS2, ADPS1, ADPS0)
}

fun sample {c:nat | c < 8}(channel: int c) : int = let
  val () = setbits(ADMUX, channel)
  val () = setbits(ADCSRA, ADEN, ADSC)
  val () = loop_until_bit_is_clear(ADCSRA, ADSC)
 in int_of_regs(ADCH, ADCL) end
 
(* First sample is trash, always do more than one. *)
fun average_sample {n,c: nat | n > 1 ; c < 8}
  (n: int n, channel: int c) : uint16 = let
  fun loop {i: nat} (i: int i, tot: int) : int =
    if i = 0 then
      tot / (n - 1)
    else let
      val curr = sample(channel)
      val tot' = if i < n then tot+curr else 0
    in loop(i-1, tot') end
  in uint16_of_int( loop(n, 0) ) end  
      
implement main () = loop () where {
  val () = $USART.atmega328p_init(baudrate)
  val () = wdt_enable(WDTO_1S)
  val () = set_sleep_mode(SLEEP_MODE_PWR_DOWN)
  fun loop() = let
    val () = init()
    val temp = average_sample(8, MUX1)
    val () = println! temp
    val () = sleep_mode()
  in loop() end
}
