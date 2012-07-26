%{#
#include <util/delay.h>
%}

(* Should Preserve their libary layout. Just keeping it simple for now. *)
fun delay (t: double) : void = "mac#_delay_ms"
