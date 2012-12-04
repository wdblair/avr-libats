(*
  The start of a bootloader in ATS.
  
  In order for this to work, set the BOOTRST fuse 
  so the MCU starts in the bootloader.
*)

staload "SATS/io.sats"
staload "SATS/usart.sats"
staload "SATS/interrupt.sats"

val application_start = $extval( () -<fun1> void, "0x0000")

fun program_page{n:nat} (page: uint32 n) = {
  val saved = save_interrupts()
  val (clear | ()) = cli(saved)
  // program the page.
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