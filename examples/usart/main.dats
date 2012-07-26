//This should be automatic
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include<ats/basics.h>
%}

staload "SATS/io.sats"
staload "SATS/delay.sats"

(* we usually need to truncate a 16-bit int for an 8bit register *)
extern
castfn _16_to_8(x:uint16) : [n:nat | n < 256] int n

extern
castfn int2eight(x:int) : [n:nat | n < 256] int n

extern
castfn reg2char(x:reg(8)) : char

extern
castfn char_to_8(x:char) : [n:nat | n < 256] int n 

//Lower 8 bits of baudrate
val UBRR0L = $extval(reg(8), "UBRR0L")
//Higher 8 bits of baudrate
val UBBR0H = $extval(reg(8), "UBBR0H")
val UCSROC = $extval(reg(8), "UCSROC")
val UCSR0B = $extval(reg(8), "UCSR0B")
val UCSR0A = $extval(reg(8), "UCSR0A")

val UDR0 = $extval(reg(8), "UDR0")

val UCSZ01 = $extval(natLt(8), "UXSZ01")
val UCSZ00 = $extval(natLt(8), "UXSZ00")
val RXEN0 = $extval(natLt(8), "RXEN0")
val TXEN0 = $extval(natLt(8), "TXEN0")
val RXC0 =  $extval(natLt(8), "RXC0")
val UDRE0 = $extval(natLt(8), "UDRE0")

fun usart_init
  (ubrr: uint16) : void = {
    val () = setval(UBRR0L,_16_to_8(ubrr))
    val high = int2eight(_16_to_8(ubrr) >> 8) //ugly
    val () = setval(UBBR0H,high)
    //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
    val () = setbits(UCSROC,UCSZ01,UCSZ00)
    //Enable TX and RX
    val () = setbits(UCSR0B,RXEN0,TXEN0)
  }

fun usart_read_char () : char = c where {
    val () = wait_set_bit(UCSR0A,RXC0)
    val c = reg2char(UDR0)
  }
  
fun usart_send_char (c: char) : void = {
    val () = wait_clear_bit(UCSR0A, UDRE0)
    val () = setval(UDR0,char_to_8(c))
 }

(* Echo all characters received. *)
implement main () = loop() where {
  fun loop () : void = let
    val () = delay(50.0)
    val c = usart_read_char()
    val () = usart_send_char(c)
  in loop() end
}