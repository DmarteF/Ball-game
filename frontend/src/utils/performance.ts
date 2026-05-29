export const GAME_FPS_OPTIONS = [30, 45, 60, 90, 120] as const;
export const DISPLAY_HZ_OPTIONS = [60, 90, 120, 144] as const;

export type GameFpsOption = typeof GAME_FPS_OPTIONS[number];
export type DisplayHzOption = typeof DISPLAY_HZ_OPTIONS[number];

export interface PerformanceSettings {
  gameFps: GameFpsOption;
  displayHz: DisplayHzOption;
}

export const DEFAULT_PERFORMANCE_SETTINGS: PerformanceSettings = {
  gameFps: 60,
  displayHz: 60,
};

export const normalizeGameFps = (value: unknown): GameFpsOption =>
  GAME_FPS_OPTIONS.includes(value as GameFpsOption) ? value as GameFpsOption : DEFAULT_PERFORMANCE_SETTINGS.gameFps;

export const normalizeDisplayHz = (value: unknown): DisplayHzOption =>
  DISPLAY_HZ_OPTIONS.includes(value as DisplayHzOption) ? value as DisplayHzOption : DEFAULT_PERFORMANCE_SETTINGS.displayHz;

export const normalizePerformanceSettings = (settings?: Partial<PerformanceSettings>): PerformanceSettings => ({
  gameFps: normalizeGameFps(settings?.gameFps),
  displayHz: normalizeDisplayHz(settings?.displayHz),
});

export const getPerformanceFrameIntervalMs = (settings?: Partial<PerformanceSettings>) => {
  const normalized = normalizePerformanceSettings(settings);
  const effectiveFps = Math.max(1, Math.min(normalized.gameFps, normalized.displayHz));
  return 1000 / effectiveFps;
};
