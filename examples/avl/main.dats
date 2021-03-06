(*
** some testing code for functions declared in
** libats/ngc/SATS/linmap_avltree.sats
*)

//
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Time: March, 2010
// Author: Artyom Shalkhakov (artyom DOT shalkhakov AT gmail DOT com)
// Time: January, 2012
//
(* ****** ****** *)

#define ATS_STALOADFLAG 0 // no static loading at run-time
#define ATS_DYNLOADFLAG 0 // no dynamic loading at run-time

staload "linmap_avltree.sats"
staload _(*anon*) = "linmap_avltree.dats"
viewtypedef map_vt (key:t@ype, itm:viewt@ype) = map (key, itm)

(* ****** ****** *)

%{^

typedef
struct {
  char *value ;
} node_itm ;

typedef
struct {
  int key ;
  char *value ;
  int height ;
  void *left ;
  void *right ;
} node_struct ;

ats_ptr_type
node_alloc () {
  return malloc(sizeof(node_struct));
  //return ATS_MALLOC(sizeof(node_struct)) ;
} // end of [node_alloc]

ats_void_type
node_free (ats_ptr_type p) {
  return free(p);
  //return ATS_FREE(p) ;
} // end of [node_free]

ats_ptr_type
node_takeout_val (ats_ptr_type x) {
  return &(((node_struct*)x)->value) ;
} // end of [node_takeout_val]

ATSinline()
ats_int_type node_get_height (ats_ptr_type x) {
  return ((node_struct*)x)->height ;
} // end of [node_get_height]

ATSinline()
ats_void_type
node_set_height (
  ats_ptr_type x, ats_int_type h1
) {
  ((node_struct*)x)->height = h1 ; return ;
} // end of [node_set_height]

ATSinline()
ats_ptr_type node_get_left (ats_ptr_type x) {
  return ((node_struct*)x)->left ;
} // end of [node_get_left]

ATSinline()
ats_void_type
node_set_left (
  ats_ptr_type x, ats_ptr_type p
) {
  ((node_struct*)x)->left = p ; return ;
} // end of [node_set_left]

ATSinline()
ats_ptr_type
node_get_right (ats_ptr_type x) {
  return ((node_struct*)x)->right ;
} // end of [node_get_right]

ATSinline()
ats_void_type
node_set_right (
  ats_ptr_type x, ats_ptr_type p
) {
  ((node_struct*)x)->right = p ; return ;
} // end of [node_set_right]

ATSinline()
int
node_get_key (ats_ptr_type x) {
  return ((node_struct*)x)->key ;
} // end of [node_get_key]

ATSinline()
void
node_set_key (ats_ptr_type x, int k0) {
  ((node_struct*)x)->key = k0 ; return ;
} // end of [node_set_key]

%} // end of [%{]

(* ****** ****** *)

viewtypedef
node_itm =
$extype_struct
  "node_itm" of {
  value= string
} // end of [node_itm]

(* ****** ****** *)

extern
fun node_alloc
  : avlnode_alloc_type (int, node_itm) = "node_alloc"
implement avlnode_alloc<int, node_itm> () = node_alloc ()

extern
fun node_free
  : avlnode_free_type (int, node_itm) = "node_free"
implement avlnode_free<int, node_itm> (pf | x) = node_free (pf | x)

(* ****** ****** *)

extern
fun node_takeout_val
  : avlnode_takeout_val_type (int, node_itm) = "node_takeout_val"
implement avlnode_takeout_val<int, node_itm> (pf | x) = node_takeout_val (pf | x)

(* ****** ****** *)

extern
fun node_get_left
  : avlnode_get_left_type (int, node_itm) = "node_get_left"
implement avlnode_get_left<int, node_itm> (pf | x) = node_get_left (pf | x)

extern
fun node_set_left
  : avlnode_set_left_type (int, node_itm)= "node_set_left"
implement avlnode_set_left<int, node_itm> (pf | x, y) = node_set_left (pf | x, y)

extern
fun node_get_right
  : avlnode_get_right_type (int, node_itm) = "node_get_right"
implement avlnode_get_right<int, node_itm> (pf | x) = node_get_right (pf | x)

extern
fun node_set_right
  : avlnode_set_right_type (int, node_itm) = "node_set_right"
implement avlnode_set_right<int, node_itm> (pf | x, y) = node_set_right (pf | x, y)

extern
fun node_get_height
  : avlnode_get_height_type (int, node_itm) = "node_get_height"
implement avlnode_get_height<int, node_itm> (pf | x) = node_get_height (pf | x)

extern
fun node_set_height
  : avlnode_set_height_type (int, node_itm) = "node_set_height"
implement avlnode_set_height<int, node_itm> (pf | x, y) = node_set_height (pf | x, y)

extern
fun node_get_key
  : avlnode_get_key_type (int, node_itm) = "node_get_key"
implement avlnode_get_key<int, node_itm> (pf | x) = node_get_key (pf | x)

extern
fun node_set_key
  : avlnode_set_key_type (int, node_itm) = "node_set_key"
implement avlnode_set_key<int, node_itm> (pf | x, y) = node_set_key (pf | x, y)

(* ****** ****** *)

implement
compare_key_key<int> (x1, x2, cmp) =
  if x1 < x2 then ~1 else if x1 > x2 then 1 else 0
// end of [compare_key_key]

(* ****** ****** *)

implement main () = let
  var n: int = 10
  val () = assert (n > 0)

  typedef key = int
  viewtypedef itm = node_itm
  fn cmp (x1: key, x2: key):<cloref> Sgn = compare (x1, x2)
//
  var res: itm? // uninitialized
//
  var map = linmap_make_nil {key,itm} ()
  val () = loop (map, n, 0) where {
    fun loop
      {i,n:nat | i <= n} .<n-i>.
      (map: &map_vt (key, itm), n: int n, i: int i): void =
      if i < n then let
        val key = i
        val itm = tostring_int key // val itm = sprintf ("%i", @(key))
        val (pfopt | p) = avlnode_alloc<key,itm> ()
        val () = assertloc (p > null)
        prval Some_v pfnod = pfopt
        val () = avlnode_set_key<key,itm?> (pfnod | p, key)
//
        val (
          pfat, fpfnod | p_itm
        ) =
          avlnode_takeout_val<key,itm?> (pfnod | p)
        val () = p_itm->value := itm
        prval () = pfnod := fpfnod {itm} (pfat)
//
        var p = p
        val found = linmap_insert<key,itm> (pfnod | map, p, cmp)
      in
        if found then let
          prval Some_v pfat = pfnod
        in
          avlnode_free<key,itm> (pfat | p)
        end else let
          prval None_v () = pfnod
        in
          // nothing
        end; // end of [if]
        loop (map, n, i+1)
      end // end of [if]
    // end of [loop]
  } // end of [where]
//
  val size = linmap_size (map)
//  val () = begin
//    print "size = "; print size; print_newline ()
//  end // end of [size]
//
  val height = linmap_height (map)
//  val () = begin
//    print "height = "; print height; print_newline ()
//  end // end of [height]
//
  val () = if :(map: map_vt (key, itm)) => n < 100 then let
    prval pf = unit_v (); val () =
      linmap_foreach_vclo<key,itm> {unit_v} (pf | map, !p_clo) where {
      var !p_clo = @lam (pf: !unit_v | k: key, i: &itm): void =<clo> $effmask_all
        ()
        //(printf ("%i\t->\t%s\n", @(k, i.value)))
    } // end of [val]
    prval unit_v () = pf
  in
    // empty
  end // end of [val]
//
  fn find (
      map: &map_vt (key, itm), k: key, res: &itm?
    ) : void = () where {
//    val () = printf ("%i\t->\t", @(k))
    val b = linmap_search (map, k, cmp, res)
    val () = if b then let
      prval () = opt_unsome {itm} (res)
    in
      ()
     // print "Some("; print (res.value); print ")"
    end else let
      prval () = opt_unnone {itm} (res) in ()//print "None()"
    end // end of [val]
    //val () = print_newline ()
  } // end of [find]
//
  val () = find (map, 0, res)
  val () = find (map, 1, res)
  val () = find (map, 10, res)
  val () = find (map, 100, res)
  val () = find (map, 1000, res)
  val () = find (map, 10000, res)
//
  val () = loop (map, n, 0) where {
    fun loop
      {i,n:nat | i <= n} .<n-i>.
      (map: &map_vt (key, itm), n: int n, i: int i):<cloref> void =
      if i < n then let
        val key = i
        val _(*removed*) = linmap_remove<key,itm> (map, key, cmp)
      in
        // nothing
      end // end of [if]
    // end of [loop]
  } // end of [where]
//
  val size = linmap_size (map)
//  val () = begin
//    print "size = "; print size; print_newline ()
//  end // end of [size]
//
  val () = linmap_free (map)
//
in
  // empty
end // end of [main]

(* ****** ****** *)

(* end of [libats_ngc_linmap_avltree.dats] *)
