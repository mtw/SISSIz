#!/bin/sh
# Draw alignments from SISSIz's own null model and score them.  If the model
# is self consistent the z-scores must centre on zero; a systematic offset
# means the simulated background does not match what the scorer assumes.
#
# Slow by design: it needs enough replicates to resolve an offset of ~0.2.
# Not part of the default "make check"; run it with "make check-stats".
. "${srcdir:-.}/common.sh"

M=${NULLDIST_REPLICATES:-300}
NS=${NULLDIST_SAMPLES:-100}
SEEDALN=${NULLDIST_INPUT:-"$DATA/atrich.aln"}
FLOOR=${NULLDIST_TOLERANCE:-0.20}

work=$(mktemp -d "${TMPDIR:-/tmp}/sissiz-nulldist.XXXXXX") || fail "cannot create work directory"
trap 'rm -rf "$work"' EXIT INT TERM

note "drawing $M null alignments from $(basename "$SEEDALN"), scoring each with -n $NS"

k=1
while [ "$k" -le "$M" ]; do
  run_limited 180 "$SISSIZ" -s -n 1 --seed "$k" "$SEEDALN" > "$work/n$k.aln" 2>/dev/null \
    || fail "simulation $k failed"
  k=$((k+1))
done

# A draw can come out too skewed for the model to score; that is a legitimate
# refusal, so skip those and insist only that most replicates survive.
: > "$work/z.txt"
k=1; used=0; skipped=0
while [ "$k" -le "$M" ]; do
  line=$(result "$work/n$k.aln" --seed $((100000+k)) -n "$NS")
  if [ -z "$line" ]; then
    skipped=$((skipped+1))
  else
    field 11 "$line" >> "$work/z.txt"
    used=$((used+1))
  fi
  k=$((k+1))
done

note "$used replicates scored, $skipped refused by the model"
if [ "$used" -lt $((M*9/10)) ]; then
  fail "only $used of $M replicates were scorable"
fi

awk -v floor="$FLOOR" '
  {z[NR]=$1; s+=$1}
  END{
    n=NR; m=s/n
    for(i=1;i<=n;i++) v+=(z[i]-m)*(z[i]-m)
    sd=sqrt(v/(n-1)); se=sd/sqrt(n)
    tol=4*se; if(tol<floor) tol=floor
    printf "  n=%d  mean z=%+.3f  sd=%.3f  se=%.3f  tolerance=%.3f\n", n, m, sd, se, tol
    if (m<0) a=-m; else a=m
    if (a>tol) {
      printf "FAIL: null z-scores are centred on %+.3f, not zero (tolerance %.3f)\n", m, tol > "/dev/stderr"
      exit 1
    }
    printf "  null distribution is centred\n"
  }' "$work/z.txt"
