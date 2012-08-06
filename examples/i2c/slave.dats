(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from Atmel Application Note AVR311
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

#include "HATS/i2c.hats"

%{^

#include <ats/basics.h>

static volatile twi_state_t twi_state;

/*
 Will need to make a simple dispatcher
 since the device may be operating in 
 either master or slave mode and there
 can only be one interrupt assigned to
 this vector.
*/
declare_isr(TWI_vect);

%}

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

(* Interrupts are off by default. *)
extern
fun main_interrupts_disabled 
  (pf: INT_CLEAR | (* *) ) : void = "mainats"

overload main with main_interrupts_disabled

  
extern
fun get_twi_state () : [s,r:nat; l:agz | s <= buff_size; r <= buff_size] (
  global(l), twi_state_t (buff_size, s, r) @ l | ptr l
) = "mac#get_twi_state"

(* ****** ****** *)

// reg = (addr << TWI_ADR_BITS) | (TRUE << TWI_GEN_BIT)
// it's a lot easier to just do this in C
extern
fun set_address (
  a:twi_address, g:bool
) : void = "mac#set_address"

(* ****** ****** *)

implement
twi_slave_init(pf | addr, gen_addr) = begin
  set_address(addr, gen_addr);
  clear_and_setbits(TWCR, TWEN);
end

implement
twi_transceiver_busy () = bit_is_set(TWCR, TWIE)

local
  extern
  castfn uchar_of_uint8 (i: uint8) : uchar

  extern
  castfn uchar_of_reg8 (r: reg(8)) : uchar

  fun sleep_until_ready
    () : void = let
      val (locked | ()) = cli()
      in 
        if twi_transceiver_busy() then let
            val () = sei_and_sleep_cpu(locked | (* *))
          in sleep_until_ready() end
        else let
          val () = sei(locked | (* *))
        in end
      end
      
  fun enable_twi() : void =
    clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)

  fun clear_state () : void = {
    val (free, pf | p) = get_twi_state()
    //Clear the status register
    val () = set_all(p->status_reg, uchar_of_int(0))
    //Clear the state
    val () = p->state := uchar_of_uint8(TWI_NO_STATE)
    prval () = return_global(free, pf)
  }

  fun copy_buffer {d,s:int} {sz:pos | sz <= s; sz <= d} (
    dest: &(@[uchar][d]), src: &(@[uchar][s]), num: int sz
  ) : void = {
    var i : [n:nat] int n;
    val () = 
      for ( i := 0; i < num ; i := i + 1) {
        val () = dest.[i] := src.[i]
      }
  }
  
  fun reset_next_byte () : void = {
    val (free, pf | p) = get_twi_state()
    val () = p->next_byte := 0
    val () = set_all_bytes_sent(p->status_reg, false)
    prval() = return_global(free, pf)
  }
  
  
  fun read_next_byte() : void = {
    val (free, pf | p) = get_twi_state()
    val () = p->buffer.data.[p->next_byte] := uchar_of_reg8(TWDR)
    val () = p->next_byte := p->next_byte + 1
    val () = p->buffer.recvd_size := p->buffer.recvd_size + 1
    val () = set_last_trans_ok(p->status_reg, true)
    val () = enable_twi()
    prval () = return_global(free, pf)
  }
  
  
in

implement 
twi_get_state_info () = let
  val () = sleep_until_ready()
  val (free, pf | p) = get_twi_state()
  val x = p->state
  prval () = return_global(free, pf)
in x end

implement
twi_start_with_data {n,p} (msg, size) = let
  val () = sleep_until_ready()
  val (free, pf | p) = get_twi_state()
  //Set the size of the message and copy the buffer
  val () = p->buffer.msg_size := size
  val () = copy_buffer(p->buffer.data, msg, size)
  val () = clear_state()
  prval () = return_global(free,pf)
in enable_twi() end

implement twi_get_data {n,p} (msg, size) = let
  val () = sleep_until_ready()
  val (free, pf | p) = get_twi_state()
  val lastok = get_last_trans_ok(p->status_reg)
in 
    if get_last_trans_ok(p->status_reg) then let
      val () = copy_buffer(msg, p->buffer.data, size)
      prval () = return_global(free, pf)
     in lastok end
    else let
      prval () = return_global(free, pf)
    in lastok end
end

implement twi_start() = let
  val () = sleep_until_ready()
  val () = clear_state()
in enable_twi() end

extern
castfn int_of_reg8 (r: reg(8)) : int

extern
castfn uint8_of_uchar (c: uchar) : [n: nat | n < 256] int n

extern
castfn uchar_of_reg8 (r: reg(8)) : uchar

// An interesting problem could be using the modeling
// the states the TWI module may be in using props.
implement TWI_vect (pf | (* *)) = let
    val twsr = int_of_reg8(TWSR)
  in
    case+ twsr of
    | TWI_STX_ADR_ACK  => reset_next_byte()
    | TWI_STX_ADR_ACK_M_ARB_LOST => reset_next_byte()
    | TWI_STX_DATA_ACK => let
        val (free,pf | p) = get_twi_state()
        //Send the next byte out for delivery
        val x = p->buffer.data.[p->next_byte]
        val () = setval(TWDR, uint8_of_uchar(x))
      in 
          if p->next_byte < p->buffer.msg_size - 1 then {
            val () = p->next_byte := p->next_byte + 1
            prval () = return_global(free, pf)
            val () = enable_twi()
          } else {
            val () = set_all_bytes_sent(p->status_reg, true)
            prval () = return_global(free, pf)
            val () = enable_twi()
          }
      end
    | TWI_STX_DATA_NACK => let
      val (free, pf | p) = get_twi_state()
      val () =
        if get_all_bytes_sent(p->status_reg) then {
          val () = set_last_trans_ok(p->status_reg, true)
          prval () = return_global(free, pf)
        } else {
          val () = p->state := uchar_of_reg8(TWSR)
          prval () = return_global(free, pf)
        }
     in
      setbits(TWCR, TWEN)
     end
    | TWI_SRX_GEN_ACK => {
        val (free, pf | p) = get_twi_state()
        val () = set_gen_address_call(p->status_reg, true)
        prval () = return_global(free, pf)
      }
    | TWI_SRX_ADR_ACK => {
        val (free, pf | p) = get_twi_state()
        val () = set_rx_data_in_buf(p->status_reg, true)
        val () = p->next_byte := 0
        prval () = return_global(free, pf)
        val () = enable_twi()
     }
    | TWI_SRX_ADR_DATA_ACK => read_next_byte()
    | TWI_SRX_GEN_DATA_ACK => read_next_byte()
      //TWI_SRX_STOP_RESTART , for some reason using the macro causes an error
      //using its value works though...
    | 0xA0 => setbits(TWCR, TWEN)
    | _ => enable_twi()
  end
end

extern
castfn _c(i:int) : uchar

implement main (pf | (* *) ) = let
  val address = 0x2
  val () = twi_slave_init(pf | address, true)
  val () = sei(pf | (* *) )
  val () = twi_start()
  fun loop () : void = let
    var !buf with pfbuf =  @[uchar](_c(0), _c(0), _c(0), _c(0))
    val (locked | ()) = cli()
  in 
    if twi_transceiver_busy() then let
        val () = sei_and_sleep_cpu(locked | (* *) )
      in loop() end
    else let
      val () = sei(locked | (* *))
      val (free, pf | p) = get_twi_state()
     in
      if get_last_trans_ok(p->status_reg) then
          if get_rx_data_in_buf(pf | p) then let
              val _ = twi_get_data(!buf, p->buffer.recvd_size)
              val () = twi_start_with_data(!buf, p->buffer.recvd_size)
              prval () = return_global(free, pf)
            in loop() end
          else let
            val () = twi_start()
            prval () = return_global(free, pf)
          in loop() end
      else let
        prval () = return_global(free, pf)
        in loop() end
     end
  end
// 
in loop() end

%{
int main () {
  mainats();
}
%}