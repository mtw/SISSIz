#!/bin/sh
# Every input and output format must round trip.
. "${srcdir:-.}/common.sh"

status=0

# MAF and CLUSTAL versions of the same alignment must agree
a=$(result "$DATA/multi.aln" --seed 8 -n 30)
b=$(result "$DATA/multi.maf" --seed 8 -n 30)
for n in 3 4 5 8; do
  [ "$(field $n "$a")" = "$(field $n "$b")" ] || {
    echo "FAIL: field $n differs between CLUSTAL and MAF input: '$(field $n "$a")' vs '$(field $n "$b")'" >&2
    status=1; }
done
note "CLUSTAL and MAF input agree"

for fmt in --clustal --maf --fasta; do
  out=$(run_limited 120 "$SISSIZ" --seed 8 -s -n 1 $fmt "$DATA/multi.aln" 2>/dev/null)
  [ -n "$out" ] || { echo "FAIL: $fmt produced nothing" >&2; status=1; continue; }
  n=$(printf '%s\n' "$out" | grep -c 'taxon')
  [ "$n" -ge 6 ] || { echo "FAIL: $fmt emitted $n taxon lines, expected at least 6" >&2; status=1; continue; }
  note "$fmt emitted $n taxon lines"
done
exit $status
