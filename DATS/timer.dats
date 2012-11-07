(* Implement a portion of the timer interface. *)

staload "SATS/io.sats"
staload "SATS/timer.sats"
staload "SATS/global.sats"
staload "SATS/interrupt.sats"

%{^
declare_isr(TIMER0_OVF_vect);
%}

local
  fun nop () : bool = false
  
  var timer0 : [n:int] timer n with pftimer0 =
    @{threshold=0u, ticks=0u, task= nop}
    
  viewdef vtimer0 = [n:nat] timer n @ timer0
in
  val timer0 = &timer0
  
  prval gtimer0 = global_new{vtimer0}(pftimer0)
end


implement TIMER0_OVF_vect (locked | (**)) = {
  prval (pf) = global_get(gtimer0)
  val () =
    if timer0->ticks = timer0->threshold then {
      val () = timer0->ticks := 0u
      val _ = timer0->task()
    } else
      timer0->ticks := timer0->ticks + 1u
  prval () = global_return(gtimer0, pf)
}

implement delayed_task0 (
  period, task
) : void = {
  prval (pf) = global_get(gtimer0)
  val () = timer0->ticks := 0u
  val () =
    timer0->threshold := 
      (uint1) ((F_CPU / (1024ul*256ul)) * period)
  val () = timer0->task := task
  prval () = global_return(gtimer0, pf)
  //Configure the hardware.
  val () = clearbits(TCCR0A, WGM01, WGM00)
  val () = clearbits(TCCR0B, WGM02)
  val () = setbits(TCCR0B, CS02, CS00)
  val () = setbits(TIMSK0, TOIE0)
}
