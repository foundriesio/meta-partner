# Device test reports

Per-release validation evidence for the FoundriesFactory LmP device test plans.
The reusable test *procedure* (plans, interface scripts, helpers) lives in
[`../test-plan/`](../test-plan/); this tree holds the *outputs* of running it.

## Layout

Reports are keyed by **LmP release line** (`test-reports/<lmp-release>/`). The
machine name is encoded in every filename, so artifacts sit flat under the
release folder — no per-machine subdirectories.

```
test-reports/<lmp-release>/                      # e.g. lmp-v96
  test-record-<machine>-<datetime>.md            # headline Phase 1–6 outcome (plan §6.4)
  interface-test-results-<machine>-<datetime>.md # full Phase 6 sweep
  interface-test-summary-<machine>-<datetime>.md # per-interface roll-up
  phase{1,3,4,5}-result-<machine>-<datetime>.md  # per-phase evidence
  baseline-<machine>-<datetime>.txt              # §0/§1.1 pre-test baseline
  serial-<datetime>.log                          # git-ignored — local evidence only
```

## Index

| Release | Board | Date | Validated target | Phases 1–6 | Interface sweep | Verdict | Test record |
|---|---|---|---|---|---|---|---|

_One row per completed run. The test-record is the authoritative artifact; the
results / summary / phase / baseline files are supporting evidence._
