#ifndef _AVR_LIBATS_SLEEP_HEADER
#define _AVR_LIBATS_SLEEP_HEADER

#include <avr/sleep.h>

#define avr_libats_sei_and_sleep_cpu()  \
  do {                                  \
    sei();                              \
    sleep_cpu();                        \
  } while(0)

#endif 
