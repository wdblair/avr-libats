%{#
#include<stdio.h>
%}

#define ATS_STALOADFLAG 0

fun getchar 
  () : int = "mac#getchar"

fun fflush 
  (f: FILEref) : int = "mac#fflush"