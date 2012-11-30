%{#
#include "CATS/twi.cats"
%}

#define ATS_STALOADFLAG 0

#define ATS_TWI 1

#include "HATS/twi.hats"

staload "SATS/interrupt.sats"
staload "SATS/global.sats"

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
#define TWI_STX_DATA_ACK_LAST_BYTE 0xC8  // Last data byte in TWDR has been transmitted; ACK has been received

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
#define TWI_NO_STATE               0xF8  // No relevant state information available; 
#define TWI_BUS_ERROR              0x00  // Bus error due to an illegal START or STOP condition

//macdef TWI_NO_STATE = $extval(uint8, "TWI_NO_STATE")

(* ****** ****** *)

typedef twi_address = [n:int | n > 0 | n < 128] int n

(* ****** ****** *)

absviewtype status_reg_t = $extype "status_reg_t"

absview TWI_READY //The device is ready for a transaction
absview TWI_BUSY  //The device is performing a transaction

//Convenience for slaves detecting the current mode.
typedef mode = bool

macdef READ  = true
macdef WRITE = false

viewtypedef buffer_t
  = $extype_struct "buffer_t" of {
  data= @[uchar][buff_size],
  trans= @[uchar][buff_size/2],
  msg_size= [n:pos | n <= buff_size] uint8 n,
  recvd_size= [p:nat | p <= buff_size] uint8 p,
  trans_size= [t:pos | t <= buff_size/2] uint8 t,
  curr_trans= [c:nat | c < buff_size/2] uint8 c
}

viewtypedef twi_state_t
  = $extype_struct "twi_state_t" of {
    buffer=  buffer_t,
    status_reg= status_reg_t,
    state=uchar,
    next_byte= [m:nat | m < buff_size] uint8 m,
    enable= () -<fun1> void,
    busy= () -<fun1> bool,
    process= {n:nat | n <= buff_size} (
      &(@[uchar][buff_size]), uint8 n, mode
    ) -<fun1> void
}

(* ****** ****** *)

viewtypedef transaction_t =  $extype_struct "transaction_t" of {
  cnt= uchar,
  curr= uchar,
  sz= uint8,
  fmt= @[uchar][buff_size/2]
}

absviewt@ype transaction_view_ptr
   (s:int (*sum*), c:int (*count*), sz:int (*maxsize*)) = ptr

viewtypedef transaction(l:addr, s:int, c:int, sz:int)
  = transaction_view_ptr(s, c, sz)

absview transaction_snapshot(s:int, c:int, sz:int)

stadef transaction (
  sum:int, n:int, sz: int
) = sz <= buff_size/2 && sum <= buff_size && n <= sz

praxi snapshot {l:addr} {sum, sz:pos | transaction(sum, sz, sz)} (
  t: !transaction(l, sum, sz, sz)
) : transaction_snapshot(sum, sz, sz)

praxi transaction_length_lemma {l:addr} {sum, n, sz:nat | sum <= buff_size;  n <= sz}
  (t: !transaction(l, sum, n , sz) ) : [sz <= buff_size/2] void

fun transaction_init {n:pos | transaction(0,0,n)} {l:agz} (
  pf: transaction_t? @ l | p: ptr l
) : transaction(l, 0, 0, n) = "mac#transaction_init"

fun size {l:addr} {sum, n, sz:nat | transaction(sum, n, sz)}
  (trans: !transaction(l, sum, n ,sz)): uint8 sz = "mac#transaction_size"

fun count {l:addr} {sum, n, sz:nat | transaction(sum, n, sz)}
  (trans: !transaction(l, sum, n, sz)) : uint8 n = "mac#transaction_count"
  
fun sum {l:addr} {sum, n, sz:nat | transaction(sum, n, sz)} (
  trans: !transaction(l, sum, n, sz)
) : uint8 sum = "mac#transaction_sum"

fun add_msg {l:addr} {s, n, sz, v:nat | v >= 2; transaction(s+v, n, sz)} (
    trans: !transaction(l, s, n, sz) >> transaction(l, s+v, n+1, sz),
    value: int v
) : void = "mac#transaction_add_msg"

fun get_msg {l:addr} {s, n, sz:nat | n > 0; transaction(s, n, sz)} (
    trans: !transaction(l, s, n, sz) >> transaction(l, s-v, n-1, sz)
) : #[v:nat | v >= 2;  s-v >= 0 ; v <= buff_size] int v = "mac#transaction_get_msg"

fun reset {l:addr} {sum,n,sz:nat} {sum': nat | transaction(sum, n, sz); 
  transaction(sum', sz, sz) } (
    pf: transaction_snapshot(sum', sz, sz) |
    trans: !transaction(l, sum, n, sz) >> transaction(l, sum', sz, sz)
) : void = "mac#transaction_reset"

praxi free_transaction {l:addr} {s, n, sz:int} (
  t: transaction(l, s, n, sz)
) : transaction_t @ l

(* ****** ****** *)

fun set_all (
  r: &status_reg_t, c: uchar
) : void = "mac#status_reg_set_all"

fun get_all (
  r: &status_reg_t
) : uchar = "mac#status_reg_get_all"

fun set_last_trans_ok (
  r: &status_reg_t, c: bool
) : void = "mac#status_reg_set_last_trans_ok"

fun get_last_trans_ok (
  r: &status_reg_t
) : bool = "mac#status_reg_get_last_trans_ok"

fun set_rx_data_in_buf (
  r: &status_reg_t, c: bool
) : void = "mac#status_reg_set_rx_data_in_buf"

fun get_rx_data_in_buf (
  r: &status_reg_t
) : bool = "mac#status_reg_get_rx_data_in_buf"

fun set_gen_address_call (
  r: &status_reg_t, c: bool
) : void = "mac#status_reg_set_gen_address_call"

fun get_gen_address_call (
  r: &status_reg_t
) : bool = "mac#status_reg_get_gen_address_call"

fun set_all_bytes_sent (
  r: &status_reg_t, b: bool
) : void = "mac#status_reg_set_all_bytes_sent"

fun get_all_bytes_sent (
  r: &status_reg_t
) : bool = "mac#status_reg_get_all_bytes_sent"

fun set_busy (
  r: &status_reg_t, b: bool
) : void = "mac#status_reg_set_busy"

fun get_busy (
  r: &status_reg_t
) : bool = "mac#status_reg_get_busy"

fun get_mode (
  r: &status_reg_t
) : mode = "mac#status_reg_get_mode"

fun set_mode (
  r: &status_reg_t, m: mode
) : void = "mac#status_reg_set_mode"

(* ****** ****** *)

fun slave_init (
  pf: !INT_CLEAR | addr: twi_address, gen_addr: bool
) : (TWI_READY | void )

fun master_init (
  pf: !INT_CLEAR  | baud: int
) : (TWI_READY | void )

fun setup_addr_byte {n,p:pos | p < 128} {i:nat | i < n} (
  buf: &(@[uchar][n]), indx: int i, addr: int p,  read: bool
) : void = "mac#avr_libats_setup_addr_byte"

fun transceiver_busy () : bool

fun get_state_info (
  pf: !INT_SET | (* *)
) : uchar

fun wait(pf: !INT_SET, busy: TWI_BUSY | (* *)) : (TWI_READY | void)

fun last_trans_ok (pf: !TWI_READY  | (* *)) : bool

fun rx_data_in_buf (pf: !TWI_READY | (* *)) : [n:nat | n <= buff_size] uint8 n

fun start_with_data {n, p:pos | n <= buff_size; p <= buff_size; p <= n} (
  pf: !INT_SET, ready: !TWI_READY >> TWI_BUSY | msg: &(@[uchar][n]), sz: uint8 p
) : void

fun start_transaction {l:addr} {
  sum, sz:pos | transaction(sum, sz, sz)
} (
  pf: !INT_SET, ready: TWI_READY | buf: &(@[uchar][sum]),
  trans: !transaction(l, sum, sz, sz)
) : (TWI_BUSY | void)

fun start_server {sz:pos | sz <= buff_size} (
  pf: !INT_SET, ready: TWI_READY | process: {n:nat | n <= buff_size} (&(@[uchar][buff_size]), uint8 n, mode) -<fun1> void, sz: uint8 sz
) : void

fun get_data {n,p:pos | n <= buff_size; p <= buff_size; p <= n} (
  pf: !INT_SET, ready: !TWI_READY | msg: &(@[uchar][n]), sz: uint8 p
) : bool

fun start (
  pf: !INT_SET, pf: TWI_READY | (* *)
) : (TWI_BUSY | void)

(*
  Disable the TWI module.
  Might be useful to have the device still operate in slave mode,
  but that's probably up to an application.
*)
praxi disable (
  pf: TWI_READY
) : void