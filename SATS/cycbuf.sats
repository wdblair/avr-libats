%{#
#include "CATS/cycbuf.cats"
%}

viewtypedef cycbuf_array (a:t@ype, n:int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = uint8 w,
      r = uint8 r,
      n = uint8 n,
      size = uint8 s,
      base = @[a][s]
}
