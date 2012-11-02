absviewt@ype fifo (t@ype, int, int)

fun {a:t@ype} insert {s:pos} {n:nat | n < s} (
   lpf: !INT_CLEAR |
   f : &fifo(a,n,s) >> fifo(a, n+1, s), x: a
) : void

fun {a:t@ype} remove {s,n:pos | n <= s} (
  lpf: !INT_CLEAR | 
  f: &fifo(a,n,s) >> fifo(a, n-1, s), x: &a? >> a
) : void

fun {a:t@ype} peek {s,n:pos | n <= s} (
  lpf: !INT_CLEAR | 
  f: &fifo(a, n, s), x: &a? >> a
) : void

fun {a:t@ype} empty {s,n:nat | n <= s} (
  lpf: !INT_CLEAR | f: &fifo(a, n, s)
) : bool (n == 0)

fun {a:t@ype} full {s,n:nat | n <= s} (
  lpf: !INT_CLEAR | f: &fifo(a,n,s)
) : bool (n == s)