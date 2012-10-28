absviewt@ype fifo (t@ype, int, int)

fun {a:t@ype} insert {l:agz} {s:pos} {n:nat | n < s} (
   lpf: !INT_CLEAR,
   pf: !fifo(a,n,s) @ l >> fifo(a, n+1, s) @ l |
   p: ptr l, x: a
) : void

fun {a:t@ype} remove {l:agz} {s,n:pos | n <= s} (
  lpf: !INT_CLEAR,
  pf: !fifo(a,n,s) @ l >> fifo(a, n-1, s) @ l |
  p: ptr l, x: &a? >> a
) : void

fun {a:t@ype} empty {l:agz} {s,n:nat | n <= s} (
  pf: !fifo(a,n,s) @ l | 
  p: ptr l
) : bool (n == 0)

fun {a:t@ype} full {l:agz} {s,n:nat | n <= s} (
  pf: !fifo(a,n,s) @ l |
  p: ptr l
) : bool (n == s)