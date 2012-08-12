
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
declare_isr(USART_RX_vect);
declare_isr(USART_TX_vect);

typedef struct {
  uint8_t w;
  uint8_t r;
  uint8_t n;
  uint8_t size;
  char base[];
} cycbuf_t;

char base[25];

static volatile cycbuf_t read = {0, 0, 0, 25, {[0 ... 24] = 0}};
static volatile cycbuf_t write = {0, 0, 0, 25, {[0 ... 24] = 0}};

ATSinline()
ats_ptr_type get_read_buffer() {
  return (cycbuf_t * volatile)&read;
}

ATSinline()
ats_ptr_type get_write_buffer() {
  return (cycbuf_t * volatile)&write;
}

%}

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"

viewtypedef cycbuf_array (a:t@ype, n:int, s: int, w: int, r: int)
  = $extype_struct "cycbuf_t" of {
      w = int w,
      r = int r,
      n = int n,
      size = int s,
      base = @[a][s]
}

viewtypedef cycbuf (a:t@ype, n:int) =
  [s,w,r:nat | n <= s; w < s; r < s] cycbuf_array(a,n,s,w,r)

extern
fun get_read_buffer 
  () : [s:pos; n:nat; l:agz] (
  global(l), cycbuf(char, n) @ l | ptr l
) = "mac#get_read_buffer"
        
extern
fun get_write_buffer
  () : [s:pos; n:nat; l:agz] (
  global(l), cycbuf(char,n) @ l | ptr l
) = "mac#get_write_buffer"

fun {a:t@ype} cycbuf_insert {l:agz} {s:pos} {n:nat | n < s} 
    {w, r: nat | n < s; w < s; r < s} (
    lpf: !INT_CLEAR,
    pf: !cycbuf_array(a, n, s, w, r) @ l >> cycbuf_array(a, n+1, s, w', r) @ l | 
    p: ptr l, x: a
) : #[w':nat | w' < s] void = let 
    val () = p->n := p->n + 1
    val () = p->base.[p->w] := x
  in
    p->w := (p->w + 1) nmod1 p->size
  end
  
//The dereference becomes this below, doesn't seem right...
//(ats_char_type*)(((((cycbuf_t*)(arg0)))->base[0]))[tmp12]

fun {a:t@ype} cycbuf_remove {l:agz} {s,n:pos}
    {w,r:nat | n <= s; w < s; r < s} (
    lpf: !INT_CLEAR,
    pf: !cycbuf_array(a, n, s, w, r) @ l >> cycbuf_array(a, n-1, s, w, r') @ l | 
    p: ptr l, x: &a? >> a
) : #[r':nat | r' < s] void = let
    val () = p->n := p->n - 1
    val () = x := p->base.[p->r]
  in
    p->r := (p->r + 1) nmod1 p->size
  end

fun {a:t@ype} cycbuf_is_empty {l:addr} {n:nat} (
    pf: !cycbuf(a,n) @ l | p: ptr l
) : bool(n == 0) = p->n = 0

fun {a:t@ype} cycbuf_is_full {l:agz} {s:pos}
      {n,w,r:nat | n <= s; w < s; r < s} (
    pf: !cycbuf_array(a,n,s,w,r) @ l | p: ptr l
) : bool(n >= s) = p->size <= p->n

(* ****** ****** *)

extern
castfn char_of_reg(r:reg(8)) : char

extern
castfn uint8_of_char(c:char) : natLt(256)

(* ****** ****** *)

implement 
USART_TX_vect (locked | (* *) ) = let
  val (gpf, pf | p) = get_write_buffer()
 in 
  if cycbuf_is_empty<char>(pf | p) then {
     prval () = return_global(gpf, pf)
  } else {
   var tmp : char
   val () = cycbuf_remove<char>(locked, pf | p ,tmp)
   val () = setval(UDR0, uint8_of_char(tmp))
   prval () = return_global(gpf, pf)
  }
 end

implement
USART_RX_vect (locked | (* *)) = let
  val contents = char_of_reg(UDR0)
  val (gpf, pf | p) = get_read_buffer()
  val full = cycbuf_is_full<char>(pf | p)
 in
   if full then {
      val () = flipbits(PORTB, PORTB3)
      prval () = return_global(gpf, pf)
   } else {
      	val () = cycbuf_insert<char>(locked, pf | p, contents)
	prval () = return_global(gpf, pf)
   }
 end

(* ****** ****** *)

extern
fun redirect_stdio () : void = "redirect_stdio"

extern
fun atmega328p_async_tx 
  (pf: !INT_SET | c:char, f:FILEref) : int = "atmega328p_async_tx"

extern
fun atmega328p_async_rx 
  (pf: !INT_SET | f:FILEref) : int = "atmega328p_async_rx"

(* ****** ****** *)

val F_CPU = $extval(lint, "F_CPU")

(* ****** ****** *)

extern
castfn uint16_of_long (x: lint) : uint16

extern
castfn uint8_of_uint16 (x: uint16) : [n: nat | n < 256] int n

extern
castfn int216 (x:int) : uint16

extern
castfn int2eight(x:int) : [n:nat | n < 256] int n

implement
atmega328p_async_init (locked | baud ) = {
  val ubrr = ubrr_of_baud(baud)
  val () = set_regs_to_int(UBRR0H, UBRR0L, ubrr_of_baud(baud))
  //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
  val () = setbits(UCSR0C, UCSZ01, UCSZ00)
  //Enable TX and RX and interrupts
  val () = setbits(UCSR0B, RXEN0, TXEN0, RXCIE0, TXCIE0)
  //Enable the standard library
  val () = redirect_stdio()
}

 
implement
atmega328p_async_tx (pf0 | c, f) = 0 where {
   val (gpf, pf | p) = get_write_buffer()
   fun loop {l:agz} {n:nat} ( 
      pf0: !INT_SET, g: global(l), pf: cycbuf(char, n) @ l | p: ptr l, c: char
   ) : void = let
      val (locked | () ) = cli(pf0 | (* *))
   in
      if cycbuf_is_full (pf | p) then let
          val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
          prval () = pf0 := enabled
        in loop(pf0, g, pf | p, c) end
      else let
          val () = cycbuf_insert<char>(locked, pf | p, c)
       in
        if bit_is_clear(UCSR0A, UDRE0) then {
          var tmp : char
	  val () = cycbuf_remove<char>(locked, pf | p, tmp)
          val (enabled | () ) = sei(locked | (* *))
	  val () = setval(UDR0, uint8_of_char(tmp))
          prval () = return_global(g, pf)
          prval () = pf0 := enabled
	} else {
           prval () = return_global(g, pf)
           val (enabled | ()) = sei(locked | (* *))
           prval () = pf0 := enabled
        }
       end
   end
   val () = loop(pf0, gpf, pf | p, c)
}

implement
atmega328p_async_rx (pf0 | f) = let
  val (gpf, pf | p) = get_read_buffer()
  fun loop {l:agz} {n:nat} (
    pf0: !INT_SET, g: global(l), pf: cycbuf(char,n) @ l | p: ptr l
  ) : char = let
    val (locked | () ) = cli(pf0 | (* *))
  in 
    if cycbuf_is_empty<char>(pf | p) then let
      val (enabled | () ) = sei_and_sleep_cpu(locked | (* *) )
      prval () = pf0 := enabled
     in loop(pf0, g, pf | p) end
    else let
      var tmp : char
      val () = cycbuf_remove<char>(locked, pf | p, tmp)
      val (enabled | () ) = sei(locked | (* *))
      prval () = return_global(g, pf)
      prval () = pf0 := enabled
    in tmp end
  end
in int_of_char( loop(pf0, gpf, pf | p) ) end

implement
atmega328p_async_flush (pf0 | (* *)) = let
  val (gpf, pf | p) = get_read_buffer()
  fun loop {l:agz} {n:nat} (
    pf0: !INT_SET, g: global(l), pf: cycbuf(char, n) @ l | p: ptr l
  ) : void = let
    //empty stdout first
    val _ = fflush(stdout_ref)
    val (locked | () ) = cli(pf0 | (* *) )
  in 
    if cycbuf_is_empty<char>(pf | p) then let
        val (enabled | () ) = sei(locked | (* *))
        prval () = return_global(g, pf)
        prval () = pf0 := enabled
      in  end
    else let
      val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
      prval () = pf0 := enabled
     in loop(pf0, g, pf | p) end
  end
in loop(pf0, gpf, pf | p) end

(* ****** ****** *)

%{
static FILE mystdio =
  FDEV_SETUP_STREAM((int(*)(char,FILE*))atmega328p_async_tx,
                    (int(*)(FILE*))atmega328p_async_rx,
                    _FDEV_SETUP_RW
                    );

ats_void_type redirect_stdio() {
  stdin = &mystdio;
  stdout = &mystdio;
}
%}
