%{#
#include <util/delay.h>
%}

#define ATS_STALOADFLAG 0

fun delay (t: double) : void = "mac#_delay_ms"
