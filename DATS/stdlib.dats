staload "SATS/stdlib.sats"

local
  extern fun
  default_qsort_basic {a:t@ype} {n,p:nat | n <= p} (
    data: &(@[a][p]), n: int n, n: sizeof_t a, cmp: (&a, &a) -<fun1> int
  ) : void = "mac#qsort"

  extern fun
  default_qsort_sync {a:t@ype} {n,p:nat | n <= p} (
    pf: !INT_CLEAR | data: &(@[a][p]), n: int n, n: sizeof_t a,
    cmp: (!INT_CLEAR | &a, &a) -<fun1> int
  ) : void = "mac#qsort"
in

implement {a}
  qsort {n, p} (data, n, cmp) =
    default_qsort_basic(data, n, sizeof<a>, cmp)
    
implement {a}
  qsort_sync {n,p} (pf | data, n, cmp) =
    default_qsort_sync(pf | data, n, sizeof<a>, cmp)
end
