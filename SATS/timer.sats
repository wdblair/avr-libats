(* An interface for dealing with timers. *)

viewtypedef timer (n:int) = @{
  threshold= uint n,
  ticks= [t:nat | t <= n] uint t,
  task= () -<fun1> bool
}

(* 
  In ATS2 we could use abstract props as templates to identify
  on which timer we wanted to periodically run a function.
*)

fun delayed_task0 (
  period: ulint, task : () -<fun1> bool
) : void

fun delayed_task1 (
  period: ulint, task : () -<fun1> bool
) : void

fun delayed_task2 (
  period: ulint, task : () -<fun1> bool
) : void
