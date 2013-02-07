(*
  A 1 to 1 wrapper around the boot macros
  in avr-libc
 
  by default, don't allow interrupts to occur.
*)

%{#
#include <avr/boot.h>
%}

staload "SATS/io.sats"
 
dataview array (a:t@ype, int, addr) = 
  | {l:addr} nil (a, 0, l) of ()
  | {l:agz} {n:int | n >= 0} cons(a, n+1, l)
      of (a @ l, array(a, n, l + sizeof a))

#define :: cons

typedef Uint8 = [n:nat] uint8 n

fun program_page {n:nat} {l:agz} (
  pf: !array(Uint8, SPM_PAGESIZE, l) |
  page: uint32 n, buf: ptr l
) : void

fun page_erase {n:nat} (
  pf: !INT_CLEAR | page: uint32 n
) : void = "mac#boot_page_erase"

fun page_write {n:nat} (
  pf: !INT_CLEAR | page: uint32 n
) : void = "mac#boot_page_write"

fun spm_busy_wait (
  pf: !INT_CLEAR | (**)
) : void = "mac#boot_spm_busy_wait"

fun page_fill {n:int} {p:nat} (
  pf: !INT_CLEAR | address: uint32 p, data: uint16 n
) : void = "mac#boot_page_fill"

fun rww_enable () : void = "mac#boot_rww_enable"