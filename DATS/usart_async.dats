#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
declare_isr(USART_RX_vect);
declare_isr(USART_TX_vect);

static cycbuf_t read = {0, 0, 0, 25, {[0 ... 24] = 0}};
static cycbuf_t write = {0, 0, 0, 25, {[0 ... 24] = 0}};

ATSinline()
ats_ptr_type get_read_buffer() {
  return (cycbuf_t *)&read;
}

ATSinline()
ats_ptr_type get_write_buffer() {
  return (cycbuf_t *)&write;
}

%}

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/usart.sats"
staload "SATS/stdio.sats"
staload "SATS/delay.sats"
staload "SATS/fifo.sats"

(* ****** ****** *)

staload "DATS/cycbuf.dats"

(* ****** ****** *)

extern
fun get_read_buffer 
  () : [n,s:nat; l:agz | n < s] (
  global(l), fifo(char, n, s) @ l | ptr l
) = "mac#get_read_buffer"

extern
fun get_write_buffer
  () : [n,s:nat; l:agz | n < s] (
  global(l), fifo(char, n, s) @ l | ptr l
) = "mac#get_write_buffer"

(* ****** ****** *)

implement 
USART_TX_vect (locked | (* *) ) = let
  val (gpf, pf | p) = get_write_buffer()
 in
  if empty(pf | p) then {
    prval () = return_global(gpf, pf)
  } else {
    var tmp : char
    val () = remove<char>(locked, pf | p , tmp)
    val () = setval(UDR0, tmp)
    prval () = return_global(gpf, pf)
  }
end
 
implement
USART_RX_vect (locked | (* *)) = let
  val (gpf, pf | p) = get_read_buffer()
  val full = full(pf | p)
  var contents : char = (char) UDR0
 in
   if full then {
      prval () = return_global(gpf, pf)
   } else {
      	val () = insert<char>(locked, pf | p, contents)
	prval () = return_global(gpf, pf)
   }
 end
 
(* ****** ****** *)

extern
fun redirect_stdio () : void = "redirect_stdio"

(* ****** ****** *)

val F_CPU = $extval(lint, "F_CPU")

(* ****** ****** *)

implement
atmega328p_async_init (locked | baud) = {
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
   fun loop {l:agz} {n, s:nat | n < s} (
      pf0: !INT_SET, g: global(l), pf: fifo(char, n, s) @ l 
        | p: ptr l, c: char
   ) : void = let
      val () = 
        if c = '\n' then {
            val _ = atmega328p_async_tx(pf0 | '\r', stdout_ref)
        }
      val (locked | () ) = cli(pf0 | (* *))
   in
      if full (pf | p) then let
          val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
          prval () = pf0 := enabled
        in loop(pf0, g, pf | p, c) end
      else let
          val () = insert<char>(locked, pf | p, c)
       in
        if bit_is_set(UCSR0A, UDRE0) then {
          var tmp : char
	  val () = remove<char>(locked, pf | p, tmp)
          val (enabled | () ) = sei(locked | (* *))
	  val () = setval(UDR0, tmp)
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
  fun loop {l:agz} {n,s:nat | n < s} (
    pf0: !INT_SET, g: global(l), pf: fifo(char, n, s) @ l | p: ptr l
  ) : char = let
    val (locked | () ) = cli(pf0 | (* *))
  in 
    if empty<char>(pf | p) then let
      val (enabled | () ) = sei_and_sleep_cpu(locked | (* *) )
      prval () = pf0 := enabled
     in loop(pf0, g, pf | p) end
    else let
      var tmp : char
      val () = remove<char>(locked, pf | p, tmp)
      val (enabled | () ) = sei(locked | (* *))
      prval () = return_global(g, pf)
      prval () = pf0 := enabled
    in tmp end
  end
in (int)(loop(pf0, gpf, pf | p)) end

implement
atmega328p_async_flush (pf0 | (* *)) = let
  val (gpf, pf | p) = get_read_buffer()
  fun loop {l:agz} {n, s:nat | n < s} (
    pf0: !INT_SET, g: global(l), pf: fifo(char, n, s) @ l | p: ptr l
  ) : void = let
    //empty stdout first
    val _ = fflush(stdout_ref)
    val (locked | () ) = cli(pf0 | (* *) )
  in 
    if empty<char>(pf | p) then let
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
