%{#
#include<ctype.h>
#include<stdint.h>
#include<stdio.h>
%}

#define ATS_STALOADFLAG 0

fun getchar 
  () : int = "mac#getchar"

fun putchar
  (c:char) : int = "mac#putchar"

fun puts 
  (s: string) : int = "mac#puts"

fun fflush 
  (f: FILEref) : int = "mac#fflush"