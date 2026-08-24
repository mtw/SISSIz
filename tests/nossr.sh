#!/bin/sh
# --nossr must actually change the model, not just the command line.
. "${srcdir:-.}/common.sh"

with=$(run_limited 120 "$SISSIZ" --seed 5150 -v -n 10 "$DATA/multi.aln" 2>/dev/null)
without=$(run_limited 120 "$SISSIZ" --seed 5150 -v -r -n 10 "$DATA/multi.aln" 2>/dev/null)

printf '%s\n' "$with"    | grep -q "with SSRs" || fail "default run did not do the SSR regression"
printf '%s\n' "$without" | grep -q "with SSRs" && fail "--nossr still ran the SSR regression"
note "--nossr skips the second regression"

a=$(printf '%s\n' "$with"    | grep '^sissiz' | tail -1)
b=$(printf '%s\n' "$without" | grep '^sissiz' | tail -1)
[ "$a" != "$b" ] || fail "--nossr gave a bit identical result to the default, the flag does nothing"
note "--nossr changes the result"
