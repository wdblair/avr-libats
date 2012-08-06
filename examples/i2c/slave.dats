(*
  An example of an interrupt driven
  i2c slave device.
    
  Adapted from an Atmel Application Note found in ref
*)

#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

//have to define this in two places unfortunately
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
  unsigned char twi_busy;
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
%}

(* ****** ****** *)

staload "SATS/io.sats"
staload "SATS/interrupt.sats"
staload "SATS/sleep.sats"
staload "SATS/global.sats"

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

macdef BUFF_SIZE = $extval(int,"BUFF_SIZE")

stadef buff_size  = BUFF_SIZE

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
  val (free, pf | p) = get_twi_state()
  val x = p->twi_busy
  prval () = return_global(free, pf)
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
    val () = p->state := uchar_of_int(TWI_NO_STATE)
    prval () = return_global(free, pf)
  }

  extern  
  fun copy_buffer {d,s:int} {sz:pos | sz <= s; sz <= d} (
    dest: @[uchar][d], src: @[uchar][s], num: int sz
  ) : void = "mac#memcpy"
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
