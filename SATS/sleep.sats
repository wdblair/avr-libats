(* Sleep Functionality *)

%{#
#include "CATS/sleep.cats"
%}

#define ATS_STALOADFLAG 0

staload "SATS/interrupt.sats"

fun sei_and_sleep_cpu 
  (pf: INT_CLEAR | (*none*) ) : void = "mac#avr_libats_sei_and_sleep_cpu"

