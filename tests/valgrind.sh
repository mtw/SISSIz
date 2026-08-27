#!/bin/sh
# Run the shipped alignments through valgrind and fail on any leak that is
# not in valgrind.supp.  Skips unless valgrind is installed and the binary
# was built with debug info; "make check-valgrind" arranges both.
. "${srcdir:-.}/common.sh"

if [ "${SISSIZ_VALGRIND:-0}" != "1" ]; then
  echo "SKIP: set SISSIZ_VALGRIND=1 or use: make check-valgrind"
  exit 77
fi
if ! command -v valgrind >/dev/null 2>&1; then
  echo "SKIP: valgrind not installed"
  exit 77
fi

# Absolute paths: the checks below run from a scratch directory, because
# --print-tree and --print-rates write aln.tree and rates.dat into the
# current directory and would otherwise litter the build tree.
SUPP=$(cd "$(dirname "${srcdir:-.}/valgrind.supp")" && pwd)/valgrind.supp
BIN=$(cd "$(dirname "$SISSIZ")" && pwd)/$(basename "$SISSIZ")
DATADIR=$(cd "$DATA" && pwd)
EXAMPLES=$(cd "$DATA/../../examples" && pwd)

work=$(mktemp -d "${TMPDIR:-/tmp}/sissiz-vg.XXXXXX") || fail "cannot create work directory"
trap 'rm -rf "$work"' EXIT INT TERM

status=0
check() {
  desc=$1; shift
  log="$work/$(printf '%s' "$desc" | tr ' /.=-' '_____').log"
  ( cd "$work" && valgrind --leak-check=full --show-leak-kinds=definite,indirect \
           --suppressions="$SUPP" --log-file="$log" \
           "$BIN" "$@" >/dev/null 2>&1 )
  def=$(sed -n 's/.*definitely lost: *\([0-9,]*\) bytes.*/\1/p' "$log" | tail -1 | tr -d ,)
  ind=$(sed -n 's/.*indirectly lost: *\([0-9,]*\) bytes.*/\1/p' "$log" | tail -1 | tr -d ,)
  bad=$(grep -cE '^==[0-9]+== (Invalid|Conditional jump|Use of uninitialised|Mismatched|Source and destination)' "$log")
  if [ "${def:-0}" != "0" ] || [ "${ind:-0}" != "0" ] || [ "$bad" -ne 0 ]; then
    echo "FAIL: $desc leaked ${def:-?} direct / ${ind:-?} indirect bytes, $bad memory errors" >&2
    grep -A6 'lost in loss record' "$log" | head -20 | sed 's/^/    /' >&2
    status=1
  else
    note "$desc: clean"
  fi
}

check "rRNA di"        --seed 1 -n 5 "$EXAMPLES/rRNA.aln"
check "rRNA mono"      --seed 1 -i -n 5 "$EXAMPLES/rRNA.aln"
check "rRNA tstv"      --seed 1 -t -n 3 "$EXAMPLES/rRNA.aln"
check "genomic maf"    --seed 1 -n 5 "$EXAMPLES/genomic.maf"
check "pair"           --seed 1 -n 5 "$DATADIR/pair.aln"
check "ambiguous"      --seed 1 -n 5 "$DATADIR/ambiguous.aln"
check "degenerate"     --seed 1 -n 5 "$DATADIR/degenerate.aln"
check "simulate"       --seed 1 -s -n 3 "$DATADIR/multi.aln"
check "tree and rates" --seed 1 -b -x -n 5 "$DATADIR/multi.aln"
check "many samples"   --seed 2 -n 100 "$DATADIR/multi.aln"
exit $status
