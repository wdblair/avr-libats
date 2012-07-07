F_CPU=16000000
PROJECT=map
CC=avr-gcc
OBJCOPY=avr-objcopy
MMCU=atmega328p

all: $(PROJECT) $(PROJECT).hex size

size: $(PROJECT)
	avr-size --mcu=atmega328p -C $(PROJECT).out

$(PROJECT).hex: $(PROJECT)
	$(OBJCOPY) -j .text -O ihex $(PROJECT).out $(PROJECT).hex

$(PROJECT): linmap_avltree_dats.c linmap_avltree_sats.c main_dats.c
	avr-gcc -D_ATS_PRELUDE_NONE -D_ATS_HEADER_NONE -mmcu=$(MMCU) -O2 -o $(PROJECT).out $^

linmap_avltree_dats.c: linmap_avltree.dats
	avr-atscc -cc linmap_avltree.dats

linmap_avltree_sats.c: linmap_avltree.sats
	avr-atscc -cc linmap_avltree.sats

main_dats.c: main.dats
	avr-atscc -cc main.dats

program: $(PROJECT).hex
	avrdude -p m8 -c avrusb500 -e -U flash:w:$(PROJECT).hex

.Phony: clean

clean:
	rm -f $(PROJECT).out
	rm -f $(PROJECT).hex
	rm -f *.c
