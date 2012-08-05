(* 
  Functions for creating globals are application specific and should be written on the spot.
*)

(* An address in the .data section, cannot free it. *)
absview global (l:addr)

praxi return_global {a:t@ype} {l:agz} (
  pfg: global(l), pf: a @ l
) : void