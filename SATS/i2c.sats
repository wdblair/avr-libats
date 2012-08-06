%{#
#include "CATS/i2c.cats"
%}

#include "HATS/i2c.hats"

staload "SATS/interrupt.sats"

//  TWI Status codes

// General TWI Master staus codes
macdef TWI_START = $extval(uint8, "TWI_START")
macdef TWI_REP_START = $extval(uint8, "TWI_REP_START")
macdef TWI_ARB_LOST = $extval(uint8, "TWI_ARB_LOST")


// TWI Master Transmitter staus codes
macdef TWI_MTX_ADR_ACK = $extval(uint8, "TWI_MTX_ADR_ACK")
macdef TWI_MTX_ADR_NACK = $extval(uint8, "TWI_MTX_ADR_NACK")
macdef TWI_MTX_DATA_ACK = $extval(uint8, "TWI_MTX_DATA_ACK")
macdef TWI_MTX_DATA_NACK = $extval(uint8, "TWI_MTX_DATA_NACK")


// TWI Master Receiver staus codes
macdef TWI_MRX_ADR_ACK = $extval(uint8, "TWI_MRX_ADR_ACK")
macdef TWI_MRX_ADR_NACK = $extval(uint8, "TWI_MRX_ADR_NACK")
macdef TWI_MRX_DATA_ACK = $extval(uint8, "TWI_MRX_DATA_ACK")
macdef TWI_MRX_DATA_NACK = $extval(uint8, "TWI_MRX_DATA_NACK")


// TWI Slave Transmitter staus codes
macdef TWI_STX_ADR_ACK = $extval(uint8, "TWI_STX_ADR_ACK")
macdef TWI_STX_ADR_ACK_M_ARB_LOST = $extval(uint8, "TWI_STX_ADR_ACK_M_ARB_LOST")
macdef TWI_STX_DATA_ACK = $extval(uint8, "TWI_STX_DATA_ACK")
macdef TWI_STX_DATA_NACK = $extval(uint8, "TWI_STX_DATA_NACK")
macdef TWI_STX_DATA_ACK_LAST_BYTE = $extval(uint8, "TWI_STX_DATA_ACK_LAST_BYTE")


// TWI Slave Receiver status codes
macdef TWI_SRX_ADR_ACK = $extval(uint8, "TWI_SRX_ADR_ACK")
macdef TWI_SRX_ADR_ACK_M_ARB_LOST = $extval(uint8, "TWI_SRX_ADR_ACK_M_ARB_LOST")
macdef TWI_SRX_GEN_ACK = $extval(uint8, "TWI_SRX_GEN_ACK")
macdef TWI_SRX_GEN_ACK_M_ARB_LOST = $extval(uint8, "TWI_SRX_GEN_ACK_M_ARB_LOST")
macdef TWI_SRX_ADR_DATA_ACK = $extval(uint8, "TWI_SRX_ADR_DATA_ACK")
macdef TWI_SRX_ADR_DATA_NACK = $extval(uint8, "TWI_SRX_ADR_DATA_NACK")
macdef TWI_SRX_GEN_DATA_ACK = $extval(uint8, "TWI_SRX_GEN_DATA_ACK")
macdef TWI_SRX_GEN_DATA_NACK = $extval(uint8, "TWI_SRX_GEN_DATA_NACK")
macdef TWI_SRX_STOP_RESTART = $extval(uint8, "TWI_SRX_STOP_RESTART")


// TWI Miscellaneous status codes
macdef TWI_NO_STATE = $extval(uint8, "TWI_NO_STATE")
macdef TWI_BUS_ERROR = $extval(uint8, "TWI_BUS_ERROR")

(* ****** ****** *)

typedef twi_address = [n:int | n >= 0 | n < 128] int n

(* ****** ****** *)

fun twi_slave_init (
  pf: !INT_CLEAR | addr: twi_address, gen_addr: bool
) : void

fun twi_transceiver_busy () : bool

fun twi_get_state_info () : uchar

fun twi_start_with_data {n:pos | n <= buff_size} (
  msg: &(@[uchar][n]), sz: int n
) : void

fun twi_get_data {n:pos | n <= buff_size} (
  msg: &(@[uchar][n]), sz: int n
) : bool

fun twi_start () : void