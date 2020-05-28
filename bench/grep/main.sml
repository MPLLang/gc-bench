structure CLA = CommandLineArgs

val (pat, file) =
  case CLA.positional () of
    [pat, file] => (pat, file)
  | _ => Util.die ("[ERR] usage: grep PATTERN FILE")

val benchmark = CLA.parseFlag "benchmark"

fun bprint str =
  if not benchmark then ()
  else print str

val pattern = Seq.tabulate (fn i => String.sub (pat, i)) (String.size pat)

val (source, tm) = Util.getTime (fn _ => ReadFile.contentsSeq file)
val _ = bprint ("read file in " ^ Time.fmt 4 tm ^ "s\n")

val ((matches, output), tm) = Util.getTime (fn _ => Grep.grep pattern source)
val _ = bprint ("grep completed in " ^ Time.fmt 4 tm ^ "s\n")
val _ = bprint ("number of matched lines: " ^ Int.toString matches ^ "\n")
val _ = bprint ("length of output: " ^ Int.toString (Seq.length output) ^ "\n")

val _ =
  if benchmark then ()
  else
    ArraySlice.app (fn c => TextIO.output1 (TextIO.stdOut, c)) output
