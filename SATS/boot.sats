(* 
  A 1 to 1 wrapper around the boot macros 
  in avr-libc
 
  by default, don't allow interrupts to occur. 
*)

%{#
#include <avr/boot.h>
%}

staload "SATS/io.sats"

typedef Uint8 = [n:nat] uint8 n

fun program_page( 
  buf: &(@[Uint8][SPM_PAGESIZE])
) : void

fun page_erase {n:nat} (
  page: uint32 n
) : void = "mac#boot_page_erase"

fun page_write {n:nat} (
  page: uint32 n
) : void = "mac#boot_page_write"

fun spm_busy_wait () : void = "mac#boot_spm_busy_wait"

fun page_fill {n,p:nat} (
  address: uint32 p, data: uint16 n
) : void = "mac#boot_page_fill"

fun rww_enable () : void = "mac#boot_rww_enable"





