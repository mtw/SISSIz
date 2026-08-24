#!/bin/sh
# The sampled alignments must reproduce the input's mean pairwise identity.
# A zero branch length or a broken site rate model shows up here first.
. "${srcdir:-.}/common.sh"

TOL=0.05
status=0

for f in pair.aln multi.aln skewed.aln; do
  for model in "" "-i"; do
    line=$(result "$DATA/$f" --seed 12345 -n 60 $model)
    [ -n "$line" ] || fail "$f $model produced no output"
    inid=$(field 5 "$line"); sampled=$(field 6 "$line")
    label="$f ${model:-di}"
    if close "$inid" "$sampled" "$TOL"; then
      note "$label: input=$inid sampled=$sampled  ok"
    else
      echo "FAIL: $label: sampled identity $sampled differs from input $inid by more than $TOL" >&2
      status=1
    fi
  done
done
exit $status
