(*
   Rough sketch of an elevator simulator.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/global.sats"
staload "SATS/sleep.sats"

staload FIFO = "SATS/fifo.sats"
staload USART = "SATS/usart.sats"

(* ****** ****** *)

staload _ = "DATS/usart_async.dats"

(* ****** ****** *)

staload "SATS/stdlib.sats"
staload "DATS/stdlib.dats"

staload "SATS/stdio.sats"

(* ****** ****** *)

stadef schedule_size = 10

%{^
#define SCHEDULE_SIZE 10

#define elevator_get_state() ((elevator_state_t*)&elevator_state)
#define neg_direction(a) (a^1)

typedef struct {
  uint8_t direction;
  uint8_t floor;
  uint8_t onboard;
} request_t;

typedef struct {
  uint8_t cnt;
  uint8_t size;
  request_t data[SCHEDULE_SIZE];
} queue_t;

typedef struct {
  queue_t queue;
  uint8_t current;
  uint8_t arrived;
  uint8_t floor;
} elevator_state_t;

//Would like to do the trick I do in the TWI driver,
//make this a global variable in ATS.
static elevator_state_t elevator_state;
%}

typedef control_state = [n:nat | n < 2] int n

#define READY 0
#define MOVING 1
  
typedef direction = [n:nat | n < 2] int n

#define UP  0
#define DOWN  1

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

fun {a:t@ype} evict {n:nat | n > 0} (
  q: &queue(a, n, n), x: a,
  cmp: (&a, &a) -<fun1> int, remove: (&a) -<fun1> bool
) : void = let
  var i : [i:nat] int i
in
  for(i := 0; i < q.cnt; i := i + 1)
    if remove(q.data.[i]) then {
      val () = q.data.[i] := x
      val () = qsort(q.data, q.cnt, cmp)
      val () = break
    }
end

fun {a:t@ype} empty {s,n:nat | n <= s} (
  q: &queue(a, n, s)
) : bool (n == 0) = q.cnt = 0

fun {a:t@ype} full {s,n:nat | n <= s; s > 0} (
  q: &queue(a, n, s)
) : bool (n == s) = q.cnt = q.size

typedef request = $extype_struct "request_t" of {
  direction= direction,
  floor= int,
  onboard= bool
}

typedef ElevatorQueue =
  [n:nat | n <= schedule_size] queue(request, n , schedule_size)

viewtypedef elevator_state =
  $extype_struct "elevator_state_t" of {
    queue= ElevatorQueue,
    current= direction,
    floor= int,
    arrived= bool
  }
  
extern
fun state() : [l:agz] (global(l), elevator_state @ l | ptr l)
  = "mac#elevator_get_state"

(*** The interface for the elevator controller. ***)

fun current_direction () : direction = d where {
  val (free, pf | p) = state()
  val d = p->current
  prval () = return_global(free, pf)
}

fun current_floor () : int = fl where {
  val (free, pf | p) = state()
  val fl = p->floor
  prval () = return_global(free, pf)
}

fun has_request() : bool = ~clr where {
  val (free, pf | p) = state()
  val clr =  empty(p->queue)
  prval () = return_global(free, pf)
}

fun new_direction (r: &request) : bool =
  if r.onboard then
    case+ current_direction() of
      | UP => r.floor < current_floor()
      | DOWN => r.floor > current_floor()
  else
    r.direction != current_direction()

fun switch_direction () : void = {
  val (free, pf | p) = state()
  val () =  p->current := neg_direction(p->current)
  prval () = return_global(free, pf)
}

fun add_request(r: request) : void = let
    // Need a better way to express this...
    fun cmp (a: &request, b: &request) : int = let
      val dir = current_direction()
    in
      if a.onboard && b.onboard ||
         (~a.onboard && ~a.onboard &&
          a.direction = b.direction) then
        case+ dir of
        | UP => b.floor - a.floor
        | DOWN => a.floor - b.floor
      else if a.onboard && ~b.onboard then
        if ~new_direction(a) && ~new_direction(b) then
          case+ dir of
            | UP => b.floor - a.floor
            | DOWN => a.floor - b.floor
        else if new_direction(a) then ~1 else 1
      else if ~a.onboard && b.onboard then
        if ~new_direction(a) && ~new_direction(b) then
          case+ dir of
            | UP => b.floor - a.floor
            | DOWN => a.floor - b.floor
        else
          if new_direction(b) then 1 else ~1
      else
        if a.direction = dir then 1 else ~1
    end
    val (free, pf | p) = state()
    val q = &p->queue
  in
    if full(!q) then
        if r.onboard then {
          fun remove (r: &request) : bool =
            ~r.onboard
          val () = evict<request>(!q, r, cmp, remove)
          prval () = return_global(free, pf)
        } else {
          prval () = return_global(free, pf)
        }
    else {
      val () = enqueue<request>(!q, r, cmp)
      prval () = return_global(free, pf)
    }
  end
  
fun next_request() : request = let
  val (free, pf | p) = state()
  val q = &p->queue
  var x : request
in
  x where {
    val () =
      if ~empty(!q) then {
        val () = dequeue<request>(!q, x)
        prval () = return_global(free, pf)
      } else {
        val () = x.direction := 0
        val () = x.floor := ~1
        val () = x.onboard := false
        prval () = return_global(free, pf)
      }
  }
end

fun send_command (r: request) : void = 
  println!("floor",r.floor)
  
fun arrived () : bool = a where {
  val (free, pf | p) = state()
  val a = p->arrived
  prval () = return_global(free, pf)
}

fun set_arrived(b: bool) : void = {
  val (free, pf | p) = state()
  val () = p->arrived := b
  prval () = return_global(free, pf)
}

(* ****** ****** *)

fun new_message {n,p:pos | n <= p} (
  pf: !INT_CLEAR | f: &($FIFO.fifo(char, n, p)) >> $FIFO.fifo(char, n', p)
) : #[n':nat | n' <= p] void = let
  var eol : char
  val () = $FIFO.peek_tail<char>(pf | f, eol)
in
  if eol = '\r' then let
    var cmd : char
    val () = $FIFO.remove(pf | f, cmd)
    fun fifo_atoi {n,p:pos | n <= p} (
      pf: !INT_CLEAR | f: &($FIFO.fifo(char, n, p))
        >> $FIFO.fifo(char, 0, p), res: int
    ) : int = let
      var tmp: char
      val () = $FIFO.remove<char>(pf | f, tmp)
      val res =
        if isdigit((int)tmp) then
          res*10 + ((int)tmp - 0x30)
        else
          res
    in
      if $FIFO.empty<char>(pf | f) then
        res
      else 
        fifo_atoi(pf | f, res)
    end
  in
    if $FIFO.empty(pf | f) then
      ()
    else let
      val value = fifo_atoi(pf | f, 0)
      var tmp : request
      val () = tmp.floor := value
      val () = tmp.onboard := false
      val () = tmp.direction := UP
    in
      case+ cmd of
        | 'u' => {
          val () = tmp.direction := UP
          val () = add_request(tmp)
        }
        | 'd' => {
          val () = tmp.direction := DOWN
          val () = add_request(tmp)
        }
        | 'r' => {
          val () = tmp.direction := UP
          val () = tmp.onboard := true
          val () = add_request(tmp)
        }
        | 'a' => {
          val (free, pf | p) = state()
          val () = p->arrived := true
          val () = p->floor := value
          prval () = return_global(free, pf)
        }
        | _ => ()
    end
  end
end

(* ****** ****** *)

//Initialize the size of the queue
val (free, pf | p) = state()
val () = p->queue.size := 10
prval () = return_global(free, pf)

(* ****** ****** *)

implement main (clr | (**)) = {
  //enable communication
  val () = $USART.atmega328p_async_init(clr | 9600, new_message)
  val (set | ()) = sei(clr | (**))
//
  val (pf0 | ()) = loop(set | READY) where {
    fun loop(set:INT_SET | s: control_state) : (INT_CLEAR | void) =
      case+ s of
        | READY => let
          in
            if has_request() then let
              val next = next_request()
              val () =
                if new_direction(next) then
                  switch_direction()
              val () = send_command(next)
            in loop(set | MOVING) end
            else let
              val () = sleep_enable()
              val () = sleep_cpu()
              val () = sleep_disable()
            in loop(set | s) end
          end
        | MOVING =>
          if arrived() then let
            val () = set_arrived(false)
          in loop(set | READY) end
          else let
            val () = sleep_enable()
            val () = sleep_cpu()
            val () = sleep_disable()
          in loop(set | s) end
  }
  prval () = clr := pf0
}