#include <stdio.h>
#include <avr/io.h>

static int sendChar(char data, FILE *stream);
static int readChar(FILE *stream);
void putChar(char data);
char getChar();
void USARTInit(uint16_t ubrr_value);

static FILE mystdio = FDEV_SETUP_STREAM(sendChar, readChar, _FDEV_SETUP_RW);

//Initializes the USART
//at a given UBRR value
void USARTInit(uint16_t ubrr_value)
{

   //Set Baud rate
   UBRR0L = ubrr_value;
   UBRR0H = (ubrr_value>>8);

   /*Set Frame Format

   >> Asynchronous mode
   >> No Parity
   >> 1 StopBit
   >> char size 8

   */
   UCSR0C=(3<<UCSZ00);


   //Enable The receiver and transmitter
   UCSR0B=(1<<RXEN0)|(1<<TXEN0);


   UBRR0L = ubrr_value;
   UBRR0H = (ubrr_value>>8);

   stdout = &mystdio; //Required for printf init
   stdin = &mystdio;  //Required for scanf init

}

//This function is used to read the available data
//from USART. This function will wait until data is
//available.
static int readChar(FILE *stream)
{
   //Wait until a data is available
   while(!(UCSR0A & (1<<RXC0)))
   {
      //Do nothing
   }
   putChar(UDR0);
    //Check for end of input
	if(UDR0 == 0x0D)
	{
		//Send a new line
		putChar(0x0A);
		return _FDEV_EOF;
	}

   //Now USART has received data from the host
   //and is available to buffer
   return UDR0;
}

void putChar(char data)
{
	//Wait until the transmitter is ready
   while(!(UCSR0A & (1<<UDRE0)))
   {
      //Do nothing
   }

   //Now write the data to USART buffer
   UDR0=data;
}

char getChar()
{
	//Wait until a data is available
   while(!(UCSR0A & (1<<RXC0)))
   {
      //Do nothing
   }

   //Now USART has received data from the host
   //and is available to buffer
   return UDR0;

}

//This fuction writes the given "data" to
//the USART which then transmit it via TX line
static int sendChar(char data, FILE *stream)
{

   //Wait until the transmitter is ready
   while(!(UCSR0A & (1<<UDRE0)))
   {
      //Do nothing
   }

   //Now write the data to USART buffer
   UDR0=data;

   return 0;
}
