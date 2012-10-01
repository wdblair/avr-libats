(*
  TWI Driver To Support Both Master and Slave Operation.

  Taken from Atmel Application Note AVR315 and AVR311
*)

%{^
declare_isr(TWI_vect);

static volatile twi_state_t twi_state;
%}

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/twi.sats"
staload "SATS/stdlib.sats"

(* ****** ****** *)

// reg = (addr << TWI_ADR_BITS) | (TRUE << TWI_GEN_BIT)
extern
fun set_address (
  a:twi_address, g:bool
) : void = "mac#set_address"

extern
fun twbr_of_scl (a: int) : uint8 = "mac#avr_libats_twi_twbr_of_scl"

(* ****** ****** *)

fun enable_twi_master () : void = {
  val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
}

fun enable_twi_slave () : void = {
  val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
  val (gpf, pf | p) = get_twi_state()
  val () = set_busy(p->status_reg, true)
  prval () = return_global(gpf, pf)
}

fun slave_busy () : bool = busy where {
    val (gpf, pf | p) = get_twi_state()
    val busy = get_busy(p->status_reg)
    prval () = return_global(gpf, pf)
}

fun master_busy () : bool = bit_is_set(TWCR, TWIE)

fun enable_pullups () : void = begin
  setbits(DDRC, DDC4, DDC5);
  setbits(PORTC, PORTC4, PORTC5);
end

local

extern
praxi get_ready () : TWI_READY

in 

implement
slave_init(pf | addr, gen_addr) = let
  val () = enable_pullups()
  val () = set_address(addr, gen_addr)
  val () = clear_and_setbits(TWCR, TWEN)
  val (gpf, pf | p) = get_twi_state()
  val () = p->enable := enable_twi_slave
  val () = p->busy := slave_busy
  prval () = return_global(gpf, pf)
  prval pf = get_ready()
in (pf | () ) end

extern
castfn _8(i: uint8) : natLt(256)

implement
master_init(pf | baud ) = let
  val twbr = twbr_of_scl(baud)
  val () = enable_pullups()
  val () = setval(TWBR, _8(twbr))
  val () = setval(TWDR, 0xFF)
  val () = clear_and_setbits(TWCR, TWEN)
  val (gpf, pf | p) = get_twi_state()
  val () = p->enable := enable_twi_master
  val () = p->busy := master_busy
  prval () = return_global(gpf, pf)
  prval pf = get_ready()
in (pf | ()) end

end

(* ****** ****** *)

implement
transceiver_busy () = busy where {
  val (gpf, pf | p) = get_twi_state()
  val busy = p->busy()
  prval () = return_global(gpf, pf)
}

local

  extern
  castfn uint8_of_uchar (c: uchar) : [n: nat | n < 256] int n

  extern
  castfn uchar_of_uint8 (i: uint8) : uchar

  extern
  castfn uchar_of_reg8 (r: reg(8)) : uchar

  fun sleep_until_ready
    (pf: !INT_SET | (* *) ) : void = let
        val (locked | ()) = cli( pf | (* *) )
      in 
        if transceiver_busy () then let
            val (enabled | () ) = sei_and_sleep_cpu(locked | (* *))
            prval () = pf := enabled
          in sleep_until_ready(pf | (* *) ) end
        else let
          val (enabled | () ) = sei(locked | (* *))
          prval () = pf := enabled
        in end
      end

  local
    extern
    praxi get_ready(pf: TWI_BUSY) : TWI_READY
  in
    implement wait (pf, busy | (* *)) = {
      val _ = sleep_until_ready(pf | (* *))
      prval () = busy := get_ready(busy)
    }
  end
  
  fun enable_twi () : void =
    clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
    
  fun clear_state () : void = {
    val (free, pf | p) = get_twi_state()
    //Clear the status register
    val () = set_all(p->status_reg, uchar_of_int(0))
    //Clear the state
    val () = p->state := uchar_of_int(TWI_NO_STATE)
    prval () = return_global(free, pf)
  }
  
  fun copy_buffer {d,s:int} {sz:pos | sz <= s; sz <= d} (
    dest: &(@[uchar][d]), src: &(@[uchar][s]), num: int sz  
  ) : void = {
    var i : [n:nat] int n;
    val () =
      for (i := 0; i < num; i := i + 1) {
        val () = dest.[i] := src.[i]
      }
  }
  
  //The last byte of the current message in reference to the 
  //total buffer.
  fun current_msg_last_byte () :
    [n:nat] int n = sum where {
      val (free, pf | p) = get_twi_state()
      var sum : [s:nat] int s = 0
      var i : [n:nat] int n
      val curr = p->buffer.curr_trans
      val () = for(i := 0; i < curr; i := i + 1) {
        val () = sum := sum + int1_of_uchar(p->buffer.trans.[i])
      }
      prval () = return_global(free, pf)
  }
  
  fun reset_next_byte () : void = {
    val (free, pf | p) = get_twi_state()
    val sum = current_msg_last_byte()
    val () = p->next_byte := sum
    val () = set_all_bytes_sent(p->status_reg, false)
    prval() = return_global(free, pf)
  }
  
  fun copy_recvd_byte () : bool = let
    val (free, pf | p) = get_twi_state()
    val () = p->buffer.data.[p->next_byte] := uchar_of_reg8(TWDR)
    var sum : [b:nat] int b = 0
    var i : [z:nat] int z
    val () = for(i := 0 ; i < p->buffer.curr_trans; i := i + 1) {
      val () = sum := sum + int1_of_uchar(p->buffer.trans.[i])
    }
    val () = p->next_byte := p->next_byte + 1
  in
    if p->next_byte = sum then true where {
      val () = p->buffer.curr_trans := p->buffer.curr_trans + 1
      prval () = return_global(free, pf)
    } else false where {
      prval () = return_global(free, pf)
    }
  end
  
  fun read_next_byte () : void = {
    val restart = copy_recvd_byte()
    val (free, pf | p) = get_twi_state()
    val () = p->buffer.recvd_size := p->buffer.recvd_size + 1
    val () = set_last_trans_ok(p->status_reg, true)
    val () = p->enable()
    prval () = return_global(free, pf)
  }
  
  fun master_transmit_next_byte () : void = let
      val (free, pf | p) = get_twi_state()
  in
      if p->next_byte < p->buffer.msg_size then let //more to send
        val sum = current_msg_last_byte()
      in
          //Reached the end of a message, restart.
          if p->next_byte = sum then {
            val () = p->buffer.curr_trans := p->buffer.curr_trans + 1
            val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
            prval () = return_global(free, pf)
          } else {
              val () = setval(TWDR, uint8_of_uchar(p->buffer.data.[p->next_byte]))
              val () = p->next_byte := p->next_byte + 1
              val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT)
              prval () = return_global (free, pf)
          }
      end
      else { //finished
//        val () = println! "f"
        val () = set_last_trans_ok(p->status_reg, true)
        val () = clear_and_setbits(TWCR, TWEN, TWINT, TWSTO)
        prval () = return_global (free, pf)
      }
  end

  fun slave_transmit_next_byte () : void = let
      val (free, pf | p) = get_twi_state()
      //Send the next byte out for delivery
      val x = p->buffer.data.[p->next_byte]
      val () = setval(TWDR, uint8_of_uchar(x))
      val () = enable_twi_slave()
  in
    if p->next_byte < (p->buffer.msg_size - 1) then {
      val () = p->next_byte := p->next_byte + 1
      prval () = return_global(free, pf)
    } else {
      prval () = return_global(free, pf)
    }
  end
  
  fun detect_last_byte () : void = let
      val (free, pf | p) = get_twi_state()
  in
      if p->next_byte < (p->buffer.msg_size - 1) then {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
        prval () = return_global (free, pf)
      } else {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT)
        prval () = return_global (free, pf)
      }
  end

in

implement
get_state_info (enabled | (* *) ) = let
  val () = sleep_until_ready(enabled | (* *) )
  val (free, pf | p) = get_twi_state()
  val x = p->state
  prval () = return_global(free, pf)
in x end

implement
last_trans_ok (rdy | (* *)) = let
  val (free, pf | p) = get_twi_state()
  val x = get_last_trans_ok(p->status_reg)
  prval () = return_global(free, pf)
in x end

implement
rx_data_in_buf (rdy | (* *)) = let
  val (free, pf | p) = get_twi_state()
  val x = p->buffer.recvd_size
  prval () = return_global(free, pf)
in x end

local

  extern
  praxi get_busy(pf: TWI_READY) : TWI_BUSY

in

implement
start_with_data {n,p} (enabled, rdy | msg, size) = {
  val () = sleep_until_ready(enabled | (* *) )
  val (free, pf | p) = get_twi_state()
  //Set the size of the message and copy the buffer
  val () = p->buffer.msg_size := size
  val () = copy_buffer(p->buffer.data, msg, size)
  val () = clear_state()
  val _ = p->enable()
  prval () = rdy := get_busy(rdy)
  prval () = return_global(free, pf)
}

implement
start_transaction {l} {sum, sz} (enabled, rdy | buf, trans, sum, sz) = {
  val () = sleep_until_ready(enabled | (* *))
  prval origin = snapshot(trans)
  val (free, pf | p) = get_twi_state()
  val () = copy_buffer(p->buffer.data, buf, sum)
  val () = p->buffer.msg_size := sum
  val () = p->buffer.curr_trans := 0
  val () = p->buffer.trans_size := sz
  fun loop  {l1:agz} {s:nat} {n1:pos | s <= buff_size; n1 <= sz} (
      pf: !twi_state_t @ l1 | t: !transaction(l, s, n1, sz) >> 
        transaction(l, s', 0, sz), 
      i: int n1, p: ptr l1
  ) : #[s':nat | s' <= buff_size] void = let
     val nxt = uchar_of_char(char_of_int(get_msg(t)))
     val indx = p->buffer.curr_trans
     val () = p->buffer.trans.[indx] := nxt
     val () =
        if p->buffer.curr_trans < p->buffer.trans_size - 1 then
          p->buffer.curr_trans := p->buffer.curr_trans + 1
  in
    if i - 1 <= 0 then 
      ()
    else 
      loop(pf | t, i - 1, p)
  end
  val () = loop(pf | trans, sz, p)
  val () = p->buffer.curr_trans := 0
  val () = reset(origin | trans)
  val () = clear_state()
  val _ = p->enable()
  prval () = rdy := get_busy(rdy)
  prval () = return_global(free, pf)
}

implement start(enabled, rdy | (* *)) = {
  val () = sleep_until_ready(enabled | (* *))
  val () = clear_state()
  val (gpf, pf | p) = get_twi_state()
  val () = p->enable()
  prval () = rdy := get_busy(rdy)
  prval () = return_global(gpf, pf)
}

end

implement get_data {n, p} (enabled, rdy | msg, size) = let
  val () = sleep_until_ready(enabled | (* *))
  val (free, pf | p) = get_twi_state()
  val lastok = get_last_trans_ok(p->status_reg)
in 
    if lastok then let
      val () = copy_buffer(msg, p->buffer.data, size)
      prval () = return_global(free, pf)
     in lastok end
    else let
      prval () = return_global(free, pf)
    in lastok end
end

extern
castfn int_of_reg8 (r: reg(8)) : [n:nat | n < 256] int n

extern
castfn uchar_of_reg8 (r: reg(8)) : uchar

implement TWI_vect (pf | (* *)) = let
    val twsr = int_of_reg8(TWSR)
    val c =  char_of_uchar(uchar_of_reg8(TWSR))
  in
    case+ twsr of
// Master
    | TWI_START => {
//        val () = println! "st"
        val () = reset_next_byte()
        val () = master_transmit_next_byte()
      }
    | TWI_REP_START => {
//        val () = println! "rp"
        val () = reset_next_byte()
        val () = master_transmit_next_byte()
      }
    | TWI_MTX_ADR_ACK => {
//        val () = println! "tack"
        val () = master_transmit_next_byte()
      }
    | TWI_MTX_DATA_ACK => {
//        val () = println! "tdat"
        val () = master_transmit_next_byte()
      }
    | TWI_MRX_DATA_ACK => {
//        val () = println! "rdat"
        val restart = copy_recvd_byte()
        val () = detect_last_byte()
      }
    | TWI_MRX_ADR_ACK => {
//        val () = println! "rack"
        val () = detect_last_byte()
      }
    | TWI_MRX_DATA_NACK => {
//        val () = println! "rnack"
        val restart = copy_recvd_byte()
        val (free, pf | p) = get_twi_state()
        val () = p->buffer.data.[p->next_byte] := uchar_of_reg8(TWDR)
        val () = set_last_trans_ok(p->status_reg, true)
        val () = clear_and_setbits(TWCR, TWEN, TWINT, TWSTO)
        prval () = return_global (free, pf)
      }
    | TWI_ARB_LOST => {
//        val () = println! "arb"
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
      }
// Slave
    | TWI_STX_ADR_ACK  => {
        val () = reset_next_byte()
        val () = slave_transmit_next_byte()
      }
    | TWI_STX_ADR_ACK_M_ARB_LOST => {
        val () = reset_next_byte()
        val () = slave_transmit_next_byte()
      }
    | TWI_STX_DATA_ACK => slave_transmit_next_byte()
    | TWI_STX_DATA_NACK => let
      val (free, pf | p) = get_twi_state()
      val () =
        if get_all_bytes_sent(p->status_reg) then {
          val () = set_last_trans_ok(p->status_reg, true)
        } else {
          val () = p->state := uchar_of_reg8(TWSR)
        }
      val () = set_busy(p->status_reg, false)
      prval () = return_global(free, pf)
     in
      clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
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
        val () = enable_twi_slave()
      }
    | TWI_SRX_ADR_DATA_ACK => {
        val () = read_next_byte()
      }
    | TWI_SRX_GEN_DATA_ACK => read_next_byte()
    | TWI_SRX_STOP_RESTART => {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
        val (gpf, pf | p) = get_twi_state()
        val () = set_busy(p->status_reg, false)
        prval () = return_global(gpf, pf)
     }
    | TWI_BUS_ERROR => {
        val () = clear_and_setbits(TWCR, TWSTO, TWINT)
      }
    | _ => {
        val (gpf, pf | p) = get_twi_state()
        val () = p->state := uchar_of_reg8(TWSR)
        val _ = p->enable()
        prval () = return_global(gpf, pf)
    }
  end
end