(*
  An example of periodically polling an ADC.
  Uses a watchdog timer to wake up every second,
  collects 8 samples from the internal temperature sensor, 
  sends the average over USART, then goes to sleep
*)

staload "SATS/io.sats"

%{^
#include <avr/wdt.h>
%}

staload "SATS/io.sats"
staload "SATS/sleep.sats"
staload "SATS/delay.sats"
staload "SATS/stdio.sats"

staload USART = "SATS/usart.sats"

val baudrate = 9600

extern
fun wdt_enable (mode: int) : void = "mac#wdt_enable"

extern
fun set_sleep_mode (mode : int) : void = "mac#set_sleep_mode"

val WDTO_1S = $extval(int, "WDTO_1S")
val SLEEP_MODE_PWR_DOWN = $extval(int, "SLEEP_MODE_PWR_DOWN")

//Turn off power save 
//Set prescaler to divide system clock by 128
fun init () : void = {
  val () = setbits(ADCSRA, PRADC, ADPS2, ADPS1, ADPS0)
}

fun sample {c:nat | c < 8} (channel: int c) : int = let
  val () = setbits(ADMUX, REFS1, REFS0, channel)
  val () = setbits(ADCSRA, ADEN, ADSC)
  //Wait for sample
  val () = loop_until_bit_is_clear(ADCSRA, ADSC)
 in int_of_regs(ADCH, ADCL) end

(* First sample is trash, always do more than one. *)
fun average_sample {n,c: nat | n > 1 ; c < 8}
  (n: int n, channel: int c) : uint16 = let
  var tot : int = 0
  var i : int
  val () = for (i := n ; i > 0 ; i := i-1) {
    val curr = sample(channel)
    val () = if i = n then
              continue
    val () = tot := tot + curr
  }
  in uint16_of_int( tot / (n - 1) ) end
  
implement main () = loop () where {
  val () = wdt_enable(WDTO_1S)
  val () = set_sleep_mode(SLEEP_MODE_PWR_DOWN)
  val () = setbits(DDRB, DDB3)
  fun loop () : void = let
    val () = $USART.atmega328p_init_stdio(baudrate)
    val () = init()
    val adc = average_sample(8, MUX3)
    // adc = (v_in * 1024) / vref and vref = 1100 
    //so just say adc ~ v_in. 93%
    // Datesheet: 314mv ~ 25 C  and 1 mV ~ 1 C 
    val () = println! (
        "Temperature is ~ ", adc - uint16_of_int(314), " C\n"
    )
    val () = sleep_mode()
  in loop() end
}