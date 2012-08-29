#ifndef _AVR_LIBATS_CYCBUF_HEADER
#define _AVR_LIBATS_CYCBUF_HEADER

typedef struct {
  volatile uint8_t w;
  volatile uint8_t r;
  volatile uint8_t n;
  volatile uint8_t size;
  volatile char base[];
} cycbuf_t;


#endif
