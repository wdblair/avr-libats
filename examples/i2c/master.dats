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
staload "SATS/usart.sats"

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
  var operation : int = REQUEST
  val () = atmega328p_async_init(pf0 | uint16_of_int(9600))
  //TODO: Generate TWBR from a frequency, maybe offer a couple of options.
  val () = twi_master_init(pf0 |  uint8_of_int(0x5C))
  val (set | ()) = sei(pf0 | (* *))
  fun loop (pf: INT_SET | s: &status) : (
   INT_CLEAR | void
  ) = let
    var !buf = @[uchar][4](_c(0))
  in
    case+ s of
    | REQUEST => let
        val () = setup_addr_byte(!buf, 0x2, true)
        val () = twi_start_with_data(pf | !buf, 2)
        val () = s := READ
      in loop(pf | s) end
    | SEND => let 
        val () = setup_addr_byte(!buf, 0x2, false)
        val () = !buf.[0] := uchar_of_char('i')
        val () = twi_start_with_data(pf | !buf, 2)
        val () = s := REQUEST
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
      in loop(pf | s) end
  end
  val (locked | ()) = loop(set | operation)
  prval () = pf0 := locked
}