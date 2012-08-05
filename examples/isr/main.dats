(*
    An example of replacing stdio routines with an
    interrupt based solution for tx and rx.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include <ats/basics.h>

%}

staload "libc/SATS/stdio.sats"

staload "SATS/interrupt.sats"
staload "SATS/usart.sats"

(* ****** ****** *)

implement main (locked | (* *) ) = let
  val () = atmega328p_async_init(locked | uint16_of_int(9800))
  val () = sei(locked | (* *) )
  fun loop () : void = let
      val c = char_of_int(getchar())
      val () =
	case+ c of 
	| _ when c = 'x' => println! "Temperature Read!"
	| _ when c = 'y' => println! "Accelerometer Read!"
	| _ when c = 'f' => println! "Message Sent!"
	| _ => println! "Error"
      in
	loop()
      end
  in loop() end