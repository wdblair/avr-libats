(* Sleep Functionality *)

%{#
#include "CATS/sleep.cats"
%}

#define ATS_STALOADFLAG 0

staload "SATS/interrupt.sats"

fun sleep_mode () : void = "mac#sleep_mode"

fun sleep_cpu  () : void = "mac#sleep_cpu"

fun sleep_enable () : void = "mac#sleep_enable"

fun sleep_disable () : void = "mac#sleep_disable"

fun sei_and_sleep_cpu 
  (pf: INT_CLEAR | (*none*)) : (INT_SET | void)
    = "mac#avr_libats_sei_and_sleep_cpu"
