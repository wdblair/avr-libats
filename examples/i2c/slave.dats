(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from Atmel Application Note AVR311.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#include "ats/basics.h"

extern volatile twi_state_t twi_state;
%}

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

implement main (pf0 | (* *) ) = let
  val address = 0x2
  val () = twi_slave_init(pf0 | address, true)
  val (pf1 | () ) = sei(pf0 | (* *) )
  val () = twi_start(pf1 | (* *))
  fun loop (enabled: INT_SET | (* *) ) : (INT_CLEAR | void) = let
    var !buf with pfbuf =  @[uchar][4](_c(0))
    val (locked | ()) = cli(enabled | (* *))
  in 
    if twi_transceiver_busy() then let
        val (enabled | () ) = sei_and_sleep_cpu(locked | (* *) )
      in loop(enabled | (* *)) end
    else let
      val (enabled | () ) = sei(locked | (* *))
      val (free, pf | p) = get_twi_state()
     in
      if get_last_trans_ok(p->status_reg) then
          if get_rx_data_in_buf(pf | p) then let
              val _ = twi_get_data(enabled | !buf, p->buffer.recvd_size)
              val () = twi_start_with_data(enabled | !buf, p->buffer.recvd_size)
              prval () = return_global(free, pf)
            in loop(enabled | (* *) ) end
          else let
            val () = twi_start(enabled | (* *))
            prval () = return_global(free, pf)
          in loop(enabled | (* *) ) end
      else let
        prval () = return_global(free, pf)
        in loop(enabled | (* *)) end
     end
  end
  //loop never completes, but preserve pf0
  val (pf1 | () ) = loop(pf1 | (* *))
in pf0 := pf1 end
