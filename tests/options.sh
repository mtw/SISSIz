#!/bin/sh
# The help screen and the option parser must agree, in both directions.
. "${srcdir:-.}/common.sh"

GGO="${srcdir:-.}/../src/cmdline_sissiz.ggo"
status=0

# --print-tree and --print-rates open their files while the options are
# parsed, so probe from a scratch directory.
BIN=$(cd "$(dirname "$SISSIZ")" && pwd)/$(basename "$SISSIZ")
work=$(mktemp -d "${TMPDIR:-/tmp}/sissiz-opt.XXXXXX") || fail "cannot create work directory"
trap 'rm -rf "$work"' EXIT INT TERM

help=$("$SISSIZ" -h 2>&1)
[ -n "$help" ] || fail "no help output"

# every long option the help advertises must be accepted by the parser
for o in $(printf '%s\n' "$help" | grep -oE '\-\-[a-zA-Z][a-zA-Z-]*' | sort -u); do
  # </dev/null: with no file argument SISSIz would read stdin and block
  err=$(cd "$work" && run_limited 20 "$BIN" "$o" </dev/null 2>&1 >/dev/null)
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
