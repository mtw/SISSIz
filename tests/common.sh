# Shared helpers for the SISSIz test suite.  Sourced by every test.

: "${srcdir:=.}"
: "${top_builddir:=..}"

SISSIZ="${top_builddir}/src/SISSIz"
DATA="${srcdir}/data"

if [ ! -x "$SISSIZ" ]; then
  echo "SKIP: $SISSIZ not built"
  exit 77
fi

fail() { echo "FAIL: $*" >&2; exit 1; }
note() { echo "  $*"; }

# run_limited SECONDS CMD...   -- portable stand-in for timeout(1)
run_limited() {
  _limit=$1; shift
  "$@" & _pid=$!
  # the watchdog must not inherit stdout, or it holds the caller's
  # command substitution open for the whole timeout
  ( sleep "$_limit"; kill -9 "$_pid" 2>/dev/null ) >/dev/null 2>&1 </dev/null & _watch=$!
  wait "$_pid"; _rc=$?
  kill "$_watch" 2>/dev/null
  wait "$_watch" 2>/dev/null
  return $_rc
}

# field N LINE  -- extract tab separated field N (1 based) from the result line
field() { printf '%s\n' "$2" | awk -F'\t' -v n="$1" '{print $n}'; }

# close A B TOL -- true when |A-B| <= TOL
close() {
  awk -v a="$1" -v b="$2" -v t="$3" 'BEGIN{d=a-b; if(d<0)d=-d; exit !(d<=t)}'
}

# result FILE ARGS... -- run SISSIz and echo the final tab separated line
result() {
  _f=$1; shift
  run_limited 120 "$SISSIZ" "$@" "$_f" 2>/dev/null | tail -1
}
