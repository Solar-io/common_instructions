# Next.js API Stubs (App Router)

Purpose
- Minimal `/api/chat` and `/api/stream` to orchestrate a run and stream SSE events.
- Provider calls not wired; focus is request/stream scaffolding and runId handling.

Usage
- Place under a Next.js app (App Router). Files assume TypeScript.
- API routes:
  - `app/api/chat/route.ts`
  - `app/api/stream/route.ts`
- Utility:
  - `lib/sse.ts`

