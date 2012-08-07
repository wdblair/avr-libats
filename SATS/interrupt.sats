(* Interrupt Service Routines *)

%{#
#include <avr/interrupt.h>
#include "CATS/interrupt.cats"
%}

#define ATS_STALOADFLAG 0

fun cli
  (pf: INT_SET | (* none *) ) : (INT_CLEAR | void ) = "mac#cli"

fun sei
  (pf: INT_CLEAR | (* none *) ) : (INT_SET | void ) = "mac#sei"

fun PCINT0_vect () : void = "PCINT0_vect"

symintr USART_RX_vect

fun USART_RX_vect_interrupts_enabled 
  () : void = "USART_RX_vect"

overload USART_RX_vect with USART_RX_vect_interrupts_enabled 

fun USART_RX_vect_interrupts_disabled 
  (pf: !INT_CLEAR | (* none *)) : void = "USART_RX_vect"

overload USART_RX_vect with USART_RX_vect_interrupts_disabled 

symintr USART_TX_vect

fun USART_TX_vect_interrupts_enabled 
  () : void = "USART_TX_vect"

overload USART_TX_vect with USART_TX_vect_interrupts_enabled

fun USART_TX_vect_interrupts_disabled 
  (pf: !INT_CLEAR | (* none *) ) : void = "USART_TX_vect"

overload USART_TX_vect with USART_TX_vect_interrupts_disabled

symintr TWI_vect

fun TWI_vect_interrupts_enabled 
  () : void = "TWI_vect"
  
overload TWI_vect with TWI_vect_interrupts_enabled

fun TWI_vect_interrupts_disabled
  (pf: !INT_CLEAR | (* none *) ) : void = "TWI_vect"
  
overload TWI_vect with TWI_vect_interrupts_disabled
