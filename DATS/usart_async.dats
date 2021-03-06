#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
declare_isr(USART_RX_vect);
declare_isr(USART_TX_vect);

static cycbuf_t statmp0 = {0, 0, 0, 25, {[0 ... 24] = 0}};
static cycbuf_t statmp1 = {0, 0, 0, 25, {[0 ... 24] = 0}};
%}

(* ****** ****** *)

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
    
  fun nop {n,p:pos | n <= p} (
    pf: !INT_CLEAR | f: &fifo(char, n, p) >> fifo(char, n', p)
  ) : #[n' :nat | n' <= p] void = ()
  
  var callback : usart_callback with pfcall = nop
  
  viewdef read = [n,s:nat | n <= s] fifo(char, n, s) @ readbuf
  viewdef write = [n,s:nat | n <= s] fifo(char, n, s) @ writebuf
  viewdef call = usart_callback @ callback
  
  prval readlock = interrupt_lock_new{read}(pfread)
  prval writelock = interrupt_lock_new{write}(pfwrite)
  prval backlock = interrupt_lock_new{call}(pfcall)
in
  val readbuf = @{lock= readlock, p= &readbuf}
  val writebuf = @{lock= writelock, p= &writebuf}
  val callback = @{lock= backlock, p= &callback}
end

(* ****** ****** *)

implement 
USART_TX_vect (locked | (* *)) = let
  val (pf | buf) = lock(locked | writebuf)
 in
  if empty(locked | !buf) then {
    prval () = unlock(locked, writebuf, pf , buf)
  } else {
    var tmp : char
    val () = remove<char>(locked | !buf, tmp)
    val () = setval(UDR0, tmp)
    prval () = unlock(locked, writebuf, pf , buf)
  }
end

implement
USART_RX_vect (locked, read | (* *)) = let
  val (pf | buf) = lock(locked | readbuf)
  var contents : char = read_udr0(read | (**))
 in
   if full(locked | !buf) then {
      prval () = unlock(locked, readbuf, pf, buf)
   } else {
      	val () = insert<char>(locked | !buf, contents)
        val (pfcall | call) = lock(locked | callback)
        val () = !call(locked | !buf)
        prval () = unlock(locked, callback, pfcall, call)
        prval () = unlock(locked, readbuf, pf, buf)
   }
 end
 
(* ****** ****** *)

extern
fun redirect_stdio () : void = "redirect_stdio"

(* ****** ****** *)

local
  fun atmega328p_async_hardware {n:nat} (
    n: uint16 n
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
    val () = atmega328p_async_hardware(baud)
  }

  implement
  atmega328p_async_init_callback(locked | baud, c) = {
    val (pf | call) = lock(locked | callback)
    val () = !call := c
    prval () = unlock(locked, callback, pf, call)
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
      val (pf | buf) = lock(locked | writebuf)
   in
      if full (locked | !buf) then let
          prval () = unlock(locked, writebuf, pf, buf)
          val (enabled | () ) = sleep_cpu(locked | (* *))
          prval () = pf0 := enabled
        in loop(pf0 | c) end
      else let
          val () = insert<char>(locked | !buf, c)
       in
        if bit_is_set(UCSR0A, UDRE0) then {
          var tmp : char
	  val () = remove<char>(locked | !buf, tmp)
          prval () = unlock(locked, writebuf, pf, buf)
          val (enabled | () ) = sei(locked | (* *))
	  val () = setval(UDR0, tmp)
          prval () = pf0 := enabled
	} else {
           prval () = unlock(locked, writebuf, pf, buf)
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
    val (pf | buf) = lock(locked | readbuf)
  in 
    if empty<char>(locked | !buf) then let
      prval () = unlock(locked, readbuf, pf, buf)
      val (enabled | () ) = sleep_cpu(locked | (* *) )
      prval () = pf0 := enabled
     in loop(pf0 | (* *)) end
    else let
      var tmp : char
      val () = remove<char>(locked | !buf, tmp)
      prval () = unlock(locked, readbuf, pf, buf)
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
    val (pf | buf) = lock(locked |  writebuf)
  in
    if empty<char>(locked | !buf) then let
        prval () = unlock(locked, writebuf, pf, buf)
        val (enabled | () ) = sei(locked | (* *))
        prval () = pf0 := enabled
      in  end
    else let
      prval () = unlock(locked, writebuf, pf, buf)
      val (enabled | () ) = sleep_cpu(locked | (* *))
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
