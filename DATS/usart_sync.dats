staload "SATS/io.sats"
staload "SATS/usart.sats"

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

implement atmega328p_init (baud) = {
  val ubrr = ubrr_of_baud(baud)
  val () = set_regs_to_int(UBRR0H, UBRR0L, ubrr)
  //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
  val () = setbits(UCSR0C, UCSZ01, UCSZ00)
  //Enable TX and RX
  val () = setbits(UCSR0B, RXEN0, TXEN0)
}

implement atmega328p_rx () = c where {
    val () = loop_until_bit_is_set(UCSR0A, RXC0)
    val c = (int) UDR0
}

implement atmega328p_tx (c) = 0 where {
    val () = 
      if c = '\n' then {
        val _ = atmega328p_tx('\r')
    }
    val () = loop_until_bit_is_set(UCSR0A, UDRE0)
    val () = setval(UDR0, c)
}