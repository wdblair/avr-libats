#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
declare_isr(USART_RX_vect);
declare_isr(USART_TX_vect);

static cycbuf_t statmp0 = {0, 0, 0, 25, {[0 ... 24] = 0}};
static cycbuf_t statmp1 = {0, 0, 0, 25, {[0 ... 24] = 0}};

static ats_ptr_type callback;

ATSinline()
ats_ptr_type get_callback (){
  return callback;
 }

ATSinline()
ats_void_type set_callback(ats_ptr_type c){
  callback = c;
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

local  
  //Interesting error, I need to use the ATS 
  //naming convention for these variables.
  var readbuf : fifo(char, 0, 25) with pfread = 
    $extval(fifo(char, 0, 25), "statmp0")
  var writebuf : fifo(char, 0, 25) with pfwrite = 
    $extval(fifo(char, 0, 25), "statmp1")
    
  viewdef read = [n,s:nat | n <= s] fifo(char, n, s) @ readbuf
  viewdef write = [n,s:nat | n <= s] fifo(char, n, s) @ writebuf
in
  val readbuf = &readbuf
  val writebuf = &writebuf
  prval gread = lock_new {read} (pfread)
  prval gwrite = lock_new {write} (pfwrite)
end

extern
fun get_callback
  () : usart_callback = "mac#get_callback"

extern
fun set_callback
  (c: usart_callback) : void = "mac#set_callback"
  
(* ****** ****** *)

implement 
USART_TX_vect (locked | (* *)) = let
  prval (pf) = lock(locked, gwrite)
 in
  if empty(locked | !writebuf) then {
    prval () = unlock(locked, gwrite, pf)
  } else {
    var tmp : char
    val () = remove<char>(locked | !writebuf , tmp)
    val () = setval(UDR0, tmp)
    prval () = unlock(locked, gwrite, pf)
  }
end
 
implement
USART_RX_vect (locked | (* *)) = let
  prval (pf) = lock(locked, gread)
  var contents : char = (char) UDR0
 in
   if full(locked | !readbuf) then {
      prval () = unlock(locked, gread, pf)
   } else {
      	val () = insert<char>(locked | !readbuf, contents)
        val call = get_callback()
        val () = call(locked | !readbuf)
        prval () = unlock(locked, gread, pf)
   }
 end
 
(* ****** ****** *)

extern
fun redirect_stdio () : void = "redirect_stdio"

(* ****** ****** *)

val F_CPU = $extval(lint, "F_CPU")

(* ****** ****** *)

local
  fun atmega328p_async_hardware {n:nat | uint16(n)} (
    n: int n
  ) : void = {
    val ubrr = ubrr_of_baud(n)
    val () = set_regs_to_int(UBRR0H, UBRR0L, ubrr)
    //Set mode to asynchronous, no parity bit, 8 bit frame, and 1 stop bit
    val () = setbits(UCSR0C, UCSZ01, UCSZ00)
    //Enable TX and RX and interrupts
    val () = setbits(UCSR0B, RXEN0, TXEN0, RXCIE0, TXCIE0)
    //Enable the standard library
    val () = redirect_stdio()
  }
in

  implement
  atmega328p_async_init_stdio (locked | baud) = {
    fun nop {n,p:pos | n <= p} (
     pf: !INT_CLEAR | f: &fifo(char, n, p) >> fifo(char, n', p)
    ) : #[n':nat | n' <= p] void = ()
    val () = set_callback(nop)
    val () = atmega328p_async_hardware(baud)
  }

  implement
  atmega328p_async_init_callback(locked | baud, callback) = {
    val () = set_callback(callback)
    val () = atmega328p_async_hardware(baud)
  }
end

implement
atmega328p_async_tx (pf0 | c, f) = 0 where {
   fun loop (
      pf0: !INT_SET | c: char
   ) : void = let
      val () =
        if c = '\n' then {
            val _ = atmega328p_async_tx(pf0 | '\r', stdout_ref)
        }
      val (locked | () ) = cli(pf0 | (* *))
      prval (pf) = lock(locked , gwrite)
   in
      if full (locked | !writebuf) then let
          prval () = unlock(locked, gwrite, pf)
          val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
          prval () = pf0 := enabled
        in loop(pf0 | c) end
      else let
          val () = insert<char>(locked | !writebuf, c)
       in
        if bit_is_set(UCSR0A, UDRE0) then {
          var tmp : char
	  val () = remove<char>(locked | !writebuf, tmp)
          prval () = unlock(locked, gwrite, pf)
          val (enabled | () ) = sei(locked | (* *))
	  val () = setval(UDR0, tmp)
          prval () = pf0 := enabled
	} else {
           prval () = unlock(locked, gwrite, pf)
           val (enabled | ()) = sei(locked | (* *))
           prval () = pf0 := enabled
        }
       end
   end
   val () = loop(pf0 | c)
}

implement
atmega328p_async_rx (pf0 | f) = let
  fun loop (
    pf0: !INT_SET | (* *)
  ) : char = let
    val (locked | () ) = cli(pf0 | (* *))
    prval (pf) = lock(locked, gread)
  in 
    if empty<char>(locked | !readbuf) then let
      prval () = unlock(locked, gread, pf)
      val (enabled | () ) = sei_and_sleep_cpu(locked | (* *) )
      prval () = pf0 := enabled
     in loop(pf0 | (* *)) end
    else let
      var tmp : char
      val () = remove<char>(locked | !readbuf, tmp)
      prval () = unlock(locked, gread, pf)
      val (enabled | () ) = sei(locked | (* *))
      prval () = pf0 := enabled
    in tmp end
  end
in (int)(loop(pf0| (* *))) end

implement
atmega328p_async_flush (pf0 | (* *)) = let
  fun loop (
    pf0: !INT_SET | (**)
  ) : void = let
    //empty stdout first
    val _ = fflush(stdout_ref)
    val (locked | () ) = cli(pf0 | (* *))
    prval (pf) = lock(locked, gwrite)
  in
    if empty<char>(locked | !writebuf) then let
        prval () = unlock(locked, gwrite, pf)
        val (enabled | () ) = sei(locked | (* *))
        prval () = pf0 := enabled
      in  end
    else let
      prval () = unlock(locked, gwrite, pf)
      val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
      prval () = pf0 := enabled
     in loop(pf0 | ) end
  end
in loop(pf0 | ) end

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
