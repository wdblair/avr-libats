#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

%{^
#include <avr/io.h>
#include <inttypes.h>
#include <util/delay.h>
#include <stddef.h>

//
// HX-2011-02-17:
// if the following definition is not supported, please change it to:
// #define ATSunused
//
#define ATSunused __attribute__ ((unused))

/* ****** ****** */
//
#define ATSextern(ty, name) extern ty name
#define ATSextern_fun(ty, name) extern ty name
#define ATSextern_prf(name) // proof constant
#define ATSextern_val(ty, name) extern ty name
//
#define ATSstatic(ty, name) static ty name
#define ATSstatic_fun(ty, name) static ty name
#define ATSstatic_val(ty, name) static ty name
#define ATSstatic_void(name) // void name // retired
//
#define ATSglobal(ty, name) ty name
//
#define ATSlocal(ty, name) ty ATSunused name
#define ATSlocal_void(name) // void name // retired
//
#define ATScastfn(castfn, name) name

#define ATSglobaldec()
#define ATSstaticdec() static

#define ATSextfun() extern
#define ATSinline() static inline

/* ****** ****** */
//
// HX: boolean values
//
#define ats_true_bool 1
#define ats_false_bool 0

/* ****** ****** */
//
// HX: handling cast functions
//
#define ats_castfn_mac(hit, vp) ((hit)vp)

/* ****** ****** */

#define ats_field_getval(tyrec, ref, lab) (((tyrec*)(ref))->lab)
#define ats_field_getptr(tyrec, ref, lab) (&((tyrec*)(ref))->lab)

/* ****** ****** */

#define ats_cast_mac(ty, x) ((ty)(x))
#define ats_castptr_mac(ty, x) ((ty*)(x))

#define ats_selind_mac(x, ind) ((x)ind)
#define ats_selbox_mac(x, lab) ((x)->lab)
#define ats_select_mac(x, lab) ((x).lab)
#define ats_selptr_mac(x, lab) ((x)->lab)
#define ats_selsin_mac(x, lab) (x)

#define ats_selptrset_mac(ty, x, lab, v) (((ty*)x)->lab = (v))

#define ats_caselind_mac(ty, x, ind) (((ty*)(x))ind)
#define ats_caselptr_mac(ty, x, lab) (((ty*)(x))->lab)

#define ats_varget_mac(ty, x) (x)
#define ats_ptrget_mac(ty, x) (*(ty*)(x))

/* ****** ****** */
//
// HX: handling for/while loops
//
#define ats_loop_beg_mac(init) while(ats_true_bool) { init:
#define ats_loop_end_mac(init, fini) goto init ; fini: break ; }

//
// from ${ATSHOME}/ccomp/runtime/ats_types.h
//
typedef int ats_int_type ;
typedef void ats_void_type ;
typedef char ats_char_type ;
typedef int ats_bool_type ;
typedef double ats_double_type ;
typedef size_t ats_size_type ;

struct ats_struct_type ;

typedef struct ats_struct_type ats_abs_type ;

typedef void *ats_ptr_type ;
typedef void *ats_ref_type ;

//
// from ${ATSHOME}/ccomp/runtime/ats_basic.h
//
#define ATSunused __attribute__ ((unused))
#define ATSstatic_fun(ty, name) static ty name

//
// for handling a call like: printk (KERN_INFO "...")
//
#ifdef ATSstrcst
#undef ATSstrcst
#endif
#define ATSstrcst(x) x

#define ATS_GC_INIT() (void)0
#define mainats_prelude() (void)0

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
