MMCU=atmega328p
BOOTSTART=0xC00
F_CPU=16000000UL

all: ats-boot.hex

ats-boot: main.dats
	avr-atscc -mmcu=$(MMCU) -Wl,-section-start=.text=$(BOOTSTART) $< -o $@ -DF_CPU=$(F_CPU)
	avr-size $@

ats-boot.hex: ats-boot
	avr-objcopy -O ihex $< $@

.Phony: clean

clean: 
	rm *.o *_dats.c ats-boot *.hex

