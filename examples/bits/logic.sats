(*
An abstraction for adding constraints to
8 bit registers.
*)

absview
REGISTER (
  n:int, B0: bool, B1: bool, 
  B2: bool, B3:bool, B4: bool, 
  B5: bool, B6: bool, B7: bool
)

viewtypedef register (n:int) (a,b,c,d,e,f,g,h:bool) = (
  REGISTER (n,a,b,c,d,e,f,g,h) |  uint n
)

fun bitor {n,n':nat} {a,b,c,d,e,f,g,h:bool}
	  {a',b',c',d',e',f',g',h':bool}
(x: register(n)(a,b,c,d,e,f,g,h),
 y: register(n')(a',b',c',d',e',f',g',h')
) : [p:nat] (
  register(p) (
    a || a', b || b', c || c', d || d', 
    e || e', f || f', g || g', h || h'
  )
)

fun bitand {n,n':nat} {a,b,c,d,e,f,g,h:bool}
	   {a',b',c',d',e',f',g',h': bool}
(
  x: register(n)(a,b,c,d,e,f,g,h),
  y: register(n')(a',b',c',d',e',f',g',h')
) : [p:nat] (
  register(p)( 
    a && a',b && b', c && c', d && d', 
    e && e', f && f', g && g', h && h'
  )
)

fun bitnot {n:nat} {a,b,c,d,e,f,g,h:bool}
(
  x: register(n)(a,b,c,d,e,f,g,h)
) : [p:nat] (
  register(p)(~a,~b,~c,~d,~e,~f,~g,~h)
) = "mac#bitnot"

stadef
xor (a:bool, b:bool) = ( (a || b) || (~a && ~b) )

fun bitxor {n,n':nat} {a,b,c,d,e,f,g,h: bool} 
           {a',b',c',d',e',f',g',h':bool} (
  x: register(n)(a,b,c,d,e,f,g,h),
  y: register(n')(a',b',c',d',e',f',g',h')
) : [p:nat] (
  register (p) (
  xor(a,a'), xor(b,b'), xor(c,c'), xor(d,d'),
  xor(e,e'), xor(f,f'), xor(g,g'), xor(h,h')
)) = "mac#bitxor"

fun set {n,n':nat} {a,b,c,d,e,f,g,h: bool} 
        {a',b',c',d',e',f',g',h':bool} (
  x: !register(n)(a,b,c,d,e,f,g,h) >> register(n')(a',b',c',d',e',f',g',h'),
  y: register(n')(a',b',c',d',e',f',g',h') |
) : void = "mac#bitset"

fun setor {n,n':nat} {p:nat} {a,b,c,d,e,f,g,h: bool} 
          {a',b',c',d',e',f',g',h':bool} (
  x: !register(n)(a,b,c,d,e,f,g,h) >> register(p)(
    a||a',b||b',c||c',d||d',
    e||e',f||f',g||g',h||h'
  ),
  y: register(n')(a',b',c',d',e',f',g',h')
) : void = "mac#bitsetor"

fun setand {n,n':nat} {p:nat} {a,b,c,d,e,f,g,h: bool}
          {a',b',c',d',e',f',g',h':bool} (
  x: !register(n)(a,b,c,d,e,f,g,h) >> register(p)(
    a && a',b && b',c && c',d && d',
    e && e',f && f',g && g',h && h'
  ),
  y: register(n')(a',b',c',d',e',f',g',h')
) : void = "mac#bitsetor"


