staload "SATS/stdlib.sats"

local
  extern fun {a:t@ype}
  default_qsort {n:nat} (
    data: &(@[a][n]), n: int n, n: sizeof_t a, cmp: (&a, &a) -<fun1> int
  ) : void = "mac#qsort"
in

implement {a}
  qsort {n} (data, n, cmp) = default_qsort(data, n, sizeof<a>, cmp)
end