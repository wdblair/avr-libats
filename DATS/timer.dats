(* Implement a portion of the timer interface. *)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

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
  prval timerlock0 = interrupt_lock_new{vtimer0}(pftimer0)
in
  val timer0 = @{lock= timerlock0, p= &timer0}
end

implement TIMER0_OVF_vect (locked | (**)) = let
  val (pf | timer) = lock(locked | timer0)
in
    if timer->ticks = timer->threshold then {
      val () = timer->ticks := 0u
      val _ = timer->task()
      prval () = unlock(locked, timer0, pf, timer)
    } else {
      val () = timer->ticks := timer->ticks + 1u
      prval () = unlock(locked, timer0, pf, timer)
    }
end
  
implement delayed_task0 (
  period, task
) : void = {
  val flags = save_interrupts()
  val (locked | ()) = cli(flags)
  val (pf | timer) = lock(locked | timer0)
  val () = timer->ticks := 0u
  val () =
    timer->threshold := 
      (uint1) ((F_CPU / (1024ul*256ul)) * period)
  val () = timer->task := task
  prval () = unlock(locked, timer0, pf, timer)
  //Configure the hardware.
  val () = clearbits(TCCR0A, WGM01, WGM00)
  val () = clearbits(TCCR0B, WGM02)
  val () = setbits(TCCR0B, CS02, CS00)
  val () = setbits(TIMSK0, TOIE0)
  val () = restore_interrupts(locked | flags)
}