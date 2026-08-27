#!/bin/sh
# Sweep every fixture through every mode and fail on any sanitizer report.
# Use "make check-asan".
. "${srcdir:-.}/common.sh"

if ! nm "$SISSIZ" 2>/dev/null | grep -q '__asan\|__ubsan'; then
  echo "SKIP: $SISSIZ was not built with -fsanitize (use: make check-asan)"
  exit 77
fi

ASAN_OPTIONS=detect_leaks=0
UBSAN_OPTIONS=print_stacktrace=1
export ASAN_OPTIONS UBSAN_OPTIONS

status=0
runs=0

for f in "$DATA"/multi.aln "$DATA"/pair.aln "$DATA"/skewed.aln \
         "$DATA"/ambiguous.aln "$DATA"/degenerate.aln "$DATA"/multi.maf; do
  for args in "-n 5" "-i -n 5" "-t -n 3" "-r -n 5" "-s -n 2" \
              "-s -n 1 --maf" "-s -n 1 --fasta"; do
    out=$(run_limited 180 "$SISSIZ" --seed 31 $args "$f" 2>&1)
    runs=$((runs+1))
    hits=$(printf '%s\n' "$out" | grep -cE 'AddressSanitizer|runtime error|LeakSanitizer')
    if [ "$hits" -ne 0 ]; then
      echo "FAIL: $(basename "$f") $args" >&2
      printf '%s\n' "$out" | grep -E 'AddressSanitizer|runtime error|SUMMARY|#[0-9] ' | head -8 | sed 's/^/    /' >&2
      status=1
    fi
  done
done

note "$runs invocations swept, no sanitizer reports"
exit $status
