(* 
  Functions for creating globals are application specific and should be written on the spot.
*)

#define ATS_STALOADFLAG 0

(* An address in the .data section, cannot free it. *)
absview global (l:addr)

praxi return_global {a:viewt@ype} {l:agz} (
  pfg: global(l), pf: a @ l
) : void