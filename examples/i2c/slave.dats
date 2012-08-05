(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from an Atmel Application Note.
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000

#include <ats/basics.h>

#define declare_isr(vector, ...)                                        \
  void vector (void) __attribute__ ((signal,__INTR_ATTRS)) __VA_ARGS__

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

static volatile status_reg_t status_reg = {0};

#define status_reg_set_all(reg, char) reg.all = char
#define status_reg_get_all(reg) reg.all

#define status_reg_set_last_trans_ok(reg, char)  reg.last_trans_ok = char
#define status_reg_get_last_trans_ok(reg) reg.last_trans_ok

#define status_reg_set_rx_data_in_buf(reg, char)  reg.rx_data_in_buf = char
#define status_reg_get_rx_data_in_buf(reg) reg.rx_data_in_buf

#define status_reg_set_gen_address_call(reg, char)  reg.rx_data_in_buf = char
#define status_reg_get_gen_address_call(reg) reg.rx_data_in_buf

#define set_address(address, general_enabled) TWAR = (address << TWI_ADR_BITS) | (general_enabled << TWI_GEN_BIT)
%}

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"

staload "prelude/SATS/integer.sats"

(* ****** ****** *)

absviewtype status_reg_t = $extype "status_reg_t"

extern
fun set_all (
  r: status_reg_t, c: uchar
) : void = "mac#status_reg_set_all"

extern
fun get_all (
  r: status_reg_t
) : uchar = "mac#status_reg_get_all"

extern
fun set_last_trans_ok (
  r: status_reg_t, c: uchar
) : void = "mac#status_set_last_trans_ok"

extern
fun get_last_trans_ok (
  r: status_reg_t
) : uchar = "mac#status_reg_get_last_trans_ok"


extern
fun set_rx_data_in_buf (
  r: status_reg_t, c: uchar
) : void = "mac#status_set_rx_data_in_buf"

extern
fun get_rx_data_in_buf (
  r: status_reg_t
) : uchar = "mac#status_reg_get_rx_data_in_buf"

extern
fun set_gen_address_call (
  r: status_reg_t, c: uchar
) : void = "mac#status_set_gen_address_call"

extern
fun get_gen_address_call (
  r: status_reg_t
) : uchar = "mac#status_reg_get_gen_address_call"

(* ****** ****** *)

typedef twi_address = [n:int | n >= 0 | n < 128] int n

(* ****** ****** *)

absprop global(view)

extern
praxi global_new {v:view} (pf: v) : global(v)

extern
praxi global_get {v:view} ( g: global(v) ) : (v)

extern
praxi global_return {v:view} (pf: v, g: global(v) ) : void

(* ****** ****** *)

stadef buffer_size  = 4

var buffer : @[uchar][buffer_size] with vbuffer
viewdef vbuffer = @[uchar?][buffer_size] @ buffer
prval global_buffer = global_new{vbuffer}(vbuffer)

var msgsize with vmsgsize = $extval(int, "msgsize")
viewdef vmsgsize = int @ msgsize
prval global_msgsize = global_new{vmsgsize}(vmsgsize)

var state with vstate =  $extval(int, "state")
viewdef vstate = int @ state
prval global_state = global_new{vstate}(vstate)

var status_reg with vstatus_reg = $extval(status_reg_t, "status_reg")
viewdef vstatus_reg = status_reg_t @ status_reg
prval global_state = global_new{vstatus_reg}(vstatus_reg)

var twi_busy with vtwi_busy = $extval(bool, "twi_busy")
viewdef vtwi_busy = bool @ twi_busy
prval global_twi_busy = global_new{vtwi_busy}(vtwi_busy)

(* ****** ****** *)

// reg = (addr << TWI_ADR_BITS) | (TRUE << TWI_GEN_BIT)
// it's a lot easier to just do this in C
extern
fun set_address ( 
  a:twi_address, g:bool
) : void = "mac#set_address"

extern
fun twi_slave_init(pf: !INT_CLEAR | addr: twi_address, gen_addr: bool) : void

extern
fun twi_transceiver_busy () : bool

extern
fun twi_get_state_info () : uchar

extern
fun twi_start_with_data {n:nat} (buf: @[uchar][n], sz: int n) : void

extern
fun twi_start () : bool

(* ****** ****** *)

implement
twi_slave_init(pf | addr, gen_addr) = begin
  set_address(addr, gen_addr);
  clear_and_setbits(TWCR, TWEN);
end

implement 
twi_transceiver_busy () = let
  prval (pf) = global_get(global_twi_busy)
  val x = twi_busy
  prval () = global_return(pf, global_twi_busy)
in x end

local

  fun sleep_until_ready (
    ) : void

in 

end
(* ****** ****** *)

