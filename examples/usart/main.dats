//This should be automatic
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include<ats/basics.h>
%}

staload "SATS/io.sats"
staload "SATS/delay.sats"

(* we usually need to truncate a 16-bit int for an 8-bit register *)
extern
castfn _16_to_8(x:uint16) : [n:nat | n < 256] int n

extern
castfn int2eight(x:int) : [n:nat | n < 256] int n

extern
castfn reg2char(x:reg(8)) : char

extern
castfn char_to_8(x:char) : [n:nat | n < 256] int n 

fun usart_init
  (ubrr: uint16) : void = {
    val () = setval(UBRR0L,_16_to_8(ubrr))
    val high = int2eight(_16_to_8(ubrr) >> 8) //ugly
    val () = setval(UBRR0H, high)
    //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
    val () = setbits(UCSR0C, UCSZ01, UCSZ00)
    //Enable TX and RX
    val () = setbits(UCSR0B, RXEN0, TXEN0)
  }

fun usart_read_char () : char = c where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = reg2char(UDR0)
  }
  
fun usart_send_char (c: char) : void = {
    val () = loop_until_bit_is_clear(UCSR0A, UDRE0)
    val () = setval(UDR0,char_to_8(c))
 }

extern
castfn uint16_of_int(i:int) : uint16

(* Echo all characters received. *)
implement main () = loop() where {
  val () = usart_init(uint16_of_int(51))
  fun loop () : void = let
    val () = delay(50.0)
    val c = usart_read_char()
    val () = usart_send_char(c)
  in loop() end
}