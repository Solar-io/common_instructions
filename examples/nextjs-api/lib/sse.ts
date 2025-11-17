export function sseHeaders() {
  return new Headers({
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache, no-transform',
    Connection: 'keep-alive',
  });
}

export function encodeSSE(event: string, data: unknown) {
  const payload = typeof data === 'string' ? data : JSON.stringify(data);
  return `event: ${event}\n` + `data: ${payload}\n\n`;
}

