(* Fixed Size Integers are Now Indexed Types in AVR ATS. *)

implement main () = {
 var !buf = @[char][4]('a')
 var i : [n:nat] uint8 n = (uint8)0
 var sum : [s:int] uint8 s = (uint8)0
 val () = for ((); i < (uint8)4; i := i + (uint8)1) {
    val x = !buf.[i]
    val () = sum := sum + (uint8) x
 }
}