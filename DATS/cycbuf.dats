(* An implementation of the fifo data structure. *)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

staload "SATS/interrupt.sats"
staload "SATS/fifo.sats"
staload "SATS/cycbuf.sats"

assume fifo(a:t@ype, n:int, s:int) =
  [w,r:nat | n <= s; w < s; r < s] cycbuf_array(a, n, s, w, r)
  
local

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
      val () = f.n := f.n + (uint8)1
      val () = f.base.[f.w] := x
    in
      f.w := (f.w + (uint8)1) mod f.size
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
      val () = f.n := f.n - (uint8)1
      val () = x := f.base.[f.r]
    in
      f.r := (f.r + (uint8)1) mod f.size
    end

  fun {a:t@ype} cycbuf_peek
      {s,n,r,w:nat | cycbuf_not_empty(s,n,r,w) } (
        f: &cycbuf_array(a, n, s, w, r), x: &a? >> a
  ) : void = x := f.base.[f.r]

  fun {a:t@ype} cycbuf_peek_tail
      {s,n,r,w:nat | cycbuf_not_empty(s,n,r,w) } (
        f: &cycbuf_array(a, n, s, w, r), x: &a? >> a
  ) : void =
    if f.w = (uint8) 0 then
      x := f.base.[f.size - (uint8)1]
    else
      x := f.base.[f.w - (uint8)1]
      
  fun {a:t@ype} cycbuf_is_empty {s,n:nat | n <= s}
      {w,r:nat | w < s; r < s} (
      f: &cycbuf_array(a,n,s,w,r)
  ) : bool(n == 0) = f.n = (uint8)0

  fun {a:t@ype} cycbuf_is_full {s:pos}
        {n,w,r:nat | n <= s; w < s; r < s} (
      f: &cycbuf_array(a,n,s,w,r)
  ) : bool(n == s) = f.size = f.n

in

  implement {a} insert (lpf | f, x) =
    cycbuf_insert(f, x)

  implement {a} remove (lpf | f , x) =
    cycbuf_remove(f, x)

  implement {a} peek (lpf | f, x) =
    cycbuf_peek(f, x)
    
  implement {a} peek_tail (lpf | f, x) =
    cycbuf_peek_tail(f, x)
    
  implement {a} empty (pf | f) =
    cycbuf_is_empty(f)

  implement {a} full (pf | f) =
    cycbuf_is_full(f)
end