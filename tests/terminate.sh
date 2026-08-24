#!/bin/sh
# Inputs the model cannot handle must be rejected, not spun on forever.
# Deliberately avoids --seed so that a binary lacking it still reaches the
# code under test instead of bailing out on the command line.
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
check_terminates "unreachable --precision" 90 -s -p 0.0001 -n 5 "$DATA/multi.aln"
exit $status
