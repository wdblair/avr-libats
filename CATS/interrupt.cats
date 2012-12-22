#ifndef _AVR_LIBATS_INTERRUPT_HEADER
#define _AVR_LIBATS_INTERRUPT_HEADER

#include <avr/interrupt.h>

#define declare_isr(vector, ...)                                        \
  void vector (void) __attribute__ ((signal,__INTR_ATTRS)) __VA_ARGS__

#define save_interrupts() SREG
#define restore_interrupts(regs) SREG = regs

#define sei_saved(flag) sei()
#define cli_saved(flag) cli()

#endif
