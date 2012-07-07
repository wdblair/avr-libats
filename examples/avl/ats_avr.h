#ifndef _ATS_AVR_HEADER
#define _ATS_AVR_HEADER

#include <avr/io.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdlib.h>

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

ATSinline()
ats_int_type
atspre_int_of_char (ats_char_type c) { return c ; }

#define ATS_MALLOC(x) malloc(x)

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

static
ats_ptr_type atspre_null_ptr = (ats_ptr_type)0 ;

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

ATSinline()
ats_void_type
atspre_assert_errmsg(ats_bool_type assertion, ats_ptr_type msg) {
  if( !assertion )
    exit(0);
}

ATSinline()
ats_void_type
atspre_assert (
  const ats_bool_type assertion
) {
  if (!assertion) {
    exit(0);
  }
  return ;
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

#endif
