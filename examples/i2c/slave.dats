(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from an Atmel Application Note found in ref
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

#include "HATS/i2c.hats"

%{^
#define BUFF_SIZE 4

#define F_CPU 16000000

#include <ats/basics.h>

  union status_reg_t
  {
      unsigned char all;
      struct
      {
         unsigned char last_trans_ok:1;
         unsigned char rx_data_in_buf:1;
         unsigned char gen_address_call:1;
         unsigned char unused_bits:5;
      };
  };

//ATS doesn't support union.
typedef union status_reg_t status_reg_t;

typedef struct {
  unsigned char data[BUFF_SIZE];
  int msg_size;
} buffer_t;

typedef struct {
  buffer_t buffer;
  status_reg_t status_reg;
  unsigned char state;
} twi_state_t;

static volatile twi_state_t twi_state;

#define get_twi_state() (twi_state_t * volatile)&twi_state

#define status_reg_set_all(reg, char) reg.all = char
#define status_reg_get_all(reg) reg.all

#define status_reg_set_last_trans_ok(reg, char)  reg.last_trans_ok = char
#define status_reg_get_last_trans_ok(reg) reg.last_trans_ok

#define status_reg_set_rx_data_in_buf(reg, char)  reg.rx_data_in_buf = char
#define status_reg_get_rx_data_in_buf(reg) reg.rx_data_in_buf

#define status_reg_set_gen_address_call(reg, char)  reg.rx_data_in_buf = char
#define status_reg_get_gen_address_call(reg) reg.rx_data_in_buf

#define set_address(address, general_enabled) TWAR = (address << TWI_ADR_BITS) | (general_enabled << TWI_GEN_BIT)

#define copy_buffer(dest, src, size) memcpy(*dest, *src, size)
%}

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"
staload "SATS/i2c.sats"

(* ****** ****** *)

absviewtype status_reg_t = $extype "status_reg_t"

extern
fun set_all (
  r: !status_reg_t, c: uchar
) : void = "mac#status_reg_set_all"

extern
fun get_all (
  r: !status_reg_t
) : uchar = "mac#status_reg_get_all"

extern
fun set_last_trans_ok (
  r: !status_reg_t, c: bool
) : void = "mac#status_set_last_trans_ok"

extern
fun get_last_trans_ok (
  r: !status_reg_t
) : bool = "mac#status_reg_get_last_trans_ok"


extern
fun set_rx_data_in_buf (
  r: !status_reg_t, c: uchar
) : void = "mac#status_set_rx_data_in_buf"

extern
fun get_rx_data_in_buf (
  r: !status_reg_t
) : uchar = "mac#status_reg_get_rx_data_in_buf"

extern
fun set_gen_address_call (
  r: !status_reg_t, c: uchar
) : void = "mac#status_set_gen_address_call"

extern
fun get_gen_address_call (
  r: !status_reg_t
) : uchar = "mac#status_reg_get_gen_address_call"

(* ****** ****** *)

viewtypedef buffer_t (size: int, n: int)
  = $extype_struct "buffer_t" of {
  data= @[uchar][size],
  msg_size= int n
}

viewtypedef twi_state_t (size: int, n: int)
  = $extype_struct "twi_state_t" of {
    buffer= buffer_t(size, n),
    status_reg= status_reg_t,
    state=uchar,
    twi_busy=bool
}
  
extern
fun get_twi_state () : [n:nat; l:agz | n <= buff_size] (
  global(l), twi_state_t (buff_size, n) @ l | ptr l
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

(* 
   I *think* we don't need to clear/set interrupts for
   the following functions that modify twi_busy as long as we do
   so immediately after enabling the TWI Interrupt.
   On AVR, the instruction following one that enables interrupts
   is guarunteed to execute without interruption.
   
   Combining enabling interrupts with modifying the busy variable
   could be helpful for clarity.
*)
local

  extern
  castfn uchar_of_uint8 (i: uint8) : uchar

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
      
  fun enable_twi_set_busy (b: bool) : void = {
    val (free, pf | p) = get_twi_state()
    val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
    val () = p->twi_busy := b
    prval () = return_global(free, pf)
  }

  fun clear_state () : void = {
    val (free, pf | p) = get_twi_state()
    //Clear the status register
    val () = set_all(p->status_reg, uchar_of_int(0))
    //Clear the state
    val () = p->state := uchar_of_uint8(TWI_NO_STATE)
    prval () = return_global(free, pf)
  }

  extern  
  fun copy_buffer {d,s:int} {sz:pos | sz <= s; sz <= d} (
    dest: &(@[uchar][d]), src: &(@[uchar][s]), num: int sz
  ) : void = "mac#copy_buffer"
in

implement 
twi_get_state_info () = let
  val () = sleep_until_ready()
  val (free, pf | p) = get_twi_state()
  val x = p->state
  prval () = return_global(free, pf)
in x end

implement
twi_start_with_data {n} (msg, size) = let
  val () = sleep_until_ready()
  val (free, pf | p) = get_twi_state()
  //Set the size of the message and copy the buffer
  val () = p->buffer.msg_size := size
  val () = copy_buffer(p->buffer.data, msg, size)
  val () = clear_state()
  prval () = return_global(free,pf)
in enable_twi_set_busy(true) end

implement twi_get_data {n} (msg, size) = let
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
in enable_twi_set_busy(false) end

end

(* ****** ****** *)
