(* 
   A basic timer example.
    
   AVRs come with a variable number
   of timers that can be used simultaneously.
   Templates could be of use here. By default,
   a naive interface could be supplied to the 
   programmer for simple scheduling operations,
   but template implementation could allow them
   to modify the actual hardware configuration
   going on behind the scenes.
   
 *)
 
staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
  
%{^
declare_isr(TIMER0_OVF_vect);
%}

implement TIMER0_OVF_vect(locked | (**)) = {
  val () = flipbits(PORTB, PORTB3)
}

implement main (locked | (**)) = {
  val () = clearbits(TCCR0A, WGM01, WGM00)
  val () = clearbits(TCCR0B, WGM02)
  val () = setbits(TCCR0B, CS02, CS00)
  val () = setbits(TIMSK0, TOIE0)
  val () = setbits(DDRB, DDB3)
  val (set | ()) = sei(locked | (**))
  val () = while(true)()
  val () = setbits(PORTB, PORTB3)
  val (pf | ()) = cli(set | (**))
  prval () = locked := pf
}

  
