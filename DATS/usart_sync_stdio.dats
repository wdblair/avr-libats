staload "SATS/io.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

extern
fun redirect_stdio () : void = "redirect_stdio"

implement atmega328p_init_stdio (baud) = {
  val () = atmega328p_init(baud)
  val () = redirect_stdio()
}

implement atmega328p_rx_stdio(f) = res where {
  val res = atmega328p_rx()
}

implement atmega328p_tx_stdio(c, f) = res where {
  val res = atmega328p_tx(c)
}

%{
static FILE mystdio =
  FDEV_SETUP_STREAM((int(*)(char, FILE*))atmega328p_tx_stdio,
                    (int(*)(FILE*))atmega328p_rx_stdio,
                    _FDEV_SETUP_RW
                    );
ats_void_type
redirect_stdio () {
  stdout = &mystdio;
  stdin = &mystdio;
}
%}
