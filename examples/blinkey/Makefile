F_CPU=16000000UL
PROJECT=blinkey
CC=avr-gcc
OBJCOPY=avr-objcopy
MMCU=atmega328p

$(PROJECT).hex: $(PROJECT)
	$(OBJCOPY) -j .text -O ihex $(PROJECT).out $(PROJECT).hex

$(PROJECT):
	avr-atscc -DF_CPU=$(F_CPU) -mmcu=$(MMCU) -o $(PROJECT).out main.dats

program: $(PROJECT).hex
	avrdude -p m8 -c avrusb500 -e -U flash:w:$(PROJECT).hex
clean:
	rm -f $(PROJECT).out
	rm -f $(PROJECT).hex
	rm -f *.c
