#!/bin/sh
# --seed must make a run reproducible, and different seeds must differ.
. "${srcdir:-.}/common.sh"

a=$(result "$DATA/multi.aln" --seed 4242 -n 40)
b=$(result "$DATA/multi.aln" --seed 4242 -n 40)
c=$(result "$DATA/multi.aln" --seed 4243 -n 40)

[ -n "$a" ] || fail "no output"
[ "$a" = "$b" ] || fail "same seed gave different results:
  $a
  $b"
note "same seed reproduces"
[ "$a" != "$c" ] || fail "different seeds gave identical results, the seed is being ignored"
note "different seed differs"

d=$(result "$DATA/multi.aln" -n 40)
e=$(result "$DATA/multi.aln" -n 40)
[ "$d" != "$e" ] || fail "two unseeded runs were identical, the default seed is not varying"
note "unseeded runs vary"
