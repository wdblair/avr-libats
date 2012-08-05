staload "SATS/io.sats"
staload "SATS/usart.sats"

%{^
#include <stdio.h>
%}

extern
fun redirect_stdio () : void = "redirect_stdio"

extern
castfn int2eight(x:int) : [n:nat | n < 256] int n

val F_CPU = $extval(lint, "F_CPU")

extern
castfn uint16_of_long (x: lint) : uint16

extern
castfn uint8_of_uint16 (x: uint16) : [n: nat | n < 256] int n

extern
castfn reg2int(x:reg(8)) : int

extern
castfn char_to_8(x:char) : [n:nat | n < 256] int n 

extern
castfn int216 (x:int) : uint16

implement atmega328p_init(baud) = {
  val vreg = uint8_of_uint16 (
              (uint16_of_long(F_CPU) / (baud * int216(16))) - int216(1)
             )
  val () = setval(UBRR0L, vreg)
  val high = int2eight(vreg >> 8)
  val () = setval(UBRR0H, high)
  //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
  val () = setbits(UCSR0C,UCSZ01,UCSZ00)
  //Enable TX and RX
  val () = setbits(UCSR0B,RXEN0,TXEN0)
  //Enable the standard library
  val () = redirect_stdio()
}

fun atmega328p_rx (f: FILEref) : int = c where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = reg2int(UDR0)
}

fun atmega328p_tx (c: char, f: FILEref) : void = {
    val () = loop_until_bit_is_clear(UCSR0A, UDRE0)
    val () = setval(UDR0, char_to_8(c))
}

%{
static FILE mystdio = 
  FDEV_SETUP_STREAM(atmega328p_tx,
                    atmega328p_rx, 
                    _FDEV_SETUP_RW
                    );

ATSinline()
ats_void_type
redirect_stdio () {
  stdout = &mystdio;
  stdin = &mystdio;
 }
%}