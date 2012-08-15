staload "SATS/io.sats"
staload "SATS/delay.sats"
staload "SATS/stdio.sats"

%{^
#include "CATS/usart.cats"
%}

extern
castfn reg2char (x:reg(8)) : char

extern
castfn char_to_8 (x:char) : [n:nat | n < 256] int n

extern
fun redirect_stdio () : void = "redirect_stdio"

extern
fun usart_read_char (f: FILEref) : int = "usart_read_char"

extern 
fun usart_send_char (c: char, f: FILEref) : int = "usart_send_char"

extern
castfn char_to_8(x:char) : [n:nat | n < 256] int n 

extern
fun ubrr_of_baud(baud: uint16) : uint16 = "mac#avr_libats_ubrr_of_baud"

extern
castfn _u16(n:int) : uint16

fun usart_init
  (baud: uint16) : void = {
    val ubrr = ubrr_of_baud(baud)
    val () = set_regs_to_int(UBRR0H, UBRR0L, ubrr)
    //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
    val () = setbits(UCSR0C, UCSZ01, UCSZ00)
    //Enable TX and RX
    val () = setbits(UCSR0B, RXEN0, TXEN0)
    val () = redirect_stdio()
  }

implement usart_read_char (f) = int_of_char(c) where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = reg2char(UDR0)
}
  
implement usart_send_char (c: char, f: FILEref) : int = 0 where {
    val () = 
      if c = '\n' then {
        val _ = usart_send_char('\r',stdout_ref)
    }
    val () = loop_until_bit_is_set(UCSR0A, UDRE0)
    val () = setval(UDR0, char_to_8(c))
}

extern
castfn uint16_of_int (i:int) : uint16

(* Echo all characters received. *)
implement main () = let
  val () = usart_init((_u16)9600)
  fun loop () : void = let
    val c = char_of_int(getchar())
    val _ = putchar(c)
  in loop() end
in loop() end

%{
static FILE mystdio =
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
