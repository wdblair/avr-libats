(*
  The start of a bootloader in ATS.
  
  In order for this to work, set the BOOTRST fuse 
  so the MCU starts in the bootloader.
*)

staload "SATS/io.sats"
staload "SATS/usart.sats"
staload "SATS/interrupt.sats"
staload "SATS/boot.sats"

%{^
#define asl_int1_int1(i,n) i << n
%}

val application_start = $extval( () -<fun1> void, "0x0000")

(* Add these to basics_fixed_int.sats *)
extern
fun asl_uint81_int1
  (i: Uint8, n: Nat) :<> [n:nat] int n = "mac#asl_int1_int1"
  
overload << with asl_uint81_int1  

implement program_page (pf | p, buf) = {
  val saved = save_interrupts()
  val (clear | () ) = cli(saved)
//  
  val () = page_erase(clear | p)
  val () = spm_busy_wait(clear | (**))
//
  (* I can't wait for higher order function templates. *)
  fun loop {l:agz} {n:nat | n <= SPM_PAGESIZE} {p:nat} (
    locked: !INT_CLEAR, buf: !array(Uint8, n, l) |
      p : ptr l, i: int (SPM_PAGESIZE - n), page: uint32 p
  ) : void =
      if i < SPM_PAGESIZE - 1 then {
        prval p0 :: p1 :: arr = buf
        //
        val write = (int)!p
        val write = write + (!(p+sizeof<Uint8>) << 8)
        val () = page_fill(locked | page, (uint16) write)
        //
        val () = loop(locked, arr | p+(2*sizeof<Uint8>), i+2, page)
        prval () = buf := p0 :: p1 :: arr
      }
  val () = loop (clear, pf | buf, 0, p)
  val () = page_write(clear | p)
  val () = spm_busy_wait(clear | (**))
  val () = restore_interrupts(clear | saved)
}

implement main(locked | (**)) =
  if bit_is_set(PORTB, PORTB3) then
    application_start()
  else {
  val () = atmega328p_init(9600)
  val () = while(true)()
  //Jump to the application
  val () = application_start()
}
