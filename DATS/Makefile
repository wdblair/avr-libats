# Compile an ATS library for Arduino (Atmega328p)

F_CPU=16000000L

objects= $(patsubst %.dats, %_dats.o, $(wildcard ./*.dats))

all: library

%_dats.o: %.dats
	avr-atscc -cc -mmcu=atmega328p -o $@ $< -DF_CPU=$(F_CPU)
	avr-size  $@

library: $(objects)
	ar rcs libats.a $^
	cp libats.a ../lib/

.phony: cleanall

cleanall:
	rm *_dats.c *_dats.o