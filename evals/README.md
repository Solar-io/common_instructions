# Evals

Structure
- datasets/
  - golden/*.jsonl — core tasks
  - regression/*.jsonl — bugs turned tests
  - stress/*.jsonl — long/context tasks
- runs/
  - YYYY-MM-DD/*.json — results

Runner (concept)
- `node scripts/evals-run.js --dataset datasets/golden/*.jsonl --out runs/$(date +%F)/golden.json`
- Records runIds and, if enabled, fixtures to `fixtures/runs/<runId>`.

Notes
- Gate merges on no regressions in golden set; require sign-off on any safety flags.

