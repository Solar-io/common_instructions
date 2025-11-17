# Fixtures — Deterministic Replays

Structure
- fixtures/
  - runs/
    - <runId>/
      - toolcalls/
        - 001_http.fetch.json
        - 002_fs.read.json
      - events.jsonl  # optional: serialized event stream
      - summary.json  # captured RunSummary

Notes
- Redact secrets using patterns in `config/project.yml` → `replay.redact_patterns`.
- When replaying, tool calls are stubbed from `toolcalls/*.json` in order.

