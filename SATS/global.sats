(* 
  An interface for global variables. Also contains functionality
  for sharing data between AVR code and ISRs without resorting to
  classifying variables as volatile.
*)

#define ATS_STALOADFLAG 0

(* For global variables not shared with ISRs. *)

absprop global (view)

praxi global_get{v:view} (g: global(v)) : (v)

praxi global_return{v:view} (g: global(v), f: v) : void

praxi global_new{v:view} (pf: v) : global(v)

(* Locking Proof Functions (For Variables Shared with ISRs) *)
absprop global_locked (view)

praxi lock {v:view} (
  pf: !INT_CLEAR, g: global_locked(v)
) : (v)

praxi unlock {v:view} (
  pf: !INT_CLEAR, g: global_locked(v), pf: v
) : void

praxi lock_new {v:view} (
  pf: v
) : global_locked(v)
