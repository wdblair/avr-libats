#ifndef _AVR_LIBATS_USART_HEADER
#define _AVR_LIBATS_USART_HEADER

ATSinline()
ats_uint16_type
avr_libats_ubrr_of_baud (ats_uint16_type baud) {
  uint16_t ubrr;
  ldiv_t div;
  div = ldiv((F_CPU >> 4), baud);
  ubrr = (uint16_t)div.quot;
  
  if((uint32_t)(div.rem) < baud)
    {
      ubrr--;
    }
  return ubrr;
}

#endif
