export interface PhaseDefinition {
  id: number;
  name: string;
  description: string;
  difficulty: string;
  ringMin: number;
  ringMax: number;
  baseHp: number;
  closingSpeed: number;
  rotationSpeed: number;
  gapSize: number;
  rewardCoins: number;
  rewardXp: number;
  keyChance: number;
  chestChance: number;
  color: string;
}

const colors = ['#00f0ff', '#b000ff', '#ff0055', '#00ff88', '#ffd700', '#ff8800', '#ff4fd8', '#60a5fa'];

const tierForPhase = (id: number) => {
  if (id <= 5) return { min: 8, max: 16, hp: 12, close: 0.018, rotate: 0.0045, gap: 2.4, name: 'Normal', desc: 'Arena inicial com aberturas grandes e pressão baixa.' };
  if (id <= 10) return { min: 16, max: 24, hp: 34, close: 0.03, rotate: 0.007, gap: 2.75, name: 'Difícil', desc: 'Rotação alternada e anéis um pouco mais resistentes.' };
  if (id <= 20) return { min: 24, max: 36, hp: 68, close: 0.045, rotate: 0.01, gap: 3.15, name: 'Avançado', desc: 'Mais padrões, aberturas menores e anéis resistentes.' };
  if (id <= 30) return { min: 36, max: 50, hp: 128, close: 0.067, rotate: 0.014, gap: 3.55, name: 'Extremo', desc: 'Arena exigente para skins e upgrades mais fortes.' };
  if (id <= 40) return { min: 50, max: 65, hp: 220, close: 0.092, rotate: 0.019, gap: 4.05, name: 'Insano', desc: 'Padrões complexos, fechamento perigoso e melhores baús.' };
  return { min: 65, max: 80, hp: 340, close: 0.12, rotate: 0.025, gap: 4.6, name: 'Ultimate', desc: 'Arena premium com rotação intensa, justa e recompensas altas.' };
};

export const PHASES: PhaseDefinition[] = Array.from({ length: 50 }, (_, index) => {
  const id = index + 1;
  const tier = tierForPhase(id);
  const tierStart = id <= 5 ? 1 : id <= 10 ? 6 : id <= 20 ? 11 : id <= 30 ? 21 : id <= 40 ? 31 : 41;
  const tierEnd = id <= 5 ? 5 : id <= 10 ? 10 : id <= 20 ? 20 : id <= 30 ? 30 : id <= 40 ? 40 : 50;
  const t = (id - tierStart) / Math.max(1, tierEnd - tierStart);
  const ringMin = Math.round(tier.min + (tier.max - tier.min) * t * 0.72);
  const ringMax = Math.round(tier.min + (tier.max - tier.min) * Math.min(1, t + 0.22));

  return {
    id,
    name: `Fase ${id}`,
    description: id === 1 ? 'Primeira arena neon com aberturas grandes.' : tier.desc,
    difficulty: tier.name,
    ringMin,
    ringMax: Math.max(ringMin + 2, ringMax),
    baseHp: Math.round(tier.hp + id * 6 + Math.pow(id, 1.32) * 5.2),
    closingSpeed: Math.min(0.18, tier.close + t * 0.025 + id * 0.0011),
    rotationSpeed: Math.min(0.048, tier.rotate + t * 0.0065 + id * 0.00034),
    gapSize: Math.max(Math.PI / 9.5, Math.PI / (tier.gap + t * 0.82)),
    rewardCoins: Math.round(70 + id * 36 + Math.pow(id, 1.18) * 6),
    rewardXp: Math.round(45 + id * 22 + Math.pow(id, 1.12) * 4),
    keyChance: Math.min(0.34, 0.025 + id * 0.0058),
    chestChance: Math.min(0.25, 0.015 + id * 0.0044),
    color: colors[index % colors.length],
  };
});

export const getPhaseConfig = (phaseId: number) => PHASES[Math.max(0, Math.min(PHASES.length - 1, phaseId - 1))] || PHASES[0];
