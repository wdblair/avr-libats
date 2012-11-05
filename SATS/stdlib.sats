%{#
#include<stdlib.h>
%}

fun {a:t@ype} qsort {n,p:nat | n <= p}
  (data: &(@[a][p]), n: int n, cmp: (&a, &a) -<fun1> int) : void
  
fun {a:t@ype} qsort_sync {n,p:nat | n <= p} (
  pf: !INT_CLEAR | data: &(@[a][p]), n: int n,
  cmp: (!INT_CLEAR | &a, &a) -<fun1> int
) : void
