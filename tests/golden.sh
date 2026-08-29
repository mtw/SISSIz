#!/bin/sh
# Lock the corrected dinucleotide triplet mapping to a known seeded result.
. "${srcdir:-.}/common.sh"

di=$(result "$DATA/multi.aln" --seed 4242 -n 20 -m 10)
expected_di=$(printf 'sissiz-di\t%s\t6\t120\t0.7622\t0.7618\t0.0113\t-9.51\t-10.24\t3.79\t0.19' "$DATA/multi.aln")

[ "$di" = "$expected_di" ] || fail "dinucleotide golden result changed:
  expected: $expected_di
  actual:   $di"
note "dinucleotide golden result matches"

# The triplet encoder is not used by the mononucleotide model. Keep that
# control locked as well, so a future mapping change cannot leak into it.
mono=$(result "$DATA/multi.aln" --seed 4242 --mono -n 20 -m 10)
expected_mono=$(printf 'sissiz-mono\t%s\t6\t120\t0.7622\t0.7503\t0.0141\t-9.51\t-8.88\t2.95\t-0.22' "$DATA/multi.aln")

[ "$mono" = "$expected_mono" ] || fail "mononucleotide control changed:
  expected: $expected_mono
  actual:   $mono"
note "mononucleotide control matches"
