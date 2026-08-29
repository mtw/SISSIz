#!/bin/sh
# Sequence names carrying Newick syntax must not break tree construction.
# They are mapped to '_' with a warning; the run has to produce an alignment
# and say so, not exit quietly with nothing.
. "${srcdir:-.}/common.sh"

work=$(mktemp -d "${TMPDIR:-/tmp}/sissiz-names.XXXXXX") || fail "cannot create work directory"
trap 'rm -rf "$work"' EXIT INT TERM

a=ACGTTGCAGTCCGATTACGGCATTCCGGATCAGGATTCCAG
b=ACGTTGCAGTCCGATTACGGCATTCCGCATCAGGATACCAG
c=ACGTTGAAGTCCGATTACGGCTTTCCGGATCAGGATTCCTG

status=0
for nm in 'tax:1' 'tax,1' 'tax(1' 'tax)1' 'tax;1' 'chr1:100-200'; do
  printf 'CLUSTAL W(1.81)\n\n\n%-30s%s\n%-30s%s\n%-30s%s\n' \
      "$nm" "$a" "partner_b" "$b" "partner_c" "$c" > "$work/n.aln"
  out=$(run_limited 120 "$SISSIZ" --seed 1 -s -n 1 "$work/n.aln" 2>/dev/null)
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo "FAIL: name '$nm' gave exit $rc" >&2; status=1
  elif [ -z "$(printf '%s\n' "$out" | grep -c 'partner_b')" ] || \
       ! printf '%s\n' "$out" | grep -q 'partner_b'; then
    echo "FAIL: name '$nm' produced no alignment" >&2; status=1
  else
    note "$nm: alignment produced"
  fi
done
exit $status
