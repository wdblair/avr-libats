# Compile the ATS library for Arduino (Atmega328p)

F_CPU=16000000L

LIBSRC=./DATSI

dats=$(wildcard ./*.dats)

%_dats.c: %.dats
	atscc -cc -IATS ../ $<

%_dats.o: %_dats.c
	avr-gcc -c -mmcu=atmega328p -o $@ $< -D_ATS_PRELUDE_NONE -D_ATS_HEADER_NONE -I ../ -I ../clib -DF_CPU=$(F_CPU)

.phony: cleanall

cleanall: 
	rm *_dats.c *_dats.o