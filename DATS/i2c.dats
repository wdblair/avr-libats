(*
  Both the master and slave interface will go here.
  I think should be alright, the only differences in 
  their interface are values they set to the TWCR register,
  and the ISR routine. In any case, the ISR will need to 
  dispatch to the appropriate routine as we can't have two 
  routines for one interrupt vector.
*)

%{^
declare_isr(TWI_vect);

volatile twi_state_t twi_state;
%}

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

// reg = (addr << TWI_ADR_BITS) | (TRUE << TWI_GEN_BIT)
extern
fun set_address (
  a:twi_address, g:bool
) : void = "mac#set_address"

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
    (pf: !INT_SET | (* *) ) : void = let
      val (locked | ()) = cli(pf | (* *))
      in 
        if twi_transceiver_busy() then let
            val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
            prval () = pf := enabled
          in sleep_until_ready(pf | (* *) ) end
        else let
          val (enabled | () ) = sei(locked | (* *))
          prval () = pf := enabled
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
twi_get_state_info (enabled | (* *) ) = let
  val () = sleep_until_ready(enabled | (* *) )
  val (free, pf | p) = get_twi_state()
  val x = p->state
  prval () = return_global(free, pf)
in x end

implement
twi_last_trans_ok () = let
  val (free, pf | p) = get_twi_state()
  val x = get_last_trans_ok(p->status_reg)
  prval () = return_global(free, pf)
in x end

implement
twi_rx_data_in_buf () = let
  val (free, pf | p) = get_twi_state()
  val x = p->buffer.recvd_size
  prval () = return_global(free, pf)
in x end

implement
twi_start_with_data {n, p} (enabled | msg, size) = let
  val () = sleep_until_ready(enabled | (* *) )
  val (free, pf | p) = get_twi_state()
  //Set the size of the message and copy the buffer
  val () = p->buffer.msg_size := size
  val () = copy_buffer(p->buffer.data, msg, size)
  val () = clear_state()
  prval () = return_global(free, pf)
in enable_twi() end

implement twi_get_data {n,p} (enabled | msg, size) = let
  val () = sleep_until_ready(enabled | (* *))
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

implement twi_start(enabled | (* *)) = let
  val () = sleep_until_ready(enabled | (* *))
  val () = clear_state()
in enable_twi() end

extern
castfn int_of_reg8 (r: reg(8)) : int

extern
castfn uint8_of_uchar (c: uchar) : [n: nat | n < 256] int n

extern
castfn uchar_of_reg8 (r: reg(8)) : uchar

// An interesting problem could be modeling
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
