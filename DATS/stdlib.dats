staload "SATS/stdlib.sats"

local
  extern fun {a:t@ype}
  default_qsort {n,p:nat | n <= p} (
    data: &(@[a][p]), n: int n, n: sizeof_t a, cmp: (&a, &a) -<fun1> int
  ) : void = "mac#qsort"
in

implement {a}
  qsort {n,p} (data, n, cmp) = default_qsort(data, n, sizeof<a>, cmp)
end