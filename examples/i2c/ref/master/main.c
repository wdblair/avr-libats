/*****************************************************************************
*
* Atmel Corporation
*
* File              : main.c
* Compiler          : AVR GCC (Ported from IAR by Will Blair)
* Support mail      : avr@atmel.com
*
* Supported devices : All devices with a TWI module can be used.
*                     The example is written for the ATmega16
*
* AppNote           : AVR315 - TWI Master Implementation
*
****************************************************************************/

#include <avr/io.h>
#include <avr/interrupt.h>
#include "TWI_Master.h"
#include "uart.h"


int main( void )
{
  PORTC = 0b00110000; //pullups on the I2C bus
  unsigned char TWI_targetSlaveAddress, temp, TWI_operation=0,
                pressedButton, myCounter=0;
  USARTInit(51);
  TWI_Master_Initialise();
  sei();

  TWI_targetSlaveAddress   = 0x0C;
  unsigned char data = 0;
  unsigned char buffer[8] = {0x20};
  unsigned char buffer1[4] = {0x21};
  unsigned char output[4] = {};
  while(1)
  {
	  	  if(data = getChar())
	  	  {
	  		  buffer[1] = data;
	  		  TWI_Start_Transceiver_With_Data( buffer, 2);
	  		  TWI_Start_Transceiver_With_Data( buffer1, 2);
	  		  TWI_Get_Data_From_Transceiver(output, 2);
	  		  //printf("%x\n\r", output[1]);
	  	  }
  }

  return 1;
}
