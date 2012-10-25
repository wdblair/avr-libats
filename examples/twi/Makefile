F_CPU=16000000U
MMCU=atmega328p

all: master slave

library: ../../DATS/twi.dats ../../SATS/twi.sats 
	cd ../../DATS && make

master: master.dats library
	avr-atscc -mmcu=$(MMCU) -h $< -o $@ -DF_CPU=$(F_CPU)
	cp $@.hex ~/Dropbox/

slave: slave.dats library
	avr-atscc -mmcu=$(MMCU) -h $< -o $@ -DF_CPU=$(F_CPU)
	cp $@.hex ~/Dropbox/

.Phony: clean

clean: 
	rm *_dats.c master slave *.hex
