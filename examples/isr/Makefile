all: build

build: main.dats
	avr-atscc -mmcu=atmega328p $< -DF_CPU=16000000UL
	avr-objcopy -O ihex a.out ~/Dropbox/isr.hex