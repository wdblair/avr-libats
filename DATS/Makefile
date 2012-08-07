# Compile an ATS library for Arduino (Atmega328p)

F_CPU=16000000L

objects= $(patsubst %.dats, %_dats.o, $(wildcard ./*.dats))

all: library

%_dats.c: %.dats
	atscc -cc -IATS ../ $<

%_dats.o: %_dats.c
	avr-gcc -c -mmcu=atmega328p -O2 -o $@ $< -D_ATS_PRELUDE_NONE -D_ATS_HEADER_NONE -I ../ -I ../clib -DF_CPU=$(F_CPU)
	avr-size --format=avr --mcu=atmega328p $@

library: $(objects)
	ar rcs libats.a $^

.phony: cleanall

cleanall: 
	rm *_dats.c *_dats.o