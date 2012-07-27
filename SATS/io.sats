%{#
#include "CATS/io.cats"
%}

abst@ype reg(n:int)

praxi lemma_reg_int8 {n:nat} (r: reg(n) ) : [0 <= n; n < 256] void

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

symintr setbits

fun loop_until_bit_is_clear {n:nat} ( 
  r: !reg(n) >> reg(n'), b: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#loop_until_bit_is_clear"

fun loop_until_bit_is_set {n:nat} (
  r: !reg(n) >> reg(n'), b: natLt(8)
) : #[n':nat; 0 <= n'; n' < 256] void = "mac#loop_until_bit_is_set"

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

fun setval {n:nat}
  (r: !reg(n) >> reg(n'), n: natLt(256)) : #[n':nat | 0 <= n; n < 256] void = "mac#avr_libats_setval"