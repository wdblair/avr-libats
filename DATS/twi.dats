(*
  TWI Driver To Support Both Master and Slave Operation.

  Adapted from Atmel Application Notes AVR315 and AVR311
*)

%{^
declare_isr(TWI_vect);
%}

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/twi.sats"

(* ****** ****** *)

local

  extern
  praxi init (t: &twi_state_t? >> twi_state_t) : void

  var twi_state : twi_state_t with pfstate
  
  prval () = init(twi_state)
  
  viewdef vtwi_state = twi_state_t @ twi_state
in
  prval gstate = global_new{vtwi_state}(pfstate)
  val state = &twi_state
end

(* ****** ****** *)

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
  prval (pf) = global_get(gstate)
  val () = set_busy(state->status_reg, true)
  prval () = global_return(gstate, pf)
}

fun slave_busy () : bool = busy where {
    prval (pf) = global_get(gstate)
    val busy = get_busy(state->status_reg)
    prval () = global_return(gstate, pf)
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
  prval (pf) = global_get(gstate)
  val () = state->enable := enable_twi_slave
  val () = state->busy := slave_busy
  prval () = global_return(gstate, pf)
  prval pf = get_ready()
in (pf | () ) end

implement
master_init(pf | baud) = let
  val twbr = twbr_of_scl(baud)
  val () = enable_pullups()
  val () = setval(TWBR, twbr)
  val () = setval(TWDR, 0xFF)
  val () = clear_and_setbits(TWCR, TWEN)
  prval (pf) = global_get(gstate)
  val () = state->enable := enable_twi_master
  val () = state->busy := master_busy
  prval () = global_return(gstate,pf)
  prval pf = get_ready()
in (pf | ()) end

end

(* ****** ****** *)

implement
transceiver_busy () = busy where {
  prval (pf) = global_get(gstate)
  val busy = state->busy()
  prval () = global_return(gstate,pf)
}

local
  fun sleep_until_ready
    (pf: !INT_SET | (**)) : void = let
        val (locked | ()) = cli( pf | (**))
  in 
    if transceiver_busy () then let
      val (enabled | ()) = sei_and_sleep_cpu(locked | (**))
      prval () = pf := enabled
    in sleep_until_ready(pf | (**)) end
    else let
      val (enabled | ()) = sei(locked | (* *))
      prval () = pf := enabled
    in end
  end
  
  local
    extern
    praxi get_ready(pf: TWI_BUSY) : TWI_READY
  in
    implement wait (pf, busy | (* *)) = (rdy | () ) where {
      val _ = sleep_until_ready(pf | (* *))
      prval rdy = get_ready(busy)
    }
  end
  
  fun enable_twi () : void =
    clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
    
  fun clear_state () : void = {
    prval (pf) = global_get(gstate)
    //Clear the status register
    val () = set_all(state->status_reg, (uchar) 0)
    //Clear the state
    val () = state->state := (uchar) TWI_NO_STATE
    prval () = global_return(gstate,pf)
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
    [n:nat | n <= buff_size] int n = let
      prval (pf) = global_get(gstate)
      var sum : [s:nat] int s = 0
      var i : [n:nat] int n
      val curr = state->buffer.curr_trans
      val () = for(i := 0; i <= curr; i := i + 1) {
        val () = sum := sum + (int1)state->buffer.trans.[i]
      }
  in 
      if sum > state->buffer.msg_size then 0 where {
        prval () = global_return(gstate, pf)
      } else sum where {
        prval () = global_return(gstate, pf)
      }
  end
  
  fun current_msg_first_byte () :
    [n:nat | n < buff_size] int n = let
    prval (pf) = global_get(gstate)
    var sum : [s:nat] int s = 0
    var i : [n:nat] int n
    val curr = state->buffer.curr_trans
    val () = for(i := 0; i < curr; i := i + 1) {
      val () = sum := sum + (int1) state->buffer.trans.[i]
    }
  in
      if sum >= state->buffer.msg_size then 0 where {
        prval () = global_return(gstate, pf)
      } else sum where {
        prval () = global_return(gstate, pf)
      }
  end
  
  fun reset_next_byte_trans () : void = {
    prval (pf) = global_get(gstate)
    val sum = current_msg_first_byte()
    val () = state->next_byte := sum
    val () = set_all_bytes_sent(state->status_reg, false)
    prval() = global_return(gstate, pf)
  }
  
  fun reset_next_byte(m:mode) : void = {
    prval (pf) = global_get(gstate)
    val () = state->next_byte := 0
    val () = set_mode(state->status_reg, m)
    prval () = global_return(gstate, pf)
  }

  fun increment {n,p:nat | p > 0} (
    n: &int n >> int n', p: int p
  ) : #[n':nat | n' < p] void =
    if n + 1 < p then
      n := n + 1
    else
      n := 0
      
  fun copy_recvd_byte_trans () : bool = let
    prval (pf) = global_get(gstate)
    val () = state->buffer.data.[state->next_byte] := (uchar) TWDR
    val sum = current_msg_last_byte()
    val () = increment(state->next_byte, state->buffer.msg_size)
  in
    if state->next_byte = sum then true where {
      val () =
        increment(state->buffer.curr_trans, state->buffer.trans_size)
      prval () = global_return(gstate, pf)
    } else false where {
      prval () = global_return(gstate, pf)
    }
  end
  
  fun copy_recvd_byte () : void = let
    prval (pf) = global_get(gstate)
    val () = state->buffer.data.[state->next_byte] := (uchar)TWDR
  in
      if state->next_byte < state->buffer.msg_size - 1 then {
        val () = state->next_byte := state->next_byte + 1
        val () = global_return(gstate, pf)
      } else {
        prval () = global_return(gstate, pf)
      }
  end
  
  fun read_next_byte () : void = {
    val () = copy_recvd_byte()
    prval (pf) = global_get(gstate)
    val () = increment(state->buffer.recvd_size, state->buffer.msg_size)
    val () = set_last_trans_ok(state->status_reg, true)
    val () = state->enable()
    prval () = global_return(gstate,pf)
  }
  
  fun master_transmit_next_byte () : void = let
      prval (pf) = global_get(gstate)
  in
      if state->next_byte < state->buffer.msg_size then let //more to send
        val sum = current_msg_last_byte()
      in
          //Reached the end of a message, restart.
          if state->next_byte = sum then {
            val () =
              increment(state->buffer.curr_trans, state->buffer.trans_size)
            val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
            prval () = global_return(gstate,pf)
          } else {
              val () = setval(TWDR, state->buffer.data.[state->next_byte])
              val () = increment(state->next_byte, state->buffer.msg_size)
              val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT)
              prval () = global_return(gstate,pf)
          }
      end
      else { //finished
//        val () = println! "f"
        val () = set_last_trans_ok(state->status_reg, true)
        val () = clear_and_setbits(TWCR, TWEN, TWINT, TWSTO)
        prval () = global_return(gstate,pf)
      }
  end

  fun slave_transmit_next_byte () : void = let
      prval (pf) = global_get(gstate)
      //Send the next byte out for delivery
      val x = state->buffer.data.[state->next_byte]
      val () = setval(TWDR, x)
      val () = enable_twi_slave()
  in
    if state->next_byte < (state->buffer.msg_size - 1) then {
      val () = state->next_byte := state->next_byte + 1
      prval () = global_return(gstate,pf)
    } else {
      prval () = global_return(gstate,pf)
    }
  end
  
  fun detect_last_byte () : void = let
      prval (pf) = global_get(gstate)
      val sum = current_msg_last_byte()
  in
      if state->next_byte < (sum - 1) then {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
        prval () = global_return(gstate,pf)
      } else {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT)
        prval () = global_return(gstate,pf)
      }
  end
  
in

implement
get_state_info (enabled | (* *) ) = let
  val () = sleep_until_ready(enabled | (**))
  prval (pf) = global_get(gstate)
  val x = state->state
  prval () = global_return(gstate,pf)
in x end

implement
last_trans_ok (rdy | (* *)) = let
  prval (pf) = global_get(gstate)
  val x = get_last_trans_ok(state->status_reg)
  prval () = global_return(gstate,pf)
in x end

implement
rx_data_in_buf (rdy | (* *)) = let
  prval (pf) = global_get(gstate)
  val x = state->buffer.recvd_size
  prval () = global_return(gstate,pf)
in x end

local
  extern
  praxi get_busy(pf: TWI_READY) : TWI_BUSY
  
  extern
  praxi remove_rdy(pf: TWI_READY) : void
in

implement
start_with_data {n, p} (enabled, rdy | msg, size) = {
  val () = sleep_until_ready(enabled | (* *) )
  prval (pf) = global_get(gstate)
  //Set the size of the message and copy the buffer
  val () = state->buffer.msg_size := size
  val () = copy_buffer(state->buffer.data, msg, size)
  val () = clear_state()
  val _ = state->enable()
  prval () = rdy := get_busy(rdy)
  prval () = global_return(gstate,pf)
}

implement
start_transaction {l} {sum, sz} (
  enabled, rdy | buf, trans
) = (busy | ()) where {
  val () = sleep_until_ready(enabled | (* *))
  prval origin = snapshot(trans)
  prval (pf) = global_get(gstate)
  val sum = sum(trans)
  val sz = size(trans)
  val () = copy_buffer(state->buffer.data, buf, sum)
  val () = state->buffer.msg_size := sum
  val () = state->buffer.curr_trans := 0
  val () = state->buffer.trans_size := sz
  fun loop  {l1:agz} {s:nat} {n1:pos | transaction(s,n1,sz)} (
      pf: !twi_state_t @ l1 | t: !transaction(l, s, n1, sz) >>
        transaction(l, s', 0, sz),
      i: int n1, state: ptr l1
  ) : #[s':nat | s' <= buff_size] void = let
     val nxt = (uchar)(get_msg(t))
     val indx = state->buffer.curr_trans
     val () = state->buffer.trans.[indx] := nxt
     val () =
        if state->buffer.curr_trans < state->buffer.trans_size - 1 then
          state->buffer.curr_trans := state->buffer.curr_trans + 1
  in
    if i - 1 <= 0 then 
      ()
    else
      loop(pf | t, i - 1, state)
  end
  val () = loop(pf | trans, sz, state)
  val () = state->buffer.curr_trans := 0
  val () = reset(origin | trans)
  val () = clear_state()
  val _ = state->enable()
  prval busy = get_busy(rdy)
  prval () = global_return(gstate,pf)
}

implement start(enabled, rdy | (* *)) = (busy | () ) where {
  val () = sleep_until_ready(enabled | (* *))
  val () = clear_state()
  prval (pf) = global_get(gstate)
  val () = state->enable()
  prval busy = get_busy(rdy)
  prval () = global_return(gstate,pf)
}

implement start_server(enabled, rdy | process, sz) = {
  val () = sleep_until_ready(enabled | (* *))
  val () = clear_state()
  prval (pf) = global_get(gstate)
  val () = state->process := process
  val () = state->enable()
  val () = state->buffer.msg_size := sz
  prval () = remove_rdy(rdy)
  prval () = global_return(gstate, pf)
}

end

implement get_data {n, p} (enabled, rdy | msg, size) = let
  val () = sleep_until_ready(enabled | (* *))
  prval (pf) = global_get(gstate)
  val lastok = get_last_trans_ok(state->status_reg)
in 
    if lastok then let
      val () = copy_buffer(msg, state->buffer.data, size)
      prval () = global_return(gstate,pf)
     in lastok end
    else let
      prval () = global_return(gstate,pf)
    in lastok end
end

implement TWI_vect (pf | (* *)) = let
    val twsr = (int1) TWSR
  in
    case+ twsr of
// Master
    | TWI_START => {
//        val () = println! "st"
        val () = reset_next_byte_trans()
        val () = master_transmit_next_byte()
      }
    | TWI_REP_START => {
//        val () = println! "rp"
        val () = reset_next_byte_trans()
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
        val _ = copy_recvd_byte_trans()
        val () = detect_last_byte()
      }
    | TWI_MRX_ADR_ACK => {
//        val () = println! "rack"
        val () = detect_last_byte()
      }
    | TWI_MRX_DATA_NACK => let
//        val () = println! "rnack"
        val _ = copy_recvd_byte_trans()
        prval (pf) = global_get(gstate)
     in
        if state->next_byte = state->buffer.msg_size then {
          //This was the last message.
          val () = set_last_trans_ok(state->status_reg, true)
          val () = clear_and_setbits(TWCR, TWEN, TWINT, TWSTO)
          prval () = global_return(gstate, pf)
        } else { //Restart to hold onto the line.
          val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
          prval () = global_return(gstate, pf)
        }
     end
    | TWI_ARB_LOST => {
//        val () = println! "arb"
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWSTA)
      }
// Slave
    | TWI_STX_ADR_ACK  => {
        val () = reset_next_byte(READ)
        val () = slave_transmit_next_byte()
      }
    | TWI_STX_ADR_ACK_M_ARB_LOST => {
        val () = reset_next_byte(READ)
        val () = slave_transmit_next_byte()
      }
    | TWI_STX_DATA_ACK => slave_transmit_next_byte()
    | TWI_STX_DATA_NACK => let
      prval (pf) = global_get(gstate)
      val () =
        if get_all_bytes_sent(state->status_reg) then {
          val () = set_last_trans_ok(state->status_reg, true)
        } else {
          val () = state->state := (uchar) TWSR
        }
      val () = set_busy(state->status_reg, false)
      prval () = global_return(gstate, pf)
     in
      clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
     end
    | TWI_SRX_GEN_ACK => {
        prval (pf) = global_get(gstate)
        val () = set_mode(state->status_reg, WRITE)
        val () = set_gen_address_call(state->status_reg, true)
        prval () = global_return(gstate, pf)
      }
    | TWI_SRX_ADR_ACK => {
        prval (pf) = global_get(gstate)
        val () = set_rx_data_in_buf(state->status_reg, true)
        val () = set_mode(state->status_reg, WRITE)
        val () = state->next_byte := 0
        prval () = global_return(gstate, pf)
        val () = enable_twi_slave()
      }
    | TWI_SRX_ADR_DATA_ACK => {
        val () = read_next_byte()
      }
    | TWI_SRX_GEN_DATA_ACK => read_next_byte()
    | TWI_SRX_STOP_RESTART => {
        val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
        prval (pf) = global_get(gstate)
        val _ =
          state->process(state->buffer.data, state->buffer.recvd_size, get_mode(state->status_reg))
        val () = set_busy(state->status_reg, false)
        prval () = global_return(gstate, pf)
     }
    | TWI_BUS_ERROR => {
//        val () = println! "err"
        val () = clear_and_setbits(TWCR, TWSTO, TWINT)
     }
    | _ => {
        prval (pf) = global_get(gstate)
        val () = state->state := (uchar) TWSR
        val x = (char) state->state
        val () = println! x
        val _ = state->enable()
        prval () = global_return(gstate, pf)
     }
  end
end
