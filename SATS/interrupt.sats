(* Declarations for Interrupt Service Routines *)

%{#
#include <avr/interrupt.h>
%}

fun PCINT0_vect () : void = "PCINT0_vect"

fun USART_RXC_vect () : void = "USART_RXC_vect"

fun USART_TXC_vect () : void = "USART_TXC_vect"