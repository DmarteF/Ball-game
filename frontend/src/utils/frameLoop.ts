interface FrameLoopOptions {
  minIntervalMs?: number;
  physicsStepMs?: number;
  maxDeltaSteps?: number;
}

export function startFrameLoop(tick: (deltaSteps: number) => void, options: FrameLoopOptions = {}) {
  const minIntervalMs = options.minIntervalMs ?? 0;
  const physicsStepMs = options.physicsStepMs ?? 1000 / 60;
  const maxDeltaSteps = options.maxDeltaSteps ?? 3;
  let frameId: number | null = null;
  let lastTickAt = 0;
  let stopped = false;

  const frame = (timestamp: number) => {
    if (stopped) return;

    if (!lastTickAt || timestamp - lastTickAt >= minIntervalMs) {
      const elapsedMs = lastTickAt ? Math.max(0, timestamp - lastTickAt) : physicsStepMs;
      lastTickAt = timestamp;
      tick(Math.min(maxDeltaSteps, Math.max(0.5, elapsedMs / physicsStepMs || 1)));
    }

    frameId = requestAnimationFrame(frame);
  };

  frameId = requestAnimationFrame(frame);

  return () => {
    stopped = true;
    if (frameId !== null) cancelAnimationFrame(frameId);
  };
}
