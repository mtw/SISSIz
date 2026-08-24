#!/bin/sh
# The sampled alignments must reproduce the input's nucleotide composition.
. "${srcdir:-.}/common.sh"

TOL=0.06
out=$(run_limited 120 "$SISSIZ" --seed 999 -v -n 60 "$DATA/multi.aln" 2>/dev/null)
inp=$(printf '%s\n' "$out" | grep -m1 '^# Mononucleotide content' | sed 's/.*)://')
smp=$(printf '%s\n' "$out" | grep -m1 '^# Sampled mononucleotide content' | sed 's/.*)://')
[ -n "$inp" ] && [ -n "$smp" ] || fail "verbose output did not report both compositions"
note "input  :$inp"
note "sampled:$smp"

printf '%s\n%s\n' "$inp" "$smp" | awk -v tol="$TOL" '
  NR==1{for(i=1;i<=NF;i++) a[i]=$i; n=NF}
  NR==2{for(i=1;i<=n;i++){d=a[i]-$i; if(d<0)d=-d; if(d>tol){
          printf "FAIL: base %d: input %s vs sampled %s exceeds %s\n", i, a[i], $i, tol > "/dev/stderr"; bad=1}}}
  END{exit bad?1:0}'
