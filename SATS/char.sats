%{#
#include "CATS/char.cats"
%}


fun asl_uchar_int1 
  (c: uchar, n: Nat) : uchar = "mac#avr_libats_asl_uchar_int1"

overload << with asl_uchar_int1

infix (<<) <<

fun asr_uchar_int1
  (c: uchar, n: Nat) : uchar = "mac#avr_libats_asr_uchar_int1"
  
overload >> with asr_uchar_int1

infix (>>) >>

symintr lor

fun lor_uchar_uchar
  (a: uchar, b: uchar) : uchar = "mac#avr_libats_lor_uchar_uchar"

overload lor with lor_uchar_uchar

//infix (lor) lor

castfn uchar_of_bool (b:bool) : uchar

castfn uchar_of_int (i:int) : uchar
