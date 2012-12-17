(* 
  An interface for global variables. Also contains functionality
  for sharing data between AVR code and ISRs without resorting to
  classifying variables as volatile.
*)
#define ATS_STALOADFLAG 0

%{#
#include "CATS/global.cats"
%}

viewtypedef global(v:view, l:addr) = @{
  at= v,
  p= ptr l
}

(* For global variables not shared with ISRs. *)

fun global_new {v:view} {l:addr} (
  pf: v | p: ptr l
) :<> global(v, l) = "mac#global_new"

absprop viewlock(v:view)

praxi viewlock_new {v:view} (
  pf: v
) : viewlock(v)

praxi viewlock{v:view}(
  v: viewlock(v)
) : v

typedef viewkey(v:view, l:addr) = @{
  lock= viewlock(v),
  p = ptr l
}

praxi global_return {v:view} {l:addr} (
  l: viewkey(v, l), g: global(v, l)
) : void

fun global_get {v:view} {l:addr} (
  g: viewkey(v, l)
) : global(v, l) = "mac#get_global"

(* Locking Proof Functions (For Variables Shared with ISRs) *)

absprop interrupt_lock (view)

praxi lock {v:view} (
  pf: !INT_CLEAR, g: interrupt_lock(v)
) : (v)

praxi unlock {v:view} (
  pf: !INT_CLEAR, g: interrupt_lock(v), pf: v
) : void

praxi interrupt_lock_new {v:view} (
  pf: v
) : interrupt_lock(v)

typedef sharedkey(v:view, l:addr) = @{
  lock= interrupt_lock(v),
  p = ptr l
}

fun global_shared_get {v:view} {l:addr} (
  pf: !INT_CLEAR, g: sharedkey(v,l)
) : global(v, l) = "mac#global_shared_get"