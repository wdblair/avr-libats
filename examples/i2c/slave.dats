(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from an Atmel Application Note found in ref
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

//An awesome feature of ATS: using this one 
//define we prove all memory manipulations
//are accurate. This
//constant is defined in the C code as well,
//so that adds another bit of stability.
#define BUFF_SIZE 4

(* ****** ****** *)

//Bit and byte definitions
#define TWI_READ_BIT  0   // Bit position for R/W bit in "address byte".
#define TWI_ADR_BITS  1   // Bit position for LSB of the slave address bits in the init byte.
#define TWI_GEN_BIT   0   // Bit position for LSB of the general call bit in the init byte.

(* ****** ****** *)

//  TWI State codes

// General TWI Master staus codes
#define TWI_START                  0x08  // START has been transmitted
#define TWI_REP_START              0x10  // Repeated START has been transmitted
#define TWI_ARB_LOST               0x38  // Arbitration lost

// TWI Master Transmitter staus codes
#define TWI_MTX_ADR_ACK            0x18  // SLA+W has been tramsmitted and ACK received
#define TWI_MTX_ADR_NACK           0x20  // SLA+W has been tramsmitted and NACK received
#define TWI_MTX_DATA_ACK           0x28  // Data byte has been tramsmitted and ACK received
#define TWI_MTX_DATA_NACK          0x30  // Data byte has been tramsmitted and NACK received

// TWI Master Receiver staus codes
#define TWI_MRX_ADR_ACK            0x40  // SLA+R has been tramsmitted and ACK received
#define TWI_MRX_ADR_NACK           0x48  // SLA+R has been tramsmitted and NACK received
#define TWI_MRX_DATA_ACK           0x50  // Data byte has been received and ACK tramsmitted
#define TWI_MRX_DATA_NACK          0x58  // Data byte has been received and NACK tramsmitted

// TWI Slave Transmitter staus codes
#define TWI_STX_ADR_ACK            0xA8  // Own SLA+R has been received; ACK has been returned
#define TWI_STX_ADR_ACK_M_ARB_LOST 0xB0  // Arbitration lost in SLA+R/W as Master; own SLA+R has been received; ACK has been returned
#define TWI_STX_DATA_ACK           0xB8  // Data byte in TWDR has been transmitted; ACK has been received
#define TWI_STX_DATA_NACK          0xC0  // Data byte in TWDR has been transmitted; NOT ACK has been received
#define TWI_STX_DATA_ACK_LAST_BYTE 0xC8  // Last data byte in TWDR has been transmitted (TWEA = 0); ACK has been received

// TWI Slave Receiver status codes
#define TWI_SRX_ADR_ACK            0x60  // Own SLA+W has been received ACK has been returned
#define TWI_SRX_ADR_ACK_M_ARB_LOST 0x68  // Arbitration lost in SLA+R/W as Master; own SLA+W has been received; ACK has been returned
#define TWI_SRX_GEN_ACK            0x70  // General call address has been received; ACK has been returned
#define TWI_SRX_GEN_ACK_M_ARB_LOST 0x78  // Arbitration lost in SLA+R/W as Master; General call address has been received; ACK has been returned
#define TWI_SRX_ADR_DATA_ACK       0x80  // Previously addressed with own SLA+W; data has been received; ACK has been returned
#define TWI_SRX_ADR_DATA_NACK      0x88  // Previously addressed with own SLA+W; data has been received; NOT ACK has been returned
#define TWI_SRX_GEN_DATA_ACK       0x90  // Previously addressed with general call; data has been received; ACK has been returned
#define TWI_SRX_GEN_DATA_NACK      0x98  // Previously addressed with general call; data has been received; NOT ACK has been returned
#define TWI_SRX_STOP_RESTART       0xA0  // A STOP condition or repeated START condition has been received while still addressed as Slave

// TWI Miscellaneous status codes
#define TWI_NO_STATE               0xF8  // No relevant state information available; TWINT = 0
#define TWI_BUS_ERROR              0x00  // Bus error due to an illegal START or STOP condition

(* ****** ****** *)


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
staload "SATS/sleep.sats"

staload "prelude/SATS/integer.sats"

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

stadef buff_size  = BUFF_SIZE

viewtypedef buffer_t (size: int, n: int)
  = $extype_struct "buffer_t" of {
  data= @[uchar][size],
  msg_size= int n
}

var buffer with vbuffer = $extval( buffer_t(buff_size, 0), "buffer")
viewdef vbuffer = [n:nat | n <= buff_size] buffer_t(buff_size, n) @ buffer
prval global_buffer = global_new{vbuffer}(vbuffer)

var state with vstate =  $extval(uchar, "state")
viewdef vstate = uchar @ state
prval global_state = global_new{vstate}(vstate)

var status_reg with vstatus_reg = $extval(status_reg_t, "status_reg")
viewdef vstatus_reg = status_reg_t @ status_reg
prval global_status_reg = global_new{vstatus_reg}(vstatus_reg)

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
fun twi_start_with_data {n:pos | n <= buff_size}
  (msg: @[uchar][n], sz: int n) : void

extern
fun twi_get_data {n:pos | n <= buff_size}
  (msg: @[uchar][n], sz: int n) : bool

extern
fun twi_start () : void

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
    prval (pf) = global_get(global_twi_busy)
    val () = clear_and_setbits(TWCR, TWEN, TWIE, TWINT, TWEA)
    val () = twi_busy := b
    prval () = global_return(pf, global_twi_busy)
  }

  fun clear_state () : void = {
    //Clear the status register
    prval (pf) = global_get(global_status_reg)
    val () = set_all(status_reg, uchar_of_int(0))
    prval () = global_return(pf, global_status_reg)
    //Clear the state
    prval (pf) = global_get(global_state)
    val () = state := uchar_of_int(TWI_NO_STATE)
    prval () = global_return(pf, global_state)
  }
  
  fun {a:t@ype} copy_buffer {n:nat} {p:nat} {m:pos | m <= n; m <= p} (
    dest: @[a][n], src: @[a][p], num: int m
  ) : void = let
    fun loop {i:nat | i < m}
      (i: int i) : void = let
      val () = dest[i] := src[i]
    in  
      if i = num -1 then 
        () //geschaft!
      else
        loop(i+1)
    end
 in loop(0) end
in

implement 
twi_get_state_info () = let
  val () = sleep_until_ready()
  prval (pf) = global_get(global_state)
  val x = state
  prval () = global_return(pf, global_state)
in x end

implement
twi_start_with_data {n} (msg, size) = let
  val () = sleep_until_ready()
  //Set the size of the message and copy the buffer
  prval (pf) = global_get(global_buffer)
  val () = buffer.msg_size := size
  val () = copy_buffer(buffer.data, msg, size)
  prval () = global_return(pf, global_buffer)
  val () = clear_state()
in enable_twi_set_busy(true) end

implement twi_get_data {n} (msg, size) = let
  val () = sleep_until_ready()
  prval (pf) = global_get(global_status_reg)
  val lastok = get_last_trans_ok(status_reg)
in 
    if get_last_trans_ok(status_reg) then let
      prval (pfb) = global_get(global_buffer)
      val () = copy_buffer(msg, buffer.data, size)
      prval () = global_return(pfb, global_buffer)
      prval () = global_return(pf, global_status_reg)
     in lastok end
    else let
      prval () = global_return(pf, global_status_reg)
    in lastok end
end

implement twi_start() = let
  val () = sleep_until_ready()
  val () = clear_state()
in enable_twi_set_busy(false) end



end

(* ****** ****** *)