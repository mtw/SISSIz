#!/bin/sh
# The help screen and the option parser must agree.  --help used to advertise
# --num-regression, which the parser did not accept, while --nossr and --gamma
# worked but were undocumented.
. "${srcdir:-.}/common.sh"

GGO="${srcdir:-.}/../src/cmdline_sissiz.ggo"
status=0

help=$("$SISSIZ" -h 2>&1)
[ -n "$help" ] || fail "no help output"

# every long option the help advertises must be accepted by the parser
for o in $(printf '%s\n' "$help" | grep -oE '\-\-[a-zA-Z][a-zA-Z-]*' | sort -u); do
  # </dev/null: with no file argument SISSIz would read stdin and block
  err=$(run_limited 20 "$SISSIZ" "$o" </dev/null 2>&1 >/dev/null)
  case "$err" in
    *unrecognized*) echo "FAIL: help advertises $o but the parser rejects it" >&2; status=1;;
    *) note "$o accepted";;
  esac
done

# and every option the parser defines must appear in the help
if [ -r "$GGO" ]; then
  for o in $(grep -oE '^option +"[a-zA-Z][a-zA-Z-]*"' "$GGO" | sed 's/.*"\(.*\)"/\1/' | sort -u); do
    case "$help" in
      *"--$o"*) ;;
      *) echo "FAIL: --$o is accepted but not documented in --help" >&2; status=1;;
    esac
  done
  note "checked against $(basename "$GGO")"
else
  note "gengetopt spec not present, skipped the reverse check"
fi
exit $status
