(*
   Runs a stop watch that increments a timer every
   second and sends it to the serial port.
   
   AVRs come with a variable number
   of timers that can be used simultaneously.
   Templates could be of use here. By default,
   a naive interface could be supplied to the 
   programmer for simple scheduling operations,
   but template implementation could allow them
   to modify the actual hardware configuration
   going on behind the scenes without having to
   mess up the interface.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"

staload "SATS/usart.sats"
staload "SATS/timer.sats"
staload "SATS/global.sats"

local
  var seconds : uint with pfseconds = 0u
  viewdef vseconds = uint @ seconds
  
  prval seconds_lock = viewlock_new{vseconds}(pfseconds)
in
  val seconds = @{lock= seconds_lock, p= &seconds}
end

implement main (locked | (**)) = {
  fun tick () : bool = true where {
    val () = print "\b\b\b"
    fun loop (rem: int) : void = ()
    val (pf | sec) = global_get(seconds)
    val () = !sec := !sec + 1u
    val () = print !sec
    prval () = global_return(seconds, pf)
  }
  val () = atmega328p_async_init(locked | 9600)
  val (set | ()) = sei(locked | (**))
  val () = delayed_task0(1ul, tick)
  val () = while(true) {
    val () = sleep_cpu()
  }
  val (pf | ()) = cli(set | (**))
  prval () = locked := pf
}