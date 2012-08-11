%{^
#include <ctype.h>
#include <stdint.h>
%}

staload "SATS/io.sats"
staload "SATS/delay.sats"
staload "SATS/stdio.sats"

(* we usually need to truncate a 16-bit int for an 8-bit register *)
extern
castfn _16_to_8 (x:uint16) : [n:nat | n < 256] int n

extern
castfn int2eight (x:int) : [n:nat | n < 256] int n

extern
castfn reg2char (x:reg(8)) : char

extern
castfn char_to_8 (x:char) : [n:nat | n < 256] int n

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

extern
fun usart_read_char (f: FILEref) : int = "usart_read_char"

extern 
fun usart_send_char (c: char, f: FILEref) : int = "usart_send_char"

implement usart_read_char (f) = int_of_char(c) where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = reg2char(UDR0)
}
  
implement usart_send_char (c: char, f: FILEref) : int = 0 where {
    val () = loop_until_bit_is_set(UCSR0A, UDRE0)
    val () = setval(UDR0, char_to_8(c))
}

extern
castfn uint16_of_int (i:int) : uint16

extern
fun redirect_stdio () : void = "redirect_stdio"

%{
FILE mystdio =
  FDEV_SETUP_STREAM((int(*)(char, FILE*))usart_send_char,
                    (int(*)(FILE*))usart_read_char,
                    _FDEV_SETUP_RW
                    );
ats_void_type
redirect_stdio () {
  stdout = &mystdio;
  stdin = &mystdio;
}
%}

(* Echo all characters received. *)
implement main () = let
  val () = setbits(DDRB, DDB3)
  val () = usart_init(uint16_of_int(104))
  val () = redirect_stdio()
  val () = println! "Hello World!"
  fun loop () : void = let
    val c = usart_read_char(stdout_ref)
    val _ = usart_send_char(char_of_int(c), stdout_ref)
    val () = flipbits(PORTB, PORTB3)
  in loop() end
in loop() end
