(*  Rough sketch of an elevator simulator. *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/stdlib.sats"
staload "SATS/stdlib.dats"

#define SCHEDULE_SIZE 10

%{^
#define SCHEDULE_SIZE 10

typedef struct {
  int n;
  int data[SCHEDULE_SIZE];
} queue_t;

static volatile queue_t fscan[2];
%}

datatype state =
  | ready of ()
  | moving of ()
  
typedef queue (n:int) =
  $extype_struct "queue_t" of {
    cnt= int n,
    data= @[int][SCHEDULE_SIZE]
  }
  
implement main (clr | (**)) = {
  val (set | ()) = sei(clr | (**))
  fun loop(set:INT_SET | s: state) : (INT_CLEAR | void) =
    case+ s of
      | ready() => 
          loop(set | s)
      | moving() => 
          loop(set | s)
  val (pf0 | ()) = loop(set | ready())
  prval () = clr := pf0
}
