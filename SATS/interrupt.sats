(* Interrupt Service Routines *)

%{#
#include "CATS/interrupt.cats"
%}

#define ATS_STALOADFLAG 0

absviewt@ype saved_sreg

symintr cli

fun cli_explicit
  (pf: INT_SET | (* none *) ) : (INT_CLEAR | void ) = "mac#cli"

overload cli with cli_explicit

fun cli_saved
  (saved: !saved_sreg) : (INT_CLEAR | void ) = "mac#cli"
  
overload cli with cli_saved

symintr sei

fun sei_explicit
  (pf: INT_CLEAR | (* none *) ) : (INT_SET | void ) = "mac#sei"
  
overload sei with sei_explicit

fun sei_saved
  (saved: !saved_sreg) : (INT_SET | void ) = "mac#sei"

overload sei with sei_saved

fun save_interrupts () : saved_sreg = "mac#save_interrupts"

symintr restore_interrupts

fun restore_interrupts_clear (pf: INT_CLEAR | saved: saved_sreg) : void = "mac#restore_interrupts"

overload restore_interrupts with restore_interrupts_clear

fun restore_interrupts_set (pf: INT_SET | saved: saved_sreg) : void = "mac#restore_interrupts"

overload restore_interrupts with restore_interrupts_set

(* 
  All these definitions should go inside io.sats instead since
  they are chip dependent.
*)
fun PCINT0_vect () : void = "PCINT0_vect"

symintr USART_RX_vect

fun USART_RX_vect_interrupts_enabled 
  () : void = "USART_RX_vect"

overload USART_RX_vect with USART_RX_vect_interrupts_enabled 

absviewtype UDR0_READ

fun USART_RX_vect_interrupts_disabled 
  (pf: !INT_CLEAR, pf0: UDR0_READ  | (* none *)) : void = "USART_RX_vect"

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

symintr TIMER0_OVF_vect

fun TIMER0_OVF_vect_interrupts_enabled
  () : void = "TIMER0_OVF_vect"

overload TIMER0_OVF_vect with TIMER0_OVF_vect_interrupts_enabled

fun TIMER0_OVF_vect_interrupts_disabled
  (pf: !INT_CLEAR | (* none *)) : void = "TIMER0_OVF_vect"
  
overload TIMER0_OVF_vect with TIMER0_OVF_vect_interrupts_disabled
