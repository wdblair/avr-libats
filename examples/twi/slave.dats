(*
  An example of an interrupt driven
  i2c slave device.
  
  Adapted from Atmel Application Note AVR311.
*)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload TWI = "SATS/twi.sats"

%{^
static unsigned char information[5] = {'a','b','c','d','e'};

#define set_data(n, c) information[n] = c
#define get_data(n) information[n]
%}

extern
fun set_data {n:nat | n < 5} (
  n:int n, c: uchar
) : void = "mac#set_data"

extern
fun get_data {n:nat | n < 5} (
  n:int n
) : uchar = "mac#get_data"

fun response {n:nat | n <= $TWI.buff_size} (
  src: &(@[uchar][$TWI.buff_size]), sz: int n, m: $TWI.mode
) : void = {
  val curr = (int1)src.[0]
  val () =
    if curr >= 0 && curr < 5 then
      src.[0] := get_data(curr)
    else 
      src.[0] := (uchar) '0'
}

(* ****** ****** *)

implement main (pf0 | (**)) = let
  val address = 0x2
  val (status | ()) =
    $TWI.slave_init(pf0 | address, true)
  val (set | ()) = sei(pf0 | (**))
  val () =
    $TWI.start_server(set, status | response, 2)
  val () = while (true) {
    val () = sleep_enable()
    val () = sleep_cpu()
    val () = sleep_disable()
  }
  val (clear | ()) = cli(set | (**))
in pf0 := clear end
