(*
  An example of an interrupt driven
  i2c master device.
  
  Constantly sends a byte, then requests a byte.
*)

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"
staload "SATS/char.sats"
staload USART = "SATS/usart.sats"
staload "SATS/stdio.sats"

(* ****** ****** *)

#define REQUEST  0x0
#define SEND     0x1
#define READ     0x2

typedef status = [n:nat | n <= 2] int n

(* ****** ****** *)

extern
castfn _c(i:int) : uchar

extern
castfn uint8_of_int(i:int) : uint8
  
implement main (pf0 | (* *) ) = {
  var operation : int = SEND
  val () = $USART.atmega328p_init(uint16_of_int(9600))
  val () = setbits(DDRB, DDB3)
  //TODO: Generate TWBR from a frequency, maybe offer a couple of options.
  val () = twi_master_init(pf0 |  uint8_of_int(0x5C))
  val (set | ()) = sei(pf0 | (* *))
  (*
    Save this for later, just get hello world working...
  fun loop (pf: INT_SET | s: &status) : (
   INT_CLEAR | void
  ) = let
    var !buf = @[uchar][4](_c(0))
  in
    case+ s of
    | REQUEST => let
        val () = setup_addr_byte(!buf, 0x2, true)
        val () = twi_start_with_data(pf | !buf, 2)
        val () = println! 'r'
        val () = s := READ
      in loop(pf | s) end
    | SEND => let
        //Wait for a command
        val _ = getchar()
        val () = setup_addr_byte(!buf, 0x2, false)
        val () = !buf.[1] := uchar_of_char('i')
        val () = twi_start_with_data(pf | !buf, 2)
        val () = println! 's'
        val () = s := SEND
      in loop(pf | s) end
    | READ => let
        val ok = twi_get_data(pf | !buf, 2)
        val () =
          if ok then let
              val c = char_of_uchar(!buf.[1])
            in
              println! c
            end
          else
            println! "Error"
        val () = s := SEND
      in loop(pf | s) end
  end
  *)
  var !buf = @[uchar][4](_c(0))
  val _ = getchar() //I forgot that getchar() puts the MCU to sleep...
  //If not configured currectly, TWI_vect won't wake up the processor....
  val () = println! 's'
  val () = setup_addr_byte(!buf, 0x2, false)
  val () = !buf.[1] := uchar_of_char('h')
  val () = twi_start_with_data(set | !buf, 2)
  val () = loop() where {
    fun loop () : void = loop()
  }
  val (pf | () ) = cli(set | (* *))
 // val (locked | ()) = loop(set | operation)
  prval () = pf0 := pf
}