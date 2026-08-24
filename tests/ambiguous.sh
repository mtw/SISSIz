#!/bin/sh
# N and friends must be excluded from the model, with a warning, not read as A.
. "${srcdir:-.}/common.sh"

err=$(run_limited 120 "$SISSIZ" --seed 1 -v -n 20 "$DATA/ambiguous.aln" 2>&1 >/dev/null)
printf '%s\n' "$err" | grep -qi "ambiguous" || fail "no warning about ambiguous characters:
$err"
note "warning emitted"

out=$(run_limited 120 "$SISSIZ" --seed 1 -v -n 20 "$DATA/ambiguous.aln" 2>/dev/null)
inp=$(printf '%s\n' "$out" | grep -m1 '^# Mononucleotide content' | sed 's/.*)://')
[ -n "$inp" ] || fail "no composition reported"
note "composition:$inp"
# the fixture is 12.5% N; counting those as A would push A far above the rest
printf '%s\n' "$inp" | awk '{
  if ($1 > 0.45) { printf "FAIL: A frequency %s looks like the Ns were counted as A\n", $1 > "/dev/stderr"; exit 1 }
}'
