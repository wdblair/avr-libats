(*
  A working elevator controller.
  
  The device is notified via the serial port
  of events (requests, current floor, closing of
  the door), and sends commands over the same
  line to move to different floors and open doors.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/global.sats"
staload "SATS/sleep.sats"

staload "SATS/stdlib.sats"
staload "SATS/stdio.sats"

staload FIFO = "SATS/fifo.sats"
staload USART = "SATS/usart.sats"

(* ****** ****** *)

staload _ = "DATS/usart_async.dats"
staload _ = "DATS/stdlib.dats"

(* ****** ****** *)


(*
 General rule: make schedule size MAX_FLOOR * 2
 Each floor can have two requests (up/down)
 at any point in time.
*)
#define SCHEDULE_SIZE 20

stadef schedule_size = SCHEDULE_SIZE

(* ****** ****** *)

%{^
#define SCHEDULE_SIZE 20

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
  uint8_t closed;
} elevator_state_t;
%}

typedef control_state = [n:nat | n < 3] int n

#define READY 0
#define WAITING 1
#define MOVING 2

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
  
viewtypedef request = $extype_struct "request_t" of {
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
    arrived= bool,
    closed= bool
  }
  
local
  fun init(
    state: &elevator_state? >> elevator_state
  ) : void = {
    extern
    praxi proof_init (
      s: &elevator_state? >> elevator_state
    ) : void
    prval () = proof_init(state)
    val () = state.queue.size := SCHEDULE_SIZE 
  }
  
  var state : elevator_state with pfstate
  
  val () = init(state)
  
  viewdef vstate = elevator_state @ state
in
  val state = &state
  prval state_lock = lock_new{vstate}(pfstate)
end

fun {a:t@ype} enqueue {n, sz:nat | n < sz} (
  locked: !INT_CLEAR | q: &queue(a, n, sz) >> queue(a, n+1, sz),
  x: a, cmp: (!INT_CLEAR | &a, &a) -<fun1> int
) : void = {
  val () = q.data.[q.cnt] := x
  val () = q.cnt := q.cnt + 1
  val () = qsort_sync(locked | q.data, q.cnt, cmp)
}

fun {a:t@ype} dequeue {n, sz:nat | n > 0; n <= sz} (
  locked: !INT_CLEAR | q: &queue(a, n, sz) >> queue(a, n-1, sz),
  x: &a? >> a, cmp: (!INT_CLEAR | &a, &a) -<fun1> int
) : void = {
  val () = qsort_sync(locked | q.data, q.cnt, cmp)
  val () = x := q.data.[q.cnt - 1]
  val () = q.cnt := q.cnt - 1
}

fun {a:t@ype} evict {n:nat | n > 0} (
  locked: !INT_CLEAR | q: &queue(a, n, n), x: a,
  cmp: (!INT_CLEAR | &a, &a) -<fun1> int, remove: (&a) -<fun1> bool
) : void = let
  var i : [i:nat] int i
in
  for(i := 0; i < q.cnt; i := i + 1)
    if remove(q.data.[i]) then {
      val () = q.data.[i] := x
      val () = qsort_sync(locked | q.data, q.cnt, cmp)
      val () = break
    }
end

fun {a:t@ype} contains {n, sz:nat | n <= sz} (
  locked: !INT_CLEAR | q: &queue(a, n, sz), needle: a,
  eq: (a,a) -<fun1> bool
) : bool = b where {
  var i : [n:nat] int n
  var b : bool = false
  val () = 
    for (i := 0; i < q.cnt; i := i + 1)
      if eq(q.data.[i], needle) then {
        val () = b := true
        val () = break
      }
}

fun {a:t@ype} empty {s,n:nat | n <= s} (
  locked: !INT_CLEAR | q: &queue(a, n, s)
) : bool (n == 0) = q.cnt = 0

fun {a:t@ype} full {s,n:nat | n <= s; s > 0} (
  locked: !INT_CLEAR | q: &queue(a, n, s)
) : bool (n == s) = q.cnt = q.size

typedef cmd_id = [n:nat | n < 2] int n

viewtypedef command = @{
  id= char,
  value= int
}

(*** The interface for the elevator controller. ***)

fun current_direction (locked: !INT_CLEAR | (**)) : direction = d where {
  prval (pf) = lock(locked, state_lock)
  val d = state->current
  prval () = unlock(locked, state_lock, pf)
}

fun current_floor (locked: !INT_CLEAR | (**)) : int = fl where {
  prval (pf) = lock(locked, state_lock)
  val fl = state->floor
  prval () = unlock(locked, state_lock, pf)
}

fun has_request(locked: !INT_CLEAR | (* *)) : bool = ~clr where {
  prval (pf) = lock(locked, state_lock)
  val clr =  empty(locked | state->queue)
  prval () = unlock(locked, state_lock, pf)
}

fun new_direction (locked: !INT_CLEAR | r: &request) : bool =
  if r.onboard then
    case+ current_direction(locked | (**)) of
      | UP => r.floor < current_floor(locked | (**))
      | DOWN => r.floor > current_floor(locked | (**))
  else
    r.direction != current_direction(locked |(**))

fun switch_direction (locked: !INT_CLEAR | (**)) : void = {
  prval (pf) = lock(locked, state_lock)
  val () =  state->current := neg_direction(state->current)
  prval () = unlock(locked, state_lock, pf)
}

fun direction(locked: !INT_CLEAR | r: !request) : direction = 
  if r.onboard then
    if r.floor > current_floor(locked | (**)) then
      UP
    else
      DOWN
  else 
    r.direction
    
(* The main scheduling logic for requests. *)
fun compare (locked: !INT_CLEAR |
      a: &request, b: &request
) : int = let
  fun elevator_direction(locked: !INT_CLEAR |
    r: !request
  ) : direction =
    if r.floor > current_floor(locked | (**)) then
      UP
    else
      DOWN
  val adir = elevator_direction(locked | a)
  val bdir = elevator_direction(locked | b)
in
  if adir != bdir then
    if adir = current_direction(locked | (**)) then
      1
    else
      ~1
  else let 
    val adir = direction(locked | a)
    val bdir = direction(locked | b)
  in
    if adir != bdir then
      if adir = current_direction(locked | (**))then
        1
      else
        ~1
    else
      case+ adir of
        | UP => b.floor - a.floor
        | DOWN => a.floor - b.floor
  end
end

fun add_request(locked: !INT_CLEAR | r: request) : void = let
    prval (pf) = lock(locked, state_lock)
    val q = &state->queue
    //Test if two requests are equal
    fun eq(
      a: request, b: request
    ) : bool =
      ((a.onboard && a.onboard = b.onboard)
        || a.direction = b.direction)
      && (a.floor = b.floor)
    val dup = contains(locked | !q, r, eq)
  in
    if full(locked | !q) then
        if r.onboard then {
          fun remove (r: &request) : bool =
            ~r.onboard
          val () = evict<request>(locked | !q, r, compare, remove)
          prval () = unlock(locked, state_lock, pf)
        } else {
          prval () = unlock(locked, state_lock, pf)
        }
    else if dup then {
      prval () = unlock(locked, state_lock, pf)
    } else {
      val () = enqueue<request>(locked | !q, r, compare)
      prval () = unlock(locked, state_lock, pf)
    }
  end
  
fun next_request(locked: !INT_CLEAR | (**)) : request = let
  prval (pf) = lock(locked, state_lock)
  val q = &state->queue
  var x : request
in
  x where {
    val () =
      if ~empty(locked | !q) then {
        val () = dequeue<request>(locked | !q, x, compare)
        prval () = unlock(locked, state_lock, pf)
      } else {
        val () = x.direction := 0
        val () = x.floor := ~1
        val () = x.onboard := false
        prval () = unlock(locked, state_lock, pf)
      }
  }
end

fun send_command (locked: !INT_CLEAR | c: command): void =
  println!(c.id, c.value)
  
fun arrived (locked: !INT_CLEAR | (**)) : bool = a where {
  prval (pf) = lock(locked, state_lock)
  val a = state->arrived
  prval () = unlock(locked, state_lock, pf)
}

fun set_arrived(locked: !INT_CLEAR | b: bool) : void = {
  prval (pf) = lock(locked, state_lock)
  val () = state->arrived := b
  prval () = unlock(locked, state_lock, pf)
}

fun closed (locked: !INT_CLEAR | (**)) : bool = b where {
  prval (pf) = lock(locked, state_lock)
  val b = state->closed
  prval () = unlock(locked, state_lock, pf)
}

(* ****** ****** *)

fun new_message {n,p:pos | n <= p} (
  locked: !INT_CLEAR |
  f: &($FIFO.fifo(char, n, p)) >> $FIFO.fifo(char, n', p)
) : #[n':nat | n' <= p] void = let
  var eol : char
  val () = $FIFO.peek_tail<char>(locked | f, eol)
in
  if eol = '\r' then let
    var cmd : char
    val () = $FIFO.remove(locked | f, cmd)
    fun fifo_atoi {n,p:pos | n <= p} (
      locked: !INT_CLEAR | f: &($FIFO.fifo(char, n, p))
        >> $FIFO.fifo(char, 0, p), res: int
    ) : int = let
      var tmp: char
      val () = $FIFO.remove<char>(locked | f, tmp)
      val res =
        if isdigit((int)tmp) then
          res*10 + ((int)tmp - 0x30)
        else
          res
    in
      if $FIFO.empty<char>(locked | f) then
        res
      else
        fifo_atoi(locked | f, res)
    end
  in
    if $FIFO.empty(locked | f) then
      ()
    else let
      val value = fifo_atoi(locked | f, 0)
      var tmp : request
      val () = tmp.floor := value
      val () = tmp.onboard := false
      val () = tmp.direction := UP
    in
      case+ cmd of
        | 'u' => {
          val () = tmp.direction := UP
          val () = add_request(locked | tmp)
        }
        | 'd' => {
          val () = tmp.direction := DOWN
          val () = add_request(locked | tmp)
        }
        | 'r' => {
          val () = tmp.direction := UP
          val () = tmp.onboard := true
          val () = add_request(locked | tmp)
        }
        | 'a' => {
          prval (pf) = lock(locked, state_lock)
          val () = state->arrived := true
          val () = state->floor := value
          val () = state->closed := false
          prval () = unlock(locked, state_lock, pf)
        }
        | 'c' => {
          prval (pf) = lock(locked, state_lock)
          val () = state->closed := true
          prval () = unlock(locked, state_lock, pf)
        }
        | _ => ()
    end
  end
end

(* ****** ****** *)

implement main (clr | (**)) = {
  //enable communication
  val () = $USART.atmega328p_async_init(clr | 9600, new_message)
  val (set | ()) = sei(clr | (**))
  //
  val (pf0 | ()) = loop(set | READY) where {
    fun loop(set:INT_SET | s: control_state) : (INT_CLEAR | void) = let
        val (locked | ()) = cli(set | (**))
    in
      case+ s of
        | READY =>
            if has_request(locked | (**)) then let
              val next = next_request(locked | (**))
              val () =
                if new_direction(locked | next) then
                  switch_direction(locked | (**))
              val () =
                send_command(locked | @{id= 'f',value= next.floor})
              val (set | ()) = sei(locked | (**))
            in loop(set | MOVING) end
            else let
              val (set | ()) = sei_and_sleep_cpu(locked | (**))
            in loop(set | s) end
        | WAITING =>
          if closed(locked | (**)) then let
            val (set | ()) = sei(locked | (**))
          in loop(set | READY) end
          else let
            val (set | ()) = sei_and_sleep_cpu(locked | (**))
          in loop(set | WAITING) end
        | MOVING =>
          if arrived(locked | (**)) then let
            val () = set_arrived(locked | false)
            val () = send_command (locked | 
              @{id= 'o', value= current_direction(locked | (**))}
            )
            val (set | ()) = sei(locked | (**))
          in loop(set | WAITING) end
          else let
            val (set | ()) = sei_and_sleep_cpu(locked | (**))
          in loop(set | s) end
    end
  }
  prval () = clr := pf0
}