#ifndef _ATS_AVR_BASICS_HEADER
#define _ATS_AVR_BASICS_HEADER

#include <inttypes.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>
#include <alloca.h>
#include <stdio.h>
#include <string.h>

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

#undef ATS_GC_MARKROOT
#define ATS_GC_MARKROOT(ptr, sz) do { ; } while (0)

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

#define ats_caselind_mac(ty, x, ind) (((ty*)(&(x)))ind)
 
#define ats_caselptrind_mac(ty, x, ind) (((ty*)(x))ind)
#define ats_caselptrlab_mac(ty, x, lab) (((ty*)(x))->lab)

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
typedef unsigned int ats_uint_type;
typedef void ats_void_type ;
typedef char ats_char_type ;
typedef char ats_schar_type ;
typedef unsigned char ats_uchar_type ;
typedef uint8_t ats_bool_type ;
typedef double ats_double_type ;
typedef size_t ats_size_type ;

struct ats_struct_type ;

typedef struct ats_struct_type ats_abs_type ;

typedef void *ats_ptr_type ;
typedef void *ats_ref_type ;

typedef
struct { int tag ; } ats_sum_type ;
typedef ats_sum_type *ats_sum_ptr_type ;

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
ats_int_type
atspre_int_of_char (ats_char_type c) { return c ; }

ATSinline()
ats_char_type
atspre_char_of_int (ats_int_type i) { return i ; }

ATSinline()
ats_schar_type
atspre_schar_of_int (ats_int_type i) { return i ; }

ATSinline()
ats_uchar_type
atspre_uchar_of_int (ats_int_type c) { return c ; }

ATSinline()
ats_int_type
atspre_int_of_uchar (ats_uchar_type c) { return c ; }

ATSinline()
ats_bool_type
atspre_eq_char_char
(ats_char_type c1, ats_char_type c2) {
  return (c1 == c2) ;
} // end of [atspre_eq_char_char]

#define ptrof_error(x) ((void*)&x)

/* ****** ****** */

#define ATS_MALLOC(x) malloc(x)
#define ATS_ALLOCA(sz) alloca(sz)
#define ATS_ALLOCA2(n, sz) alloca((n)*(sz))
#define ATS_FREE(x) free(x)

ATSinline()
ats_void_type
ats_exit_errmsg (ats_int_type n) {
  abort();
}

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

ATSinline()
ats_size_type
atspre_size_of_int
  (ats_int_type i) {
  if (i < 0) {
    exit (1) ;
  } /* end of [if] */
  return ((ats_size_type)i) ;
} // end of [atspre_size_of_int]

#define atspre_add_size_int atspre_add_size1_int1
#define atspre_add_size_size atspre_add_size1_size1

ATSinline()
ats_size_type
atspre_add_size1_int1 (ats_size_type sz1, ats_int_type i2) {
  return (sz1 + i2) ;
}

ATSinline()
ats_size_type
atspre_add_size1_size1 (
  ats_size_type sz1, ats_size_type sz2
) {
  return (sz1 + sz2) ;
} // end of [atspre_add_size1_size1]

/*
  Fixed size numbers
 */
/* ****** ****** */

/* signed and unsigned integers of fixed sizes */

/* ****** ****** */



typedef int8_t ats_int8_type ;
typedef uint8_t ats_uint8_type;
typedef int16_t ats_int16_type;
typedef uint16_t ats_uint16_type;

// signed integer of size 8bit

ATSinline()
ats_int8_type
atspre_int8_of_int (ats_int_type i) {
  return i ;
}

ATSinline()
ats_int_type
atspre_int_of_int8 (ats_int8_type i) {
  return i ;
}

// ------ ------

ATSinline()
ats_int8_type
atspre_abs_int8 (ats_int8_type i) {
  return (i >= 0 ? i : -i) ;
}

ATSinline()
ats_int8_type
atspre_neg_int8 (ats_int8_type i) {
  return (-i) ;
}

ATSinline()
ats_int8_type
atspre_succ_int8 (ats_int8_type i) {
  return (i + 1) ;
}

ATSinline()
ats_int8_type
atspre_pred_int8 (ats_int8_type i) {
  return (i - 1) ;
}

ATSinline()
ats_int8_type
atspre_add_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 + i2) ;
}

ATSinline()
ats_int8_type
atspre_sub_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 - i2) ;
}

ATSinline()
ats_int8_type
atspre_mul_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 * i2) ;
}

ATSinline()
ats_int8_type
atspre_div_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 / i2) ;
}

ATSinline()
ats_int8_type
atspre_mod_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 % i2) ;
}

ATSinline()
ats_bool_type
atspre_lt_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 < i2) ;
}

ATSinline()
ats_bool_type
atspre_lte_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 <= i2) ;
}

ATSinline()
ats_bool_type
atspre_gt_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 > i2) ;
}

ATSinline()
ats_bool_type
atspre_gte_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 >= i2) ;
}

ATSinline()
ats_bool_type
atspre_eq_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 == i2) ;
}

ATSinline()
ats_bool_type
atspre_neq_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 != i2) ;
}

// compare, max, min

ATSinline()
ats_int_type
atspre_compare_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  if (i1 < i2) return (-1) ;
  else if (i1 > i2) return ( 1) ;
  else return (0) ;
}

ATSinline()
ats_int8_type
atspre_max_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 >= i2) ? i1 : i2 ;
}

ATSinline()
ats_int8_type
atspre_min_int8_int8 (ats_int8_type i1, ats_int8_type i2) {
  return (i1 <= i2) ? i1 : i2 ;
}

#define atspre_ineg atspre_neg_int

// print functions

ATSinline()
ats_void_type
atspre_fprint_int8 (ats_ptr_type out, ats_int8_type i) {
  int n = fprintf ((FILE*)out, "%hhd", i) ;
  if (n < 0) {
    ats_exit_errmsg (n);
  }
  return ;
}

ATSinline()
ats_void_type
atspre_print_int8 (ats_int8_type i) {
  atspre_fprint_int8 ((ats_ptr_type)stdout, i) ;
  return ;
}

ATSinline()
ats_void_type
atspre_fprint_int (ats_ptr_type out, ats_int_type i) {
  int n = fprintf ((FILE*)out, "%d", i) ;
  if (n < 0) {
    ats_exit_errmsg (n);
  }
  return ;
}

ATSinline()
ats_void_type
atspre_print_int (ats_int_type i) {
//  atspre_stdout_view_get () ;
  atspre_fprint_int ((ats_ptr_type)stdout, i) ;
//  atspre_stdout_view_set () ;
  return ;
}


ATSinline()
ats_void_type
atspre_prerr_int8 (ats_int8_type i) {
  atspre_fprint_int8 ((ats_ptr_type)stderr, i) ;
  return ;
}

/* ****** ****** */

// unsigned integer of size 8bit

ATSinline()
ats_uint8_type
atspre_uint8_of_uint (ats_uint_type i) {
  return i ;
}

ATSinline()
ats_uint_type
atspre_uint_of_uint8 (ats_uint8_type i) {
  return i ;
}

// ------ ------

ATSinline()
ats_uint8_type
atspre_succ_uint8 (ats_uint8_type i) {
  return (i + 1) ;
}

ATSinline()
ats_uint8_type
atspre_pred_uint8 (ats_uint8_type i) {
  return (i - 1) ;
}

ATSinline()
ats_uint8_type
atspre_add_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 + i2) ;
}

ATSinline()
ats_uint8_type
atspre_sub_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 - i2) ;
}

ATSinline()
ats_uint8_type
atspre_mul_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 * i2) ;
}

ATSinline()
ats_uint8_type
atspre_div_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 / i2) ;
}

ATSinline()
ats_uint8_type
atspre_mod_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 % i2) ;
}

// ------ ------

// comparison operations

ATSinline()
ats_bool_type
atspre_lt_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 < i2) ;
}

ATSinline()
ats_bool_type
atspre_lte_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 <= i2) ;
}

ATSinline()
ats_bool_type
atspre_gt_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 > i2) ;
}

ATSinline()
ats_bool_type
atspre_gte_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 >= i2) ;
}

ATSinline()
ats_bool_type
atspre_eq_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 == i2) ;
}

ATSinline()
ats_bool_type
atspre_neq_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 != i2) ;
}

// compare, max, min

ATSinline()
ats_int_type
atspre_compare_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  if (i1 < i2) return (-1) ;
  else if (i1 > i2) return ( 1) ;
  else return (0) ;
}

ATSinline()
ats_uint8_type
atspre_max_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 >= i2) ? i1 : i2 ;
}

ATSinline()
ats_uint8_type
atspre_min_uint8_uint8 (ats_uint8_type i1, ats_uint8_type i2) {
  return (i1 <= i2) ? i1 : i2 ;
}

// print functions

ATSinline()
ats_void_type
atspre_fprint_uint8 (ats_ptr_type out, ats_uint8_type i) {
  int n = fprintf ((FILE*)out, "%hhu", i) ;
  if (n < 0) {
    ats_exit_errmsg (n);
  }
  return ;
}

ATSinline()
ats_void_type
atspre_print_uint8 (ats_uint8_type i) {
  atspre_fprint_uint8 ((ats_ptr_type)stdout, i) ;
  return ;
}

ATSinline()
ats_void_type
atspre_prerr_uint8 (ats_uint8_type i) {
  atspre_fprint_uint8 ((ats_ptr_type)stderr, i) ;
  return ;
}

/* ****** ****** */

// signed integer of size 16bit

ATSinline()
ats_int16_type
atspre_int16_of_int (ats_int_type i) {
  return i ;
}

ATSinline()
ats_int_type
atspre_int_of_int16 (ats_int16_type i) {
  return i ;
}

// ------ ------

ATSinline()
ats_int16_type
atspre_abs_int16 (ats_int16_type i) {
  return (i >= 0 ? i : -i) ;
}

ATSinline()
ats_int16_type
atspre_neg_int16 (ats_int16_type i) {
  return (-i) ;
}

ATSinline()
ats_int16_type
atspre_succ_int16 (ats_int16_type i) {
  return (i + 1) ;
}

ATSinline()
ats_int16_type
atspre_pred_int16 (ats_int16_type i) {
  return (i - 1) ;
}

ATSinline()
ats_int16_type
atspre_add_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 + i2) ;
}

ATSinline()
ats_int16_type
atspre_sub_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 - i2) ;
}

ATSinline()
ats_int16_type
atspre_mul_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 * i2) ;
}

ATSinline()
ats_int16_type
atspre_div_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 / i2) ;
}

ATSinline()
ats_int16_type
atspre_mod_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 % i2) ;
}

ATSinline()
ats_bool_type
atspre_lt_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 < i2) ;
}

ATSinline()
ats_bool_type
atspre_lte_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 <= i2) ;
}

ATSinline()
ats_bool_type
atspre_gt_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 > i2) ;
}

ATSinline()
ats_bool_type
atspre_gte_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 >= i2) ;
}

ATSinline()
ats_bool_type
atspre_eq_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 == i2) ;
}

ATSinline()
ats_bool_type
atspre_neq_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 != i2) ;
}

// compare, max, min

ATSinline()
ats_int_type
atspre_compare_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  if (i1 < i2) return (-1) ;
  else if (i1 > i2) return ( 1) ;
  else return (0) ;
}

ATSinline()
ats_int16_type
atspre_max_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 >= i2) ? i1 : i2 ;
}

ATSinline()
ats_int16_type
atspre_min_int16_int16 (ats_int16_type i1, ats_int16_type i2) {
  return (i1 <= i2) ? i1 : i2 ;
}

// print functions

ATSinline()
ats_void_type
atspre_fprint_int16 (ats_ptr_type out, ats_int16_type i) {
  int n = fprintf ((FILE*)out, "%d", i) ;
  if (n < 0) {
    ats_exit_errmsg (n);
  }
  return ;
}

ATSinline()
ats_void_type
atspre_print_int16 (ats_int16_type i) {
  atspre_fprint_int16 ((ats_ptr_type)stdout, i) ;
  return ;
}

ATSinline()
ats_void_type
atspre_prerr_int16 (ats_int16_type i) {
  atspre_fprint_int16 ((ats_ptr_type)stderr, i) ;
  return ;
}

/* ****** ****** */

//
// unsigned integer of size 16bit
//

ATSinline()
ats_uint16_type
atspre_uint16_of_int (ats_int_type i) { return i ; }
ATSinline()
ats_int_type
atspre_int_of_uint16 (ats_uint16_type i) { return i ; }

ATSinline()
ats_uint16_type
atspre_uint16_of_uint (ats_uint_type i) { return i ; }
ATSinline()
ats_uint_type
atspre_uint_of_uint16 (ats_uint16_type i) { return i ; }

// ------ ------

ATSinline()
ats_uint16_type
atspre_succ_uint16 (ats_uint16_type i) {
  return (i + 1) ;
}

ATSinline()
ats_uint16_type
atspre_pred_uint16 (ats_uint16_type i) {
  return (i - 1) ;
}

ATSinline()
ats_uint16_type
atspre_add_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 + i2) ;
}

ATSinline()
ats_uint16_type
atspre_sub_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 - i2) ;
}

ATSinline()
ats_uint16_type
atspre_mul_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 * i2) ;
}

ATSinline()
ats_uint16_type
atspre_div_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 / i2) ;
}

ATSinline()
ats_uint16_type
atspre_mod_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 % i2) ;
}

// ------ ------

// comparison operations

ATSinline()
ats_bool_type
atspre_lt_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 < i2) ;
}

ATSinline()
ats_bool_type
atspre_lte_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 <= i2) ;
}

ATSinline()
ats_bool_type
atspre_gt_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 > i2) ;
}

ATSinline()
ats_bool_type
atspre_gte_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 >= i2) ;
}

ATSinline()
ats_bool_type
atspre_eq_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 == i2) ;
}

ATSinline()
ats_bool_type
atspre_neq_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 != i2) ;
}

// compare, max, min

ATSinline()
ats_int_type
atspre_compare_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  if (i1 < i2) return (-1) ;
  else if (i1 > i2) return ( 1) ;
  else return (0) ;
}

ATSinline()
ats_uint16_type
atspre_max_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 >= i2) ? i1 : i2 ;
}

ATSinline()
ats_uint16_type
atspre_min_uint16_uint16 (ats_uint16_type i1, ats_uint16_type i2) {
  return (i1 <= i2) ? i1 : i2 ;
}

//
// print functions
//

ATSinline()
ats_void_type
atspre_fprint_uint16 (ats_ptr_type out, ats_uint16_type i) {
  int n = fprintf ((FILE*)out, "%hu", i) ;
  if (n < 0) {
    ats_exit_errmsg (n) ;
  }
  return ;
}

ATSinline()
ats_void_type
atspre_print_uint16 (ats_uint16_type i) {
//  atspre_stdout_view_get () ;
  atspre_fprint_uint16 ((ats_ptr_type)stdout, i) ;
//  atspre_stdout_view_set () ;
  return ;
}

ATSinline()
ats_void_type
atspre_prerr_uint16 (ats_uint16_type i) {
  atspre_fprint_uint16 ((ats_ptr_type)stderr, i) ;
  return ;
}


/*
  closures
 */

typedef struct { void *closure_fun ; } ats_clo_type ;

typedef ats_clo_type *ats_clo_ptr_type ;
typedef ats_clo_type *ats_clo_ref_type ;

typedef void *ats_fun_ptr_type ;

ATSinline()
ats_bool_type
atspre_gt_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 > i2) ;
}

#define atspre_null_ptr NULL

//static
//ats_ptr_type atspre_null_ptr = (ats_ptr_type)0 ;

ATSinline()
ats_bool_type
atspre_pgt (ats_ptr_type p1, ats_ptr_type p2) {
  return (p1 > p2) ;
}

#define atspre_iadd atspre_add_int_int
#define atspre_isub atspre_sub_int_int
#define atspre_imul atspre_mul_int_int

#define atspre_ilt atspre_lt_int_int
#define atspre_ilte atspre_lte_int_int
#define atspre_igt atspre_gt_int_int
#define atspre_igte atspre_gte_int_int
#define atspre_ieq atspre_eq_int_int
#define atspre_ineq atspre_neq_int_int

#define atspre_icompare atspre_compare_int_int
#define atspre_imax atspre_max_int_int
#define atspre_imin atspre_min_int_int

#define atspre_ipow atspre_pow_int_int1
#define atspre_npow atspre_pow_int_int1

#define atspre_nmod atspre_mod_int_int
#define atspre_nmod1 atspre_mod_int_int
#define atspre_nmod2 atspre_mod_int_int

ATSinline()
ats_void_type
atspre_assert_errmsg(ats_bool_type assertion, ats_ptr_type msg) {
  assert(assertion);
}

ATSinline()
ats_void_type
atspre_assert (const ats_bool_type assertion)
 {
   assert(assertion);
} // end of [atspre_assert]

ATSinline()
ats_int_type
atspre_sub_int_int (ats_int_type i1, ats_int_type i2) {
  return (i1 - i2) ;
}

typedef long long int ats_llint_type ;

ATSinline()
ats_ptr_type
atspre_tostrptr_llint
(ats_llint_type i0) {
  ats_llint_type i, i1 ; int n ; char *res ;
//
  i1 = (i0 >= 0 ? i0 : -i0) ;
  for (i = i1, n = 0; i > 0; i = i / 10) n += 1 ;
  if (i0 < 0) n += 1 ; if (i0 == 0) n = 1;
  res = ATS_MALLOC(n+1) ; res = res + n ; *res = '\000' ;
  for (i = i1, n = 0; i > 0; i = i / 10) {
    *--res = ('0' + i % 10) ;
  } // end of [for]
  if (i0 < 0) *--res = '-' ; if (i0 == 0) *--res = '0' ;
//
  return res ;
} // end of [atspre_tostrptr_llint]

ATSinline()
ats_ptr_type
atspre_tostrptr_int
(ats_int_type i) { return atspre_tostrptr_llint (i) ; }
// end of [atspre_tostrptr_int]

#define ats_closure_fun(f) ((ats_clo_ptr_type)f)->closure_fun

/* Strings  */

ATSinline()
ats_void_type
atspre_fprint_string
(const ats_ptr_type out, const ats_ptr_type s) {
  int n = fprintf ((FILE *)out, "%s", (char*)s);
  if (n < 0) { 
    ats_exit_errmsg(n);
  } // end of [if]
  return ;
} /* end of [atspre_fprint_string] */


ATSinline()
ats_void_type
atspre_print_string (const ats_ptr_type s) {
  //  atspre_stdout_view_get() ;
  atspre_fprint_string((ats_ptr_type)stdout, s) ;
  //  atspre_stdout_view_set() ;
  return ;
} /* end of [atspre_print_string] */

ATSinline()
ats_void_type
atspre_fprint_newline (
  const ats_ptr_type out
) {
  fprintf((FILE*)out, "\n") ;
  fflush((FILE*)out) ;
  return ;
} // end of [atspre_fprint_newline]

ATSinline()
ats_void_type
atspre_fprint_char (
  ats_ptr_type out, ats_char_type c
) {
  int n = fputc ((unsigned char)c, (FILE *)out) ;
  if (n < 0) {
    ats_exit_errmsg (n) ;
  } // end of [if]
  return ;
} // end of [atspre_fprint_char]

ATSinline()
ats_void_type
atspre_print_char
  (ats_char_type c) {
//  atspre_stdout_view_get () ;
  atspre_fprint_char((ats_ptr_type)stdout, c) ;
//  atspre_stdout_view_set () ;
  return ;
}

ATSinline()
ats_void_type
atspre_print_newline () {
  //atspre_stdout_view_get() ;
  atspre_fprint_newline((ats_ptr_type)stdout) ;
  //atspre_stdout_view_set() ;
  return ;
} // end of [atspre_print_newline]


typedef unsigned char byte ;

//
// HX-2010-05-24
// In case 'memcpy' is already defined as a macro ...
//
#ifndef memcpy
extern void *memcpy (void *dst, const void* src, size_t n) ;
#endif // end of [memcpy]

ATSinline()
ats_void_type
atspre_array_ptr_initialize_elt_tsz (
  ats_ptr_type A
, ats_size_type asz
, ats_ptr_type ini
, ats_size_type tsz
)  {
  int i, itsz ; int left ; ats_ptr_type p ;
  if (asz == 0) return ;
  memcpy (A, ini, tsz) ;
  i = 1 ; itsz = tsz ; left = asz - i ;
  while (left > 0) {
    p = (ats_ptr_type)(((byte*)A) + itsz) ;
    if (left <= i) { memcpy (p, A, left * tsz) ; return ; }
    memcpy (p, A, itsz);
    i = i + i ; itsz = itsz + itsz ; left = asz - i ;
  } /* end of [while] */
  return ;
} /* end of [atspre_array_ptr_initialize_elt_tsz] */


#define atspre_neg_bool1 atspre_neg_bool
#define atspre_add_bool1_bool1 atspre_add_bool_bool
#define atspre_mul_bool1_bool1 atspre_mul_bool_bool

#define atspre_lt_bool1_bool1 atspre_lt_bool_bool
#define atspre_lte_bool1_bool1 atspre_lte_bool_bool
#define atspre_gt_bool1_bool1 atspre_gt_bool_bool
#define atspre_gte_bool1_bool1 atspre_gte_bool_bool
#define atspre_eq_bool1_bool1 atspre_eq_bool_bool
#define atspre_neq_bool1_bool1 atspre_neq_bool_bool

#define atspre_compare_bool1_bool1 atspre_compare_bool_bool


ATSinline()
ats_bool_type
atspre_neg_bool
  (ats_bool_type b) {
  return (b ? ats_false_bool : ats_true_bool) ;
} // end of [atspre_neg_bool]

/* ****** ****** */

#if(0)
ATSinline()
ats_bool_type
atspre_add_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  if (b1) { return ats_true_bool ; } else { return b2 ; }
} // end of [atspre_add_bool_bool]

ATSinline()
ats_bool_type
atspre_mul_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  if (b1) { return b2 ; } else { return ats_false_bool ; }
} // end of [atspre_mul_bool_bool]
#endif
#define atspre_add_bool_bool(b1, b2) ((b1) || (b2))
#define atspre_mul_bool_bool(b1, b2) ((b1) && (b2))

/* ****** ****** */

ATSinline()
ats_bool_type
atspre_lt_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  return (!b1 && b2) ;
} // end of [atspre_lt_bool_bool]

ATSinline()
ats_bool_type
atspre_lte_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  return (!b1 || b2) ;
} // end of [atspre_lte_bool_bool]

ATSinline()
ats_bool_type
atspre_gt_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  return (b1 && !b2) ;
} // end of [atspre_gt_bool_bool]

ATSinline()
ats_bool_type
atspre_gte_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  return (b1 || !b2) ;
} // end of [atspre_gte_bool_bool]

ATSinline()
ats_bool_type
atspre_eq_bool_bool (
  ats_bool_type b1, ats_bool_type b2
) {
  if (b1) { return b2 ; } else { return !b2 ; }
} // end of [atspre_eq_bool_bool]

ATSinline()
ats_bool_type
atspre_neq_bool_bool
(ats_bool_type b1, ats_bool_type b2) {
  if (b1) { return !b2 ; } else { return b2 ; }
} // end of [atspre_neq_bool_bool]

#endif
