(* Sleep Functionality *)

%{#
#include "CATS/sleep.cats"
%}

#define ATS_STALOADFLAG 0

staload "SATS/interrupt.sats"

fun sleep_mode () : void = "mac#sleep_mode"

fun sleep_enable () : void = "mac#sleep_enable"

fun sleep_disable () : void = "mac#sleep_disable"

symintr sleep_cpu

fun sei_and_sleep_cpu 
  (pf: INT_CLEAR | (*none*)) :  (INT_SET | void)
    = "mac#avr_libats_sei_and_sleep_cpu"

overload sleep_cpu with sei_and_sleep_cpu

fun sleep_cpu_avrlibc  () : void = "mac#sleep_cpu"

overload sleep_cpu with sleep_cpu_avrlibc