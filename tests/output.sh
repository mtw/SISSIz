#!/bin/sh
# stdout must carry the result line and nothing else, in every mode.
# A stray debug print here corrupts every downstream parser.
. "${srcdir:-.}/common.sh"

status=0
for args in "-n 20" "-i -n 20" "-t -n 10" "-r -n 20"; do
  out=$(run_limited 120 "$SISSIZ" --seed 77 $args "$DATA/multi.aln" 2>/dev/null)
  lines=$(printf '%s\n' "$out" | grep -c .)
  if [ "$lines" -ne 1 ]; then
    echo "FAIL: '$args' wrote $lines lines to stdout, expected 1:" >&2
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    status=1; continue
  fi
  nf=$(printf '%s\n' "$out" | awk -F'\t' '{print NF}')
  [ "$nf" -eq 11 ] || { echo "FAIL: '$args' result line has $nf fields, expected 11" >&2; status=1; continue; }
  case $(field 1 "$out") in
    sissiz-di|sissiz-mono) ;;
    *) echo "FAIL: '$args' first field is not a model tag: $(field 1 "$out")" >&2; status=1;;
  esac
  note "$args: 1 line, 11 fields"
done
exit $status
