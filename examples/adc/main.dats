(*
  An example of periodically polling an ADC.
  Uses a watchdog timer to wake up every second,
  collects 8 samples, sends the average over USART,
  then goes back to sleep.
*)

staload "SATS/io.sats"

%{^
#include <avr/wdt.h>
%}

staload "SATS/io.sats"
staload "SATS/sleep.sats"
staload USART = "SATS/usart.sats"

val baudrate = uint16_of_int(19200)

extern
fun wdt_enable (mode: int) : void = "mac#wdt_enable"

extern
fun set_sleep_mode (mode : int) : void = "mac#set_sleep_mode"

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
  var tot : int = 0
  var i : int
  val () = for (i := n ; i > 0 ; i := i+1) {
    val curr = sample(channel)
    val () = if i = n then
              continue
    val () = tot := tot + curr
  }
  in uint16_of_int( tot / (n - 1) ) end
  
implement main () = loop () where {
  val () = $USART.atmega328p_init(baudrate)
  val () = wdt_enable(WDTO_1S)
  val () = set_sleep_mode(SLEEP_MODE_PWR_DOWN)
  fun loop () : void = let
    val () = init()
    val temp = average_sample(8, MUX1)
    val () = println! temp
    val () = sleep_mode()
  in loop() end
}
