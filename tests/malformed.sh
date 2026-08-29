#!/bin/sh
# Malformed input must be refused with a message and a non-zero exit,
# never a crash or a hang.  The MAF cases guard read_maf's empty-block
# path; note that a compiler which drops the dead load there hides the
# underlying fault, so this checks the behaviour rather than the fault.
. "${srcdir:-.}/common.sh"

work=$(mktemp -d "${TMPDIR:-/tmp}/sissiz-bad.XXXXXX") || fail "cannot create work directory"
trap 'rm -rf "$work"' EXIT INT TERM

: > "$work/empty.aln"
printf 'CLUSTAL W(1.81)\n\n\nonly_one   ACGTACGTACGTACGTACGT\n' > "$work/oneseq.aln"
printf 'CLUSTAL W(1.81)\n\n\na   ACGTACGTACGTACGTACGTAAAA\nb   ACGTACGT\n' > "$work/unequal.aln"
printf 'CLUSTAL W(1.81)\n\n\na   ACGT\n' > "$work/tiny.aln"
printf '>notclustal\nACGTACGT\n>x\nACGTACGT\n' > "$work/fasta.aln"
printf '##maf version=1\na score=0\ns seq1 100 60 + 1000\n\n' > "$work/truncated.maf"
printf '##maf version=1\na score=0\n\n' > "$work/emptyblock.maf"
printf '##maf version=1\na score=0\na score=1\ns s1.c1 1 8 + 99 ACGTACGT\ns s2.c1 1 8 + 99 ACGTACGA\n\n' > "$work/twoblocks.maf"
printf 'CLUSTAL W(1.81)\n\n\na   \001\002\003\004\005\006\n' > "$work/control.aln"

status=0
for f in empty.aln oneseq.aln unequal.aln tiny.aln fasta.aln truncated.maf \
         emptyblock.maf twoblocks.maf control.aln; do
  err=$( { run_limited 60 "$SISSIZ" --seed 1 -n 5 "$work/$f" >/dev/null; } 2>&1 ); rc=$?
  if [ "$rc" -eq 137 ] || [ "$rc" -eq 9 ]; then
    echo "FAIL: $f did not terminate" >&2; status=1
  elif [ "$rc" -gt 128 ]; then
    echo "FAIL: $f died on signal $((rc-128))" >&2; status=1
  elif [ "$rc" -eq 0 ]; then
    echo "FAIL: $f was accepted, expected an error" >&2; status=1
  else
    note "$f: exit $rc"
  fi
done

# a missing file and a directory must also be refused cleanly
for f in "$work/does_not_exist.aln" "$work"; do
  run_limited 60 "$SISSIZ" --seed 1 -n 5 "$f" >/dev/null 2>&1; rc=$?
  if [ "$rc" -eq 0 ] || [ "$rc" -gt 128 ]; then
    echo "FAIL: '$f' gave exit $rc" >&2; status=1
  else
    note "$(basename "$f"): exit $rc"
  fi
done
exit $status
