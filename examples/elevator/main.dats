(*  
   Rough sketch of an elevator simulator.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/global.sats"

(* ****** ****** *)

staload "SATS/stdlib.sats"
staload "DATS/stdlib.dats"

(* ****** ****** *)

stadef schedule_size = 10

%{^
#define SCHEDULE_SIZE 10

#define elevator_get_state() ((elevator_state_t* volatile)&elevator_state)
#define neg_direction(a) (a^1)

typedef struct {
  int cnt;
  int size;
  int data[SCHEDULE_SIZE];
} queue_t;

typedef struct {
  volatile queue_t fscan[2];
  volatile uint8_t current;
} elevator_state_t;

static volatile elevator_state_t elevator_state;


%}

datatype control_state =
  | ready of ()
  | moving of ()
  
typedef direction = [n:nat | n < 2] int n

macdef UP = 0
macdef DOWN = 1

extern
fun neg_direction (d: direction) : direction = "mac#neg_direction"

overload ~ with neg_direction

viewtypedef queue (a: t@ype, n:int, sz:int) =
  $extype_struct "queue_t" of {
    cnt= int n,
    size= int sz,
    data= @[a][sz]
  }
  
fun {a:t@ype} enqueue {n, sz:nat | n < sz} (
  q: &queue(a, n, sz) >> queue(a, n+1, sz),  x: a, 
  cmp: (&a, &a) -<fun1> int
) : void = {
  val () = q.data.[q.cnt] := x
  val () = q.cnt := q.cnt + 1
  val () = qsort(q.data, q.cnt, cmp)
}

fun {a:t@ype} dequeue {n, sz:nat | n > 0; n <= sz} (
  q: &queue(a, n, sz) >> queue(a, n-1, sz), x: &a? >> a
) : void = {
  val () = x := q.data.[q.cnt - 1]
  val () = q.cnt := q.cnt - 1
}

fun {a:t@ype} empty {s,n:nat | n <= s} (
  q: &queue(a, n, s)
) : bool (n <= 0) = q.cnt = 0

fun {a:t@ype} full {s,n:nat | n <= s} (
  q: &queue(a, n, s)
) : bool (n == s) = q.cnt = q.size

viewtypedef elevator_state =
  $extype_struct "elevator_state_t" of {
    fscan= @[ [n:nat | n <= schedule_size]
      queue(int, n, schedule_size)
    ][2],
    current= direction
  }
  
extern
fun state() : [l:agz] (global(l), elevator_state @ l | ptr l)
  = "mac#elevator_get_state"

fun has_request(d:direction) : bool = ~clr where {
  val (free, pf | p) = state()
  val clr =  empty(p->fscan.[d])
  prval () = return_global(free, pf)
}

fun next_request(d:direction) : int = let
  val (free, pf | p) = state()
  val q = p->fscan.[d]
in
  if ~empty(q) then let 
    var x : int
    val () = dequeue(q, x)
    prval () = return_global(free, pf)
  in x end
  else ~1 where {
    prval () = return_global(free, pf)
  }
end

implement main (clr | (**)) = {
  val (set | ()) = sei(clr | (**))
  fun loop(set:INT_SET | s: control_state) : (INT_CLEAR | void) =
    case+ s of
      | ready() =>
            loop(set | s)
      | moving() => 
          loop(set | s)
  val (pf0 | ()) = loop(set | ready())
  prval () = clr := pf0
}
