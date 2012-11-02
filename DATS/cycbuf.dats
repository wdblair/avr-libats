#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

staload "SATS/fifo.sats"
staload "SATS/cycbuf.sats"

assume fifo(a:t@ype, n:int, s:int) =
  [w,r:nat | n <= s; w < s; r < s] cycbuf_array(a, n, s, w, r)

stadef cycbuf_read_write(size:int, read:int, write:int) =
  (read < size && write < size)

stadef cycbuf_space_available (
  size:int, count:int, read:int, write:int
) =
  cycbuf_read_write(size, read, write)
    && count < size

fun {a:t@ype} cycbuf_insert {s:nat}
    {n, r, w: nat | cycbuf_space_available(s, n, r, w)} (
    f: &cycbuf_array(a, n, s, w, r)
        >> cycbuf_array(a, n+1, s, w', r), x: a
) : #[w':nat | w' < s] void = let
    val () = f.n := f.n + 1
    val () = f.base.[f.w] := x
  in
    f.w := (f.w + 1) nmod1 f.size
  end

stadef cycbuf_not_empty (
  size:int, count:int, read:int, write:int
) =
  cycbuf_read_write(size, read, write)
    && count <= size && count > 0

fun {a:t@ype} cycbuf_remove
    {s,n,r,w:nat | cycbuf_not_empty(s,n,r,w) } (
    f: &cycbuf_array(a, n, s, w, r)
        >> cycbuf_array(a, n-1, s, w, r'), x: &a? >> a
) : #[r':nat | r' < s] void = let
    val () = f.n := f.n - 1
    val () = x := f.base.[f.r]
  in
    f.r := (f.r + 1) nmod1 f.size
  end

implement {a} insert (lpf | f , x) =
  cycbuf_insert(f, x)

implement {a} remove (lpf | f , x) =
  cycbuf_remove(f, x)
  
fun {a:t@ype} cycbuf_is_empty {s,n:nat | n <= s}
    {w,r:nat | w < s; r < s} (
    f: &cycbuf_array(a,n,s,w,r)
) : bool(n == 0) = f.n = 0

implement {a} empty (pf | f) =
  cycbuf_is_empty(f)

fun {a:t@ype} cycbuf_is_full {s:pos}
      {n,w,r:nat | n <= s; w < s; r < s} (
    f: &cycbuf_array(a,n,s,w,r)
) : bool(n == s) = f.size = f.n

implement {a} full (pf | f) =
  cycbuf_is_full(f)
