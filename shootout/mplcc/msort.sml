structure CLA = CommandLineArgs

val n = CLA.parseInt "N" (100 * 1000 * 1000)
val _ = print ("N " ^ Int.toString n ^ "\n")

val repeat = CLA.parseInt "repeat" 10
val _ = print ("repeat " ^ Int.toString repeat ^ "\n")

val _ = print ("hashes "
  ^ LargeInt.toString (Word64.toLargeIntX (Util.hash64 (Word64.fromInt 0))) ^ " "
  ^ LargeInt.toString (Word64.toLargeIntX (Util.hash64 (Word64.fromInt 1))) ^ " "
  ^ LargeInt.toString (Word64.toLargeIntX (Util.hash64 (Word64.fromInt 2))) ^ " "
  ^ "\n")

val _ = print ("generating " ^ Int.toString n ^ " random 32-bit integers\n")

fun elem i =
  Int32.fromInt (Word64.toInt
    (Word64.mod (Util.hash64 (Word64.fromInt i),
                 Word64.fromInt (Int32.toInt (valOf Int32.maxInt)))))

val input = ArraySlice.full (SeqBasis.tabulate 10000 (0, n) elem)
val _ = print ("input " ^ Util.summarizeArraySlice 8 Int32.toString input ^ "\n")

fun loopRepeat tms k =
  if k >= repeat then tms else
  let
    val (result, tm) = Util.getTime (fn _ => Mergesort.sort Int32.compare input)
    val ms = LargeInt.toInt (Time.toMilliseconds tm)
  in
    print ("==== run " ^ Int.toString k ^ " ====\n");
    print ("wall " ^ Int.toString ms ^ "\n");
    print ("result " ^ Util.summarizeArraySlice 8 Int32.toString result ^ "\n");
    loopRepeat (ms :: tms) (k+1)
  end

val tms = loopRepeat [] 0

val total = List.foldl op+ 0 tms
val min = List.foldl Int.min (valOf Int.maxInt) tms
val max = List.foldl Int.max 0 tms
val avg = total div repeat

val _ = print "==== summary ====\n"
val _ = print ("tot " ^ Int.toString total ^ "\n")
val _ = print ("min " ^ Int.toString min ^ "\n")
val _ = print ("max " ^ Int.toString max ^ "\n")
val _ = print ("avg " ^ Int.toString avg ^ "\n")

val _ = GCStats.report ()
