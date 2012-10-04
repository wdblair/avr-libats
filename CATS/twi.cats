#ifndef _AVR_LIBATS_I2C_HEADER
#define _AVR_LIBATS_I2C_HEADER

#include <stdlib.h>

#include "HATS/twi.hats"

//Bit and byte definitions
#define TWI_READ_BIT  0   // Bit position for R/W bit in "address byte".
#define TWI_ADR_BITS  1   // Bit position for LSB of the slave address bits in the init byte.
#define TWI_GEN_BIT   0   // Bit position for LSB of the general call bit in the init byte.

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

#define status_reg_set_all(reg, char) (reg)->all = char
#define status_reg_get_all(reg) (reg)->all

#define status_reg_set_last_trans_ok(reg, char)  (reg)->bits.last_trans_ok = char
#define status_reg_get_last_trans_ok(reg) (reg)->bits.last_trans_ok

#define status_reg_set_rx_data_in_buf(reg, char)  (reg)->bits.rx_data_in_buf = char
#define status_reg_get_rx_data_in_buf(reg) (reg)->bits.rx_data_in_buf

#define status_reg_set_gen_address_call(reg, char)  (reg)->bits.rx_data_in_buf = char
#define status_reg_get_gen_address_call(reg) (reg)->bits.rx_data_in_buf

#define status_reg_set_all_bytes_sent(reg, bool)  (reg)->bits.all_bytes_sent = bool
#define status_reg_get_all_bytes_sent(reg) (reg)->bits.all_bytes_sent

#define status_reg_set_busy(reg, bool) (reg)->bits.busy = bool
#define status_reg_get_busy(reg) (reg)->bits.busy

#define status_reg_get_mode(reg) (reg)->bits.mode
#define status_reg_set_mode(reg, mode) (reg)->bits.busy = mode

#define set_address(address, general_enabled) TWAR = (address << TWI_ADR_BITS) | (general_enabled << TWI_GEN_BIT)

#define avr_libats_setup_addr_byte(buffer, addr, read)  \
  ((unsigned char *)buffer)[0] = (addr << 1) | read

typedef struct {
  unsigned char cnt;
  unsigned char curr;
  unsigned char fmt[BUFF_SIZE/2];
} transaction_t;

ATSinline()
ats_ptr_type
transaction_init (transaction_t *trans) {
  int i;

  trans->cnt = 0;
  trans->curr = 0;
  for(i = 0 ; i < BUFF_SIZE/2; i++)
    trans->fmt[i] = 0;
  return trans;
}

#define transaction_add_msg(trans, v)                                   \
  ((transaction_t*)trans)->fmt[((transaction_t*)trans)->cnt++] = (char)v

#define transaction_get_msg(trans)                              \
  ((transaction_t*)trans)->fmt[((transaction_t*)trans)->curr++]

#define transaction_reset(trans)                \
  ((transaction_t*)trans)->curr = 0

ATSinline()
ats_int_type
avr_libats_twi_twbr_of_scl (ats_int_type scl) {
  //SCL = CLOCK / ((16 + 2(TWBR))* PRESCALER)
  //TWBR = (CLOCK/SCL - 16) / 2
  uint8_t twbr;
  ldiv_t div;

  div = ldiv(F_CPU/1000, scl);
  
  twbr = (uint8_t)div.quot;

  twbr = (twbr - 16) / 2;
  
  return twbr;
}

union status_reg_t
{
  volatile unsigned char all;
  volatile struct
  {
    volatile unsigned char last_trans_ok:1;
    volatile unsigned char rx_data_in_buf:1;
    volatile unsigned char gen_address_call:1;
    volatile unsigned char all_bytes_sent:1;
    volatile unsigned char busy:1;
    volatile unsigned char mode:1;
    volatile unsigned char unused_bits:2;
  } bits;
};

// ATS doesn't have a union type
typedef union status_reg_t status_reg_t;

typedef struct {
  volatile unsigned char data[BUFF_SIZE];
  volatile unsigned char trans[BUFF_SIZE/2];
  volatile uint8_t msg_size;
  volatile uint8_t recvd_size;
  volatile uint8_t trans_size;
  volatile uint8_t curr_trans;
} buffer_t;

typedef struct {
  volatile buffer_t buffer;
  volatile status_reg_t status_reg;
  volatile uint8_t state;
  volatile uint8_t next_byte;
  volatile ats_ptr_type enable;
  volatile ats_ptr_type busy;
  volatile ats_ptr_type process;
} twi_state_t;

#define get_twi_state() (twi_state_t * volatile)&twi_state

#endif
