structure Seq =
struct
  structure A = Array
  structure AS = ArraySlice

  type 'a t = 'a ArraySlice.slice

  val gran = 10000

  fun empty () = AS.full (A.fromList [])
  fun fromList xs = ArraySlice.full (Array.fromList xs)

  fun length s = AS.length s

  fun subseq s (i, n) = AS.subslice (s, i, SOME n)

  fun take s k = subseq s (0, k)
  fun drop s k = subseq s (k, length s - k)

  fun nth s i = AS.sub (s, i)

  fun tabulate f n = AS.full (SeqBasis.tabulate gran (0, n) f)

  fun map f s = tabulate (fn i => f (nth s i)) (length s)

  fun iterate f b s =
    SeqBasis.foldl f b (0, length s) (nth s)

  fun foreach s f =
    ForkJoin.parfor gran (0, length s) (fn i => f (i, nth s i))

  fun scan f b s =
    let
      val n = AS.length s
      val r = SeqBasis.scan gran f b (0, n) (nth s)
    in
      (AS.slice (r, 0, SOME n), A.sub (r, n))
    end

  fun scanIncl f b s =
    let
      val n = AS.length s
      val r = SeqBasis.scan gran f b (0, n) (nth s)
    in
      AS.slice (r, 1, NONE)
    end

  fun reduce f b s =
    SeqBasis.reduce gran f b (0, length s) (nth s)

  fun filter p s =
    AS.full (SeqBasis.filter gran (0, length s) (nth s) (p o nth s))

  fun equal eq (s, t) =
    length s = length t andalso
    SeqBasis.reduce gran (fn (a, b) => a andalso b) true (0, length s)
      (fn i => eq (nth s i, nth t i))

end
