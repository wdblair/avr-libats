%{#
#include<stdlib.h>
%}

fun {a:t@ype} qsort {n:nat}
  (data: &(@[a][n]), n: int n, cmp: (&a, &a) -<fun1> int) : void