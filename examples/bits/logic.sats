(*
An abstraction for adding constraints to
8 bit registers.
*)

absview
REGISTER (
  n:int, B0: bool, B1: bool, B2: bool, B3:bool, B4: bool, B5: bool, B6: bool, B7: bool
)

fun bitor {n:nat} {n':nat} {a,b,c,d,e,f,g,h:bool}
			{a',b',c',d',e',f',g',h':bool}
(pfa: REGISTER(n,a,b,c,d,e,f,g,h),
 pfb: REGISTER(n',a',b',c',d',e',f',g',h') | a: uint n, b: uint n') : [p:nat]
  (REGISTER(p, a || a',b || b', c || c', d || d', e || e', f || f', g || g', h || h') | uint p)

fun bitand {n,n':nat} {a,b,c,d,e,f,g,h:bool}
			 {a',b',c',d',e',f',g',h': bool}
(pfa: REGISTER(n,a,b,c,d,e,f,g,h),
 pfb: REGISTER(n',a',b',c',d',e',f',g',h') | a: uint n, b: uint n') : [p:nat]
  (REGISTER(p, a && a',b && b', c && c', d && d', e && e', f && f', g && g', h && h') | uint p)

fun bitnot {n:nat} {a,b,c,d,e,f,g,h:bool}
(pfa: REGISTER(n,a,b,c,d,e,f,g,h) | a: uint n) : [p:nat] (REGISTER(p,~a,~b,~c,~d,~e,~f,~g,~h) | uint p)

stadef
xor (a:bool, b:bool) = ( (a || b) || (~a && ~b) )

prfun bitxor {n,n':nat} {a,b,c,d,e,f,g,h: bool} {a',b',c',d',e',f',g',h':bool}
(
  a: REGISTER(n,a,b,c,d,e,f,g,h),
  b: REGISTER(n',a',b',c',d',e',f',g',h')
) : 
[p:nat] REGISTER (
  p, xor(a,a'), xor(b,b'), xor(c,c'), xor(d,d'), 
  xor(e,e'), xor(f,f'), xor(g,g'), xor(h,h')
)

viewtypedef register = [n:nat] [a,b,c,d,e,f,g,h:bool] (
  REGISTER (n,a,b,c,d,e,f,g,h) |  uint n
)

(*
var TCCR2A : register = (
  REGISTER(0, false,false,false,false,false,false,false,false) | $extval(uint 0, "TCCR2A")
)
*)
