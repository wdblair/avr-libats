%{#
#include "CATS/io.cats"
%}

#define ATS_STALOADFLAG 0

abst@ype reg(n:int)

praxi lemma_reg_int8 {n:nat} (r: reg(n) ) : [0 <= n; n < 256] void

// Need to figure out a good way to either include the right SATS file
// conditionally from the -mmcu flag or use specific implementation
// to bind register names to devices. Only running code on Arduino now
// so atmega328p is fine.
#include "SATS/iom328p.sats"

macdef F_CPU = $extval(ulint, "F_CPU")

fun bit_is_set {n:nat} (
  r: reg(n), b: natLt(8)
) : bool = "mac#bit_is_set"

fun bit_is_clear {n:nat} (
  r: reg(n), b: natLt(8)
) : bool = "mac#bit_is_clear"

(* Combine two registers into an int.
   Reads low first, then high. *)
fun int_of_regs {n,p:nat} (
  high: reg(n), low: reg(p)
) : int = "mac#avr_libats_int_of_regs"

(* Set an integer across two 8 bit registers *)
fun set_regs_to_int {n,p:nat} (
  high: reg(n), low: reg(p), value: uint16
) : void = "mac#avr_libats_set_regs_to_int"

castfn char_of_reg(r:reg(8)) : char

castfn int_of_reg(r:reg(8)) : [n:nat | n < 256] int n

symintr setbits

fun loop_until_bit_is_clear {n:nat} ( 
  r: !reg(n) >> reg(n'), b: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_loop_until_bit_is_clear"

fun loop_until_bit_is_set {n:nat} (
  r: !reg(n) >> reg(n'), b: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_loop_until_bit_is_set"

fun setbits0 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8)
) : #[n':nat; 0 <= n'; n' < 25] void = "mac#avr_libats_setbits0"

overload setbits with setbits0

fun setbits1 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits1"


overload setbits with setbits1

fun setbits2 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits2"

overload setbits with setbits2

fun setbits3 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits3"


overload setbits with setbits3

fun setbits4 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits4"


overload setbits with setbits4

fun setbits5 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits5"


overload setbits with setbits5

fun setbits6 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits6"


overload setbits with setbits6

fun setbits7 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_setbits7"


overload setbits with setbits7

symintr maskbits

fun maskbits0 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits0"


overload maskbits with maskbits0

fun maskbits1 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits1"


overload maskbits with maskbits1

fun maskbits2 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits2"


overload maskbits with maskbits2

fun maskbits3 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits3"


overload maskbits with maskbits3

fun maskbits4 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits4"


overload maskbits with maskbits4

fun maskbits5 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits5"


overload maskbits with maskbits5

fun maskbits6 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits6"


overload maskbits with maskbits6

fun maskbits7 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_maskbits7"


overload maskbits with maskbits7

symintr clearbits

fun clearbits0 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits0"


overload clearbits with clearbits0

fun clearbits1 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits1"


overload clearbits with clearbits1

fun clearbits2 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits2"


overload clearbits with clearbits2

fun clearbits3 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits3"


overload clearbits with clearbits3

fun clearbits4 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits4"


overload clearbits with clearbits4

fun clearbits5 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits5"


overload clearbits with clearbits5

fun clearbits6 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits6"


overload clearbits with clearbits6

fun clearbits7 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clearbits7"

overload clearbits with clearbits7

symintr setval

fun setval_int {n:nat} (
  r: !reg(n) >> reg(n'), n: natLt(256)
) : #[n':nat | 0 <= n; n < 256] void = "mac#avr_libats_setval"
  
overload setval with setval_int

fun setval_char {n:nat} (
  r: !reg(n) >> reg(n'), c: char
) : #[n':nat | 0 <= n; n < 256] void = "mac#avr_libats_setval"
  
overload setval with setval_char

fun setval_uchar {n:nat} (
  r: !reg(n) >> reg(n'), c: uchar
) : #[n':nat | 0 <= n; n < 256] void = "mac#avr_libats_setval"  

overload setval with setval_uchar

fun setval_uint8 {n:nat} (
  r: !reg(n) >> reg(n'), c: uint8
) : #[n':nat | 0 <= n; n < 256] void = "mac#avr_libats_setval"

overload setval with setval_uint8

symintr clear_and_setbits

fun clear_and_setbits0 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits0"


overload clear_and_setbits with clear_and_setbits0

fun clear_and_setbits1 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits1"


overload clear_and_setbits with clear_and_setbits1

fun clear_and_setbits2 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits2"


overload clear_and_setbits with clear_and_setbits2

fun clear_and_setbits3 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits3"


overload clear_and_setbits with clear_and_setbits3

fun clear_and_setbits4 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits4"


overload clear_and_setbits with clear_and_setbits4

fun clear_and_setbits5 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits5"


overload clear_and_setbits with clear_and_setbits5

fun clear_and_setbits6 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits6"


overload clear_and_setbits with clear_and_setbits6

fun clear_and_setbits7 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_clear_and_setbits7"


overload clear_and_setbits with clear_and_setbits7

symintr flipbits

fun flipbits0 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits0"


overload flipbits with flipbits0

fun flipbits1 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits1"


overload flipbits with flipbits1

fun flipbits2 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits2"


overload flipbits with flipbits2

fun flipbits3 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits3"


overload flipbits with flipbits3

fun flipbits4 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits4"


overload flipbits with flipbits4

fun flipbits5 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits5"


overload flipbits with flipbits5

fun flipbits6 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits6"


overload flipbits with flipbits6

fun flipbits7 {n:nat} (
    r: !reg(n) >> reg(n'), b0: natLt(8), b1: natLt(8), b2: natLt(8), b3: natLt(8), b4: natLt(8), b5: natLt(8), b6: natLt(8), b7: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#avr_libats_flipbits7"


overload flipbits with flipbits7