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

export const PHASES: PhaseDefinition[] = Array.from({ length: 20 }, (_, index) => {
  const id = index + 1;
  const ringMin =
    id <= 5 ? 8 + (id - 1) * 2 :
    id <= 10 ? 18 + Math.floor((id - 6) * 1.5) :
    id <= 15 ? 24 + Math.floor((id - 11) * 2) :
    32 + Math.floor((id - 16) * 2.5);
  const ringMax = id <= 20 ? Math.min(45, ringMin + (id < 6 ? 2 : id < 11 ? 4 : id < 16 ? 6 : 8)) : ringMin + 3;

  return {
    id,
    name: `Fase ${id}`,
    description:
      id === 1 ? 'Primeira arena neon com aberturas grandes.' :
      id <= 5 ? 'Progressão inicial com anéis mais resistentes.' :
      id <= 10 ? 'Rotação variada e fechamento médio.' :
      id <= 15 ? 'Aberturas menores e padrões alternados.' :
      'Arena avançada com pressão intensa.',
    difficulty: id <= 3 ? 'Normal' : id <= 8 ? 'Difícil' : id <= 15 ? 'Extremo' : 'Insano',
    ringMin,
    ringMax,
    baseHp: Math.round(14 + id * 8 + Math.pow(id, 1.45) * 4),
    closingSpeed: Math.min(0.145, 0.02 + id * 0.0048),
    rotationSpeed: Math.min(0.034, 0.005 + id * 0.00135),
    gapSize: Math.max(Math.PI / 7.2, Math.PI / (2.55 + id * 0.105)),
    rewardCoins: 70 + id * 28,
    rewardXp: 45 + id * 18,
    keyChance: Math.min(0.24, 0.035 + id * 0.008),
    chestChance: Math.min(0.16, 0.018 + id * 0.006),
    color: colors[index % colors.length],
  };
});

export const getPhaseConfig = (phaseId: number) => PHASES[Math.max(0, Math.min(19, phaseId - 1))] || PHASES[0];
