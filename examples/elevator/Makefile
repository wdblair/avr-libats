F_CPU=16000000U
MMCU=atmega328p

all: elevator

elevator: main.dats
	avr-atscc -mmcu=$(MMCU) -h $< -o $@ -DF_CPU=$(F_CPU)
	cp $@.hex ~/Dropbox/

.Phony: clean

clean:
	rm *_dats.c elevator *.hex
