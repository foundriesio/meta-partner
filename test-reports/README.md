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
| lmp-v96 | imx8mm-evk | 2026-05-19 | `imx8mm-lpddr4-evk-lmp-20` | PASS | 88P / 4F / 20I / 12S | ✅ PASS (4 FAIL = headless caveats) | [test-record](lmp-v96/test-record-imx8mm-evk-20260519T013643Z.md) |
| lmp-v96 | imx8mn-evk | 2026-05-19 | `imx8mn-ddr4-evk-lmp-20` | PASS | 85P / 4F / 21I / 10S | ✅ PASS (4 FAIL = headless caveats) | [test-record](lmp-v96/test-record-imx8mn-evk-20260519T013643Z.md) |
| lmp-v96 | imx8mp-evk | 2026-05-19 | `imx8mp-lpddr4-evk-lmp-20` | PASS | 98P / 2F / 18I / 11S | ✅ PASS (2 FAIL = headless caveats) | [test-record](lmp-v96/test-record-imx8mp-evk-20260519T013643Z.md) |
| lmp-v96 | imx8mq-evk | 2026-05-19 | `imx8mq-evk-lmp-20` | PASS | 89P / 1F / 26I / 10S | ✅ PASS (1 FAIL = RF-env caveat) | [test-record](lmp-v96/test-record-imx8mq-evk-20260519T013643Z.md) |

_One row per completed run. The test-record is the authoritative artifact; the
results / summary / phase / baseline files are supporting evidence._
