# Changelog

## 0.2.0

Results change with this release. Two of the fixes below alter the numbers
SISSIz reports, so anything produced with an earlier version should be
regenerated rather than compared.

### Model and scoring

* Pairwise alignments were scored against a degenerate null model. The
  two-taxon Newick string was written with `%.f`, so any divergence below 0.5
  rounded to a zero branch length and every sampled alignment came back
  identical to its ancestor. On 40 pairwise Rfam alignments the sampled mean
  pairwise identity was 1.0000 against an input mean of 0.7960. Correcting it
  shifts the mean z-score by -2.01 and raises detection at z < -2 from 47.5%
  to 70%.

* Simulated time advanced only when a proposed substitution was accepted,
  which pinned the substitution rate at one per site per unit branch length
  whatever the composition. Time now advances on every proposal of the
  uniformised jump chain. Drawing 200 alignments from SISSIz's own null model
  and scoring them, the mean z-score moves from +0.292 to +0.060 on an AT-rich
  alignment. Strongly skewed input also runs more than ten times faster.

* Ambiguity codes were counted as adenine. The nucleotide map defaulted to
  zero, so N, R and Y alike fed the model an A; a test case that is 12.5% N
  reported an A frequency of 0.6. They are now left out of the model, with a
  warning giving the count.

* `--nossr` did nothing. Site-specific rates were installed before the flag
  was tested, so the second regression round used them anyway.

* The site-rate adjustment divided by zero when every site exceeded the
  maximum divergence. The singular-matrix check in phyml read
  `!Matinv(...)<0`, which is always false.

### Robustness

* A composition skewed enough to zero every triplet exit rate yielded a rate
  matrix of zeros and a mutation loop that never terminated. Such input is now
  refused with a message.

* Ragged sequence lengths hung the tool. The readers signal a malformed
  alignment by returning 0 and that return value was ignored, leaving the
  alignment half-read.

* Fixed a heap buffer overflow. MAF sequence names have no length limit but
  were copied into phyml's 100-byte name buffer.

* The Newick buffer was a fixed 10 kB on the stack; a 400-taxon tree needs
  about 15 kB. It is now sized from the alignment.

* The `--precision` filter leaked every rejected alignment and retried
  forever, roughly 28 MB per second. Rejected samples are freed and the
  retries are capped.

* Plugged three leaks. `rateT2` released the pointer array of its scratch
  matrix but none of the 64 rows behind it, `treeML` never tore down phyml's
  tree and distance matrix, and `main` held on to the Newick buffer and the
  sampled identities.

* The cumulative scans in `choosenuc` and `cchoosetriplet` ran past the end of
  their probability arrays whenever rounding left the running sum just short
  of the drawn value.

* Out-of-range values for `--num-samples`, `--precision`,
  `--num-samples-regression` and `--gamma` used to run to completion and
  report nan, or a z-score of zero, which reads as "not significant".

### Random numbers

* New `--seed` option. The same seed on the same input reproduces a run
  exactly.

* The default seed is taken from system entropy. `time(NULL)` has one-second
  resolution, so screens launching many jobs at once drew identical sample
  sets.

* `start_kiss` seeded only `x` and left `y`, `z` and `w` on the same
  trajectory in every run, so different seeds gave streams differing by
  nothing but the LCG component. All four state words are now mixed from the
  seed.

### Build and tests

* Fixed compilation with current compilers. Empty parameter lists mean
  `(void)` in C23, and a plain `inline` definition emits no external symbol
  under C99 rules.

* The bundled archives are linked by path, so an installed ViennaRNA in an
  earlier `-L` directory no longer satisfies `-lRNA`.

* `configure` appends `-O2` when `CFLAGS` carries no `-O` flag. A `CFLAGS`
  inherited from the environment suppressed the `-g -O2` that `AC_PROG_CC`
  would otherwise supply, and cost a factor of 2.3 in runtime.

* New test suite. `make check` runs the functional tests, `make check-asan`
  rebuilds under AddressSanitizer and UndefinedBehaviorSanitizer,
  `make check-valgrind` sweeps the shipped alignments for leaks, and
  `make check-stats` checks that the null z-scores are centred. GitHub Actions
  runs all of it on Linux and macOS with both gcc and clang.

* `--help` advertised `--num-regression`, which does not exist, and left out
  `--nossr` and `--gamma`, which do.

* The output field list in the README omitted the alignment length, so every
  field after it was numbered one too low.

* `--num-samples-regression` now defaults to 50 rather than 10. This does not
  change the typical run-to-run spread of the z-score, which stays near 0.2,
  but large excursions become rarer: over 80 alignments scored twice, the
  share of runs differing by more than 2 fell from 6% to 1%, for about 12%
  more runtime. Nothing further is gained above 50.
