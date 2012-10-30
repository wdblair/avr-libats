%{#
#include<stdlib.h>
%}

fun {a:t@ype} qsort {n,p:nat | n <= p}
  (data: &(@[a][p]), n: int n, cmp: (&a, &a) -<fun1> int) : void