import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  const body = await req.json();
  // Validate minimal shape
  const runId = `run_${Date.now()}`;

  // TODO: persist initial events to SQLite, enqueue orchestration work
  // For now, return runId for the client to connect to SSE stream
  return NextResponse.json({ runId });
}

