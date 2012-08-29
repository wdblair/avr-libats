%{#
#include "CATS/cycbuf.cats"
%}

viewtypedef cycbuf_array (a:t@ype, n:int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = int w,
      r = int r,
      n = int n,
      size = int s,
      base = @[a][s]
}
