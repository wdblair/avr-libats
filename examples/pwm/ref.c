#include <avr/io.h>

#define F_CPU 16000000

#include <util/delay.h>

void InitPWM()
{
   TCCR2A|=(1<<WGM20)|(1<<WGM21)|(1<<COM2A1);
   TCCR2B|=(1 << CS20);
   DDRB|=(1<<PB3);
}

/******************************************************************
Sets the duty cycle of output. 

Arguments
---------
duty: Between 0 - 255

0= 0%

255= 100%

The Function sets the duty cycle of pwm output generated on OC0 PIN
The average voltage on this output pin will be

         duty
 Vout=  ------ x 5v
         255 

This can be used to control the brightness of LED or Speed of Motor.
*********************************************************************/

void SetPWMOutput(uint8_t duty)
{
   OCR2A = duty;
}

/******************************************************************** 

Simple Wait Loop

*********************************************************************/

void Wait()
{
_delay_ms(10);
}

int main()
{
   uint8_t brightness=0;

   //Initialize PWM Channel 0
   InitPWM();
   //Do this forever
   while(1)
   {	
      //Now Loop with increasing brightness
      for(brightness=5;brightness<255;brightness++)
      {
         //Now Set The Brighness using PWM

         SetPWMOutput(brightness);

         //Now Wait For Some Time
         Wait();
      }

      //Now Loop with decreasing brightness
      for(brightness=255;brightness>5;brightness--)
      {
         //Now Set The Brighness using PWM

         SetPWMOutput(brightness);

         //Now Wait For Some Time
         Wait();
      }
   }
   return 0;
}
