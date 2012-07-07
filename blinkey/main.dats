#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#define F_CPU 16000000L
#include <avr/io.h>
#include <inttypes.h>
#include <util/delay.h>


/* signed integers */

/* ****** ****** */

ATSinline()
ats_bool_type
atspre_gt_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 > i2) ;
}

ATSinline()
ats_int_type
atspre_sub_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 - i2) ;
}


ATSinline()
ats_int_type
atspre_int_of_char (ats_char_type c) { return c ; }

//

ATSinline()
ats_int_type
atspre_abs_int
  (ats_int_type i) { return (i >= 0 ? i : -i) ; }
// end of [atspre_abs_int]

ATSinline()
ats_int_type
atspre_neg_int (ats_int_type i) { return (-i) ; }

ATSinline()
ats_int_type
atspre_succ_int (ats_int_type i) { return (i + 1) ; }

ATSinline()
ats_int_type
atspre_pred_int (ats_int_type i) { return (i - 1) ; }

ATSinline()
ats_int_type
atspre_add_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 + i2) ;
}

ATSinline()
ats_int_type
atspre_mul_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 * i2) ;
}

ATSinline()
ats_int_type
atspre_div_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 / i2) ;
}

ATSinline()
ats_int_type
atspre_mod_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 % i2) ;
}

ATSinline()
ats_bool_type
atspre_lt_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 < i2) ;
}

ATSinline()
ats_bool_type
atspre_lte_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 <= i2) ;
}


ATSinline()
ats_bool_type
atspre_gte_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 >= i2) ;
}

ATSinline()
ats_bool_type
atspre_eq_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 == i2) ;
}

ATSinline()
ats_bool_type
atspre_neq_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 != i2) ;
}

// compare, max and min

ATSinline()
ats_int_type
atspre_compare_int_int (ats_int_type i1, ats_int_type i2) {
  if (i1 < i2) return (-1) ;
  else if (i1 > i2) return ( 1) ;
  else return (0) ;
}

ATSinline()
ats_int_type
atspre_max_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 >= i2) ? i1 : i2 ;
}

ATSinline()
ats_int_type
atspre_min_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 <= i2) ? i1 : i2 ;
}

//
// square, cube and pow functions
//

ATSinline()
ats_int_type
atspre_square_int (ats_int_type i) {
  return (i * i) ;
}

ATSinline()
ats_int_type
atspre_cube_int (ats_int_type i) {
  return (i * i * i) ;
}

ATSinline()
ats_int_type
atspre_pow_int_int1 (ats_int_type x, ats_int_type n) {
  ats_int_type res = 1;
  while (n > 0) {
    if (n % 2 > 0) { res *= x ; x = x * x ; }
    else { x = x * x ; }
    n = n >> 1 ;
  }
  return res ;
}

// greatest common division

ATSinline()
ats_int_type
atspre_gcd_int_int (ats_int_type m0, ats_int_type n0) {
  int m, n, t ;

  if (m0 >= 0) m = m0; else m = -m0 ;
  if (n0 >= 0) n = n0; else n = -n0 ;
  while (m) { t = n % m ; n = m ; m = t ; }
  return n ;

}

// bitwise operations
ATSinline()
ats_int_type
atspre_asl_int_int1 (ats_int_type i, ats_int_type n) {
  return i << n ;
}

ATSinline()
ats_int_type
atspre_asr_int_int1 (ats_int_type i, ats_int_type n) {
  return i >> n ;
}

ats_void_type ats_avr_toggle_led() {
  PORTD ^= _BV(PORTD3); //Toggle on and off
}

ats_void_type ats_avr_init() {
  DDRD = _BV(DDD3);     //Set Pin 3 to output
  PORTD |= _BV(PORTD3); //Turn on the LED at first.
}
%}

extern
fun toggle_led () :  void = "ats_avr_toggle_led"

extern
fun init () : void = "ats_avr_init"

extern
fun delay_ms(ms: double) : void = "_delay_ms"

extern
fun loop (x : int) : void

implement loop (x) =
 if x > 0 then 
   let 
    val () = toggle_led()
    val () = delay_ms(50.0)
   in loop(x-1) end
 else
   ()
   
implement main () =
 let
  val () = init()
  val list = loop(500)
 in end
