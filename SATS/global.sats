(* 
  An interface for global variables. Also contains functionality
  for sharing data between AVR code and ISRs without having to
  variables as volatile.  
*)

#define ATS_STALOADFLAG 0

absprop global (view)

praxi global_get{v:view} (g: global(v)) : (v)

praxi global_return{v:view} (g: global(v), f: v) : void

praxi global_new{v:view} (pf: v) : global(v)
