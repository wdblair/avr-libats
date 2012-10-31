#ifndef _AVR_LIBATS_CYCBUF_HEADER
#define _AVR_LIBATS_CYCBUF_HEADER

typedef struct {
  uint8_t w;
  uint8_t r;
  uint8_t n;
  uint8_t size;
  char base[];
} cycbuf_t;

#endif
