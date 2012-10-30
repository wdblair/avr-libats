(*  
   Rough sketch of an elevator simulator.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/global.sats"
staload "SATS/sleep.sats"

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
  uint8_t direction;
  uint8_t floor;
} request_t;

typedef struct {
  volatile uint8_t cnt;
  volatile uint8_t size;
  request_t data[SCHEDULE_SIZE];
} queue_t;

typedef struct {
  volatile queue_t fscan[2];
  volatile uint8_t current;
  volatile uint8_t arrived;
  volatile uint8_t id;
} elevator_state_t;

static volatile elevator_state_t elevator_state;
%}

typedef control_state = [n:nat | n < 2] int n

#define READY 0
#define MOVING 1
  
typedef direction = [n:nat | n < 2] int n

macdef UP = 0
macdef DOWN = 1

typedef queue_id = [n:nat | n < 2] int n

extern
fun neg_direction (d: direction) : direction = 
  "mac#neg_direction"

overload ~ with neg_direction

extern
fun neg_queue_id (d: queue_id) : queue_id = 
  "mac#neg_direction"

overload ~ with neg_queue_id

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
) : bool (n == 0) = q.cnt = 0

fun {a:t@ype} full {s,n:nat | n <= s; s > 0} (
  q: &queue(a, n, s)
) : bool (n == s) = q.cnt = q.size

(* A bit of a hack... *)
extern
castfn reference {a:t@ype} {n,s:nat} (
  x: &queue(a,n,s)
) : [l:agz] (global(l), queue(a, n, s) @ l | ptr l)

abst@ype foobar = $extype "foo"

typedef foobar = @(int, int)

typedef request = $extype_struct "request_t" of {
  direction= direction,
  floor= int
}

typedef ElevatorQueue = 
  [n:nat | n <= schedule_size] queue(request, n , schedule_size)

viewtypedef elevator_state =
  $extype_struct "elevator_state_t" of {
    fscan= @[ElevatorQueue][2],
    id= queue_id,
    current= direction,
    arrived= bool
  }
  
extern
fun state() : [l:agz] (global(l), elevator_state @ l | ptr l)
  = "mac#elevator_get_state"

(*** The interface for the elevator controller. ***)

fun has_request(d: queue_id) : bool = ~clr where {
  val (free, pf | p) = state()
  val clr =  empty(p->fscan.[d])
  prval () = return_global(free, pf)
}

fun add_request(r: request) : void = let
    fun cmp (a: &request, b: &request) : int = 
      a.floor - b.floor
    val (free, pf | p) = state()
    val (elimq, pfq | q) = reference(p->fscan.[neg_queue_id(p->id)])
  in
    if full(!q) then {
      //drop the request.
      prval () = return_global(free, pf)
      prval () = return_global(elimq, pfq)
    } else {
      val () = enqueue<request>(!q, r, cmp)
      prval () = return_global(free, pf)
      prval () = return_global(elimq, pfq)
    }
  end

fun next_request(d: queue_id) : request = let
  val (free, pf | p) = state()
  val (elimq, pfq | q) = reference(p->fscan.[d])
  var x : request
in
  x where {
    val () = 
      if ~empty(!q) then {
        val () = dequeue<request>(!q, x)
        prval () = return_global(elimq, pfq)
        prval () = return_global(free, pf)
      }
      else {
        val () = x.direction := 0
        val () = x.floor := ~1
        prval () = return_global(elimq, pfq)
        prval () = return_global(free, pf)
      }
  }
end

fun current_queue () : queue_id = id where {
  val (free, pf | p) = state()
  val id = p->id
  prval () = return_global(free, pf)
}

fun current_direction () : direction = d where {
  val (free, pf | p) = state()
  val d = p->current
  prval () = return_global(free, pf)
}

fun switch_direction () : void = {
  val (free, pf | p) = state()
  val () =  p->current := neg_direction(p->current)
  prval () = return_global(free, pf)
}

fun switch_queues () : void = {
  val (free, pf | p) = state()
  val () =  p->id := neg_queue_id(p->id)
  prval () = return_global(free, pf)
}

fun send_command(floor: request) : void = 
  ()

fun arrived () : bool = a where {
  val (free, pf | p) = state()
  val a = p->arrived
  prval () = return_global(free, pf)
}

(* ****** ****** *)

implement main (clr | (**)) = {
  val (set | ()) = sei(clr | (**))
  fun loop(set:INT_SET | s: control_state) : (INT_CLEAR | void) =
    case+ s of
      | READY => let
          val q = current_queue ()
        in
          if has_request(q) then let
            val next = next_request(q)
            val () =
              if next.direction != current_direction() then
                switch_direction()
            val () = send_command(next)
          in loop(set | MOVING) end
          
          else if has_request(neg_queue_id(q)) then let
            val () = switch_queues()
          in loop(set | s) end
          
          else let
            val () = sleep_enable()
            val () = sleep_cpu()
            val () = sleep_disable()
          in loop(set | s) end
        end
      | MOVING =>
        if arrived() then 
          loop(set | READY)
        else let
          val () = sleep_enable()
          val () = sleep_cpu()
          val () = sleep_disable()
        in loop(set | s) end
  val (pf0 | ()) = loop(set | READY)
  prval () = clr := pf0
}
