//Do this by default
#define ATS_STALOADFLAG 0
#define ATS_DYNLOADFLAG 0

(* A simple example of Fast-PWM. Could use to glow an LED on and off. *)

typedef avr_register = uint8_t0ype

macdef TCCR2A = $extval(avr_register,"TCCR2A")
macdef TCCR2B = $extval(avr_register,"TCCR2B")

macdef DDRB = $extval(avr_register, "DRRB")

macdef OCR2A = $extval(avr_register, "OCR2A")

dataprop POW2 (int, int) = 
  | {n:nat} {p:nat} POW2ind (n+1, 2*p) of POW2 (n,p)
  | POW2bas (0,1)

extern
fun _BV {n:nat} (b: int n) : [m:nat] ( POW2(n,m) | int m) = "mac#_BV"

extern
fun sbi {n,m:nat | n < 8} (pf: POW(n,m) | reg: avr_register, bits: int m) : void

implement main () = ()
