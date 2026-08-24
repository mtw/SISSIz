#!/bin/sh
# Out of range options must be refused, not silently turned into nan.
. "${srcdir:-.}/common.sh"

status=0
check_rejected() {
  desc=$1; shift
  out=$(run_limited 60 "$SISSIZ" "$@" "$DATA/multi.aln" 2>&1); rc=$?
  if [ "$rc" -eq 0 ]; then
    echo "FAIL: $desc was accepted (exit 0): $(printf '%s' "$out" | tail -1)" >&2; status=1
  else
    note "$desc rejected"
  fi
}

check_rejected "--num-samples 0"  -n 0
check_rejected "--num-samples 1"  -n 1
check_rejected "--num-samples -5" -n -5
check_rejected "--precision 0"    -p 0
check_rejected "--num-regression 0" -m 0
check_rejected "--gamma 0"        -g 0

# and a valid run must still work
line=$(result "$DATA/multi.aln" --seed 1 -n 20)
[ -n "$line" ] || fail "a valid invocation stopped working"
case "$line" in *nan*|*NaN*) fail "valid run reported nan: $line";; esac
note "valid run clean: $line"
exit $status
