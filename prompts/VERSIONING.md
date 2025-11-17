# Prompt Versioning

Goals
- Ensure reproducibility and clear provenance for changes to system and task prompts.

Practices
- Store prompts as individual files under `prompts/` (one per role/task).
- Include a short header comment with purpose and optional semantic version.
- On changes that may affect behavior, bump the version note and reference an ADR if relevant.

Hashing
- Compute a content hash (e.g., SHA-256) of the prompt text and tool schema; include this hash in run events for traceability.
- Record the hash in experiment logs when measuring prompt changes.

Linkage
- Reference prompt filenames and hashes in `docs/EXPERIMENTS.md` entries.
- Record prompt changes in `docs/DECISIONS.md` when adopted.

