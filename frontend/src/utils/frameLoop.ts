interface FrameLoopOptions {
  minIntervalMs?: number;
}

export function startFrameLoop(tick: () => void, options: FrameLoopOptions = {}) {
  const minIntervalMs = options.minIntervalMs ?? 0;
  let frameId: number | null = null;
  let lastTickAt = 0;
  let stopped = false;

  const frame = (timestamp: number) => {
    if (stopped) return;

    if (!lastTickAt || timestamp - lastTickAt >= minIntervalMs) {
      lastTickAt = timestamp;
      tick();
    }

    frameId = requestAnimationFrame(frame);
  };

  frameId = requestAnimationFrame(frame);

  return () => {
    stopped = true;
    if (frameId !== null) cancelAnimationFrame(frameId);
  };
}
