#ifndef _AVR_LIBATS_USART_HEADER
#define _AVR_LIBATS_USART_HEADER

#include <stdlib.h>

//Would like to move this to ATS if I make an interface around stdlib
ATSinline()
ats_uint16_type
avr_libats_ubrr_of_baud (ats_uint16_type baud) {
  //ubrr = ( F_CPU / (BAUD x 16 ) ) - 1
  uint16_t ubrr;
  ldiv_t div;
  div = ldiv((F_CPU >> 4), baud);
  ubrr = (uint16_t)div.quot;
  
  if((uint32_t)(div.rem) < baud)
    ubrr--;
  return ubrr;
}

ATSinline()
ats_char_type
avr_libats_read_udr0() {
  return UDR0;
}

#endif
