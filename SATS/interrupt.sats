(* Interrupt Service Routines *)

%{#
#include <avr/interrupt.h>
#include "CATS/interrupt.cats"
%}

#define ATS_STALOADFLAG 0

fun cli
  () : (INT_CLEAR | void ) = "mac#cli"

fun sei
  (pf: INT_CLEAR | (* none *) ) : void = "mac#sei"

fun PCINT0_vect () : void = "PCINT0_vect"

symintr USART_RXC_vect

fun USART_RXC_vect_interrupts_enabled 
  () : void = "USART_RXC_vect"

overload USART_RXC_vect with USART_RXC_vect_interrupts_enabled 

fun USART_RXC_vect_interrupts_disabled 
  (pf: !INT_CLEAR | (* none *)) : void = "USART_RXC_vect"

overload USART_RXC_vect with USART_RXC_vect_interrupts_disabled 

symintr USART_TXC_vect

fun USART_TXC_vect_interrupts_enabled 
  () : void = "USART_TXC_vect"

overload USART_TXC_vect with USART_TXC_vect_interrupts_enabled

fun USART_TXC_vect_interrupts_disabled 
  (pf: !INT_CLEAR | (* none *) ) : void = "USART_TXC_vect"

overload USART_TXC_vect with USART_TXC_vect_interrupts_disabled

symintr TWI_vect

fun TWI_vect_interrupts_enabled 
  () : void = "TWI_vect"
  
overload TWI_vect with TWI_vect_interrupts_enabled

fun TWI_vect_interrupts_disabled
  (pf: !INT_CLEAR | (* none *) ) : void = "TWI_vect"
  
overload TWI_vect with TWI_vect_interrupts_disabled
