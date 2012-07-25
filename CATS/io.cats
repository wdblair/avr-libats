/**
  Author: Will Blair
  wdblair AT cs dot bu dot edu
  July 2012
*/


#define avr_libats_setbits0(reg, b0) (reg |= (b0))


#define avr_libats_setbits1(reg, b0, b1) (reg |= (b0 | b1))


#define avr_libats_setbits2(reg, b0, b1, b2) (reg |= (b0 | b1 | b2))


#define avr_libats_setbits3(reg, b0, b1, b2, b3) (reg |= (b0 | b1 | b2 | b3))


#define avr_libats_setbits4(reg, b0, b1, b2, b3, b4) (reg |= (b0 | b1 | b2 | b3 | b4))


#define avr_libats_setbits5(reg, b0, b1, b2, b3, b4, b5) (reg |= (b0 | b1 | b2 | b3 | b4 | b5))


#define avr_libats_setbits6(reg, b0, b1, b2, b3, b4, b5, b6) (reg |= (b0 | b1 | b2 | b3 | b4 | b5 | b6))


#define avr_libats_setbits7(reg, b0, b1, b2, b3, b4, b5, b6, b7) (reg |= (b0 | b1 | b2 | b3 | b4 | b5 | b6 | b7))


#define avr_libats_maskbits0(reg, b0) (reg &= (b0))


#define avr_libats_maskbits1(reg, b0, b1) (reg &= (b0 | b1))


#define avr_libats_maskbits2(reg, b0, b1, b2) (reg &= (b0 | b1 | b2))


#define avr_libats_maskbits3(reg, b0, b1, b2, b3) (reg &= (b0 | b1 | b2 | b3))


#define avr_libats_maskbits4(reg, b0, b1, b2, b3, b4) (reg &= (b0 | b1 | b2 | b3 | b4))


#define avr_libats_maskbits5(reg, b0, b1, b2, b3, b4, b5) (reg &= (b0 | b1 | b2 | b3 | b4 | b5))


#define avr_libats_maskbits6(reg, b0, b1, b2, b3, b4, b5, b6) (reg &= (b0 | b1 | b2 | b3 | b4 | b5 | b6))


#define avr_libats_maskbits7(reg, b0, b1, b2, b3, b4, b5, b6, b7) (reg &= (b0 | b1 | b2 | b3 | b4 | b5 | b6 | b7))


#define avr_libats_clearbits0(reg, b0) (reg &= ~(b0))


#define avr_libats_clearbits1(reg, b0, b1) (reg &= ~(b0 | b1))


#define avr_libats_clearbits2(reg, b0, b1, b2) (reg &= ~(b0 | b1 | b2))


#define avr_libats_clearbits3(reg, b0, b1, b2, b3) (reg &= ~(b0 | b1 | b2 | b3))


#define avr_libats_clearbits4(reg, b0, b1, b2, b3, b4) (reg &= ~(b0 | b1 | b2 | b3 | b4))


#define avr_libats_clearbits5(reg, b0, b1, b2, b3, b4, b5) (reg &= ~(b0 | b1 | b2 | b3 | b4 | b5))


#define avr_libats_clearbits6(reg, b0, b1, b2, b3, b4, b5, b6) (reg &= ~(b0 | b1 | b2 | b3 | b4 | b5 | b6))


#define avr_libats_clearbits7(reg, b0, b1, b2, b3, b4, b5, b6, b7) (reg &= ~(b0 | b1 | b2 | b3 | b4 | b5 | b6 | b7))

#define avr_libats_setval(reg,val) reg = val