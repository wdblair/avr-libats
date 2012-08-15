staload "SATS/io.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

extern
fun redirect_stdio () : void = "redirect_stdio"

extern
fun atmega328p_rx (f: FILEref) : int = "atmega328p_rx"

extern
fun atmega328p_tx (c: char, f: FILEref) : int = "atmega328p_tx"

extern
castfn int2eight (x:int) : [n:nat | n < 256] int n

val F_CPU = $extval(lint, "F_CPU")

extern
castfn reg2int(x:reg(8)) : int

extern
castfn char_to_8 (x:char) : [n:nat | n < 256] int n 

implement atmega328p_init (baud) = {
  val ubrr = ubrr_of_baud(baud)
  val () = set_regs_to_int(UBRR0H, UBRR0L, ubrr)
  //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
  val () = setbits(UCSR0C, UCSZ01, UCSZ00)
  //Enable TX and RX
  val () = setbits(UCSR0B, RXEN0, TXEN0)
  //Enable the standard library
  val () = redirect_stdio()
}

implement atmega328p_rx (f) = c where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = reg2int(UDR0)
}

implement atmega328p_tx (c, f) = res where {
    val () = 
      if c = '\n' then {
        val _ = atmega328p_tx('\r',f)
    }
    val () = loop_until_bit_is_set(UCSR0A, UDRE0)
    val () = setval(UDR0, char_to_8(c))
    val res = 0
}

%{
static FILE mystdio =
  FDEV_SETUP_STREAM((int(*)(char, FILE*))atmega328p_tx,
                    (int(*)(FILE*))atmega328p_rx,
                    _FDEV_SETUP_RW
                    );
ats_void_type
redirect_stdio () {
  stdout = &mystdio;
  stdin = &mystdio;
}
%}
