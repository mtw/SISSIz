#!/bin/sh
# Inputs the model cannot handle must be rejected, not spun on forever.
# Avoids --seed so the run reaches the code under test either way.
. "${srcdir:-.}/common.sh"

status=0

check_terminates() {
  desc=$1; limit=$2; shift 2
  err=$( { run_limited "$limit" "$SISSIZ" "$@" >/dev/null; } 2>&1 ); rc=$?
  if [ "$rc" -eq 137 ] || [ "$rc" -eq 9 ]; then
    echo "FAIL: $desc did not terminate within ${limit}s" >&2; status=1; return
  fi
  if [ "$rc" -eq 0 ]; then
    echo "FAIL: $desc exited 0, expected an error" >&2; status=1; return
  fi
  if [ -z "$err" ]; then
    echo "FAIL: $desc exited $rc without any message on stderr" >&2; status=1; return
  fi
  note "$desc: exit $rc, $(printf '%s' "$err" | head -1 | cut -c1-70)"
}

check_terminates "degenerate alignment" 60 -n 5 "$DATA/degenerate.aln"

# near-identical sequences can zero the expected substitution rate; the
# normaliser then made the rate matrix infinite and the waiting time per
# proposal exactly zero, so the mutation loop never advanced
printf 'CLUSTAL W(1.81)\n\n\n%-12s%s\n%-12s%s\n%-12s%s\n%-12s%s\n' \
    a ACGTACGT b ACGTACGT c ACGTACGT d ACGTACGA > "${TMPDIR:-/tmp}/sissiz-inf.aln"
check_terminates "infinite-rate alignment" 60 --simulate -n 1 -m 1 "${TMPDIR:-/tmp}/sissiz-inf.aln"
rm -f "${TMPDIR:-/tmp}/sissiz-inf.aln"
check_terminates "unreachable --precision" 90 -s -p 0.0001 -n 5 "$DATA/multi.aln"
exit $status
