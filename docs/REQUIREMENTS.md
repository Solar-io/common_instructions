# Requirements (Project-Level Selections)

Purpose

- Capture baseline choices

Defaults

- Framework: Next.js (App Router)
- UI Kit: shadcn/ui (+ Radix + Tailwind)
- Icon Pack: Lucide (or Heroicons via React Icons)
- Database: SQLite (portable, zero-setup)

Selections (configure in `config/project.yml`)

- framework: `nextjs`
- ui_kit: `shadcn` | `mui` | `mantine` | `chakra` | `headless` | `nextui` | `ant` | `flowbite` | `daisyui` | `primereact`
- icon_pack: `lucide` | `radix-icons` | `heroicons` | `fontawesome` | `streamline` | `react-icons` | `phosphor` | `feather` | `iconify`
- database: `sqlite` | `postgres`

Non-Functional

- Portability: local, minimal setup; no background services required by default.
- Recoverability: snapshot tags hourly and end-of-session; restore branches.
- Observability: per-run IDs with token/latency counters; logs persisted locally.
- Accessibility: WCAG AA; keyboard-first; reduced motion support.

Providers & IDE Assistants

- IDE tools: GitHub Copilot, Claude Code, OpenAI Chat in VS Code. When using these:
  - Keep changes small and focused; run snapshots before large edits.
  - Update `docs/PROJECT_STATUS.md`, `docs/TASKS.md`, and logs during the session.
  - Ensure provider keys set in `.env` as needed.

Environment

- Copy `.env.example` to `.env` and fill relevant keys.
