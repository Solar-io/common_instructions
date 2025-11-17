import { NextRequest } from 'next/server';
import { encodeSSE, sseHeaders } from '../../../lib/sse';

export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const runId = searchParams.get('runId');
  if (!runId) {
    return new Response('Missing runId', { status: 400 });
  }

  const stream = new ReadableStream({
    start(controller) {
      // Example boot events
      controller.enqueue(encodeSSE('event', { type: 'PLAN', runId, payload: { steps: [] } }));
      // Simulate streaming tokens
      const tokens = ['Hello', ',', ' ', 'world', '!'];
      let i = 0;
      const interval = setInterval(() => {
        if (i < tokens.length) {
          controller.enqueue(encodeSSE('token', { runId, text: tokens[i++] }));
        } else {
          clearInterval(interval);
          controller.enqueue(encodeSSE('event', { type: 'DONE', runId }));
          controller.close();
        }
      }, 250);
    },
  });

  return new Response(stream, { headers: sseHeaders() });
}

