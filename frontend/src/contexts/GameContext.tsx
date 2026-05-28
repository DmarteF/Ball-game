import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import { storage } from '@/src/utils/storage';

const API_URL = process.env.EXPO_PUBLIC_BACKEND_URL;

interface GameStats {
  baseDamage: number;
  baseSpeed: number;
  critChance: number;
  critMultiplier: number;
  coinMultiplier: number;
  xpMultiplier: number;
}

interface GameContextType {
  playerId: string | null;
  coins: number;
  gems: number;
  currentPhase: number;
  unlockedPhases: number[];
  permanentUpgrades: Record<string, number>;
  ballTransformation: string;
  stats: GameStats;
  loading: boolean;
  initializePlayer: () => Promise<void>;
  updateCoins: (amount: number) => Promise<void>;
  updateGems: (amount: number) => Promise<void>;
  unlockPhase: (phaseId: number) => Promise<void>;
  purchaseUpgrade: (upgradeName: string, cost: number) => Promise<boolean>;
  setBallTransformation: (transformationId: string) => Promise<void>;
  saveProgress: () => Promise<void>;
}

const GameContext = createContext<GameContextType | undefined>(undefined);

export const GameProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [playerId, setPlayerId] = useState<string | null>(null);
  const [coins, setCoins] = useState(0);
  const [gems, setGems] = useState(0);
  const [currentPhase, setCurrentPhase] = useState(1);
  const [unlockedPhases, setUnlockedPhases] = useState<number[]>([1]);
  const [permanentUpgrades, setPermanentUpgrades] = useState<Record<string, number>>({});
  const [ballTransformation, setBallTransformationState] = useState('neon_blue');
  const [stats, setStats] = useState<GameStats>({
    baseDamage: 10.0,
    baseSpeed: 100.0,
    critChance: 5.0,
    critMultiplier: 2.0,
    coinMultiplier: 1.0,
    xpMultiplier: 1.0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    initializePlayer();
  }, []);

  const initializePlayer = async () => {
    try {
      setLoading(true);
      // Try to load existing player ID
      const savedPlayerId = await storage.getItem('playerId');
      
      if (savedPlayerId) {
        // Load player data from backend
        const response = await axios.get(`${API_URL}/api/player/${savedPlayerId}`);
        const playerData = response.data;
        
        setPlayerId(playerData.playerId);
        setCoins(playerData.coins || 0);
        setGems(playerData.gems || 0);
        setCurrentPhase(playerData.currentPhase || 1);
        setUnlockedPhases(playerData.unlockedPhases || [1]);
        setPermanentUpgrades(playerData.permanentUpgrades || {});
        setBallTransformationState(playerData.ballTransformation || 'neon_blue');
        setStats(playerData.stats || stats);
      } else {
        // Create new player
        const newPlayerId = `player_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
        const newPlayer = {
          playerId: newPlayerId,
          coins: 1000, // Starting coins
          gems: 5000, // Starting gems for testing
          currentPhase: 1,
          unlockedPhases: [1],
          permanentUpgrades: {},
          ballTransformation: 'neon_blue',
          stats: {
            baseDamage: 10.0,
            baseSpeed: 100.0,
            critChance: 5.0,
            critMultiplier: 2.0,
            coinMultiplier: 1.0,
            xpMultiplier: 1.0,
          },
        };
        
        await axios.post(`${API_URL}/api/player/create`, newPlayer);
        await storage.setItem('playerId', newPlayerId);
        
        setPlayerId(newPlayerId);
        setCoins(newPlayer.coins);
        setGems(newPlayer.gems);
      }
    } catch (error) {
      console.error('Error initializing player:', error);
      // Fallback to local only
      const newPlayerId = `player_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      setPlayerId(newPlayerId);
      setCoins(1000);
      setGems(5000);
      await storage.setItem('playerId', newPlayerId);
    } finally {
      setLoading(false);
    }
  };

  const saveProgress = async () => {
    if (!playerId) return;
    
    try {
      await axios.put(`${API_URL}/api/player/${playerId}/update`, {
        coins,
        gems,
        currentPhase,
        unlockedPhases,
        permanentUpgrades,
        ballTransformation,
        stats,
      });
    } catch (error) {
      console.error('Error saving progress:', error);
    }
  };

  const updateCoins = async (amount: number) => {
    const newCoins = coins + amount;
    setCoins(newCoins);
    await saveProgress();
  };

  const updateGems = async (amount: number) => {
    const newGems = gems + amount;
    setGems(newGems);
    await saveProgress();
  };

  const unlockPhase = async (phaseId: number) => {
    if (unlockedPhases.includes(phaseId)) return;
    
    const newUnlockedPhases = [...unlockedPhases, phaseId];
    setUnlockedPhases(newUnlockedPhases);
    
    if (playerId) {
      try {
        await axios.post(`${API_URL}/api/player/${playerId}/unlock-phase`, null, {
          params: { phase_id: phaseId },
        });
      } catch (error) {
        console.error('Error unlocking phase:', error);
      }
    }
  };

  const purchaseUpgrade = async (upgradeName: string, cost: number): Promise<boolean> => {
    if (coins < cost) return false;
    
    if (playerId) {
      try {
        await axios.post(
          `${API_URL}/api/player/${playerId}/purchase-upgrade`,
          null,
          { params: { upgrade_name: upgradeName, cost } }
        );
        
        setCoins(coins - cost);
        const currentLevel = permanentUpgrades[upgradeName] || 0;
        setPermanentUpgrades({
          ...permanentUpgrades,
          [upgradeName]: currentLevel + 1,
        });
        
        // Update stats based on upgrade
        updateStatsFromUpgrade(upgradeName);
        
        return true;
      } catch (error) {
        console.error('Error purchasing upgrade:', error);
        return false;
      }
    }
    return false;
  };

  const updateStatsFromUpgrade = (upgradeName: string) => {
    const newStats = { ...stats };
    const level = (permanentUpgrades[upgradeName] || 0) + 1;
    
    switch (upgradeName) {
      case 'baseDamage':
        newStats.baseDamage = 10 * Math.pow(1.1, level);
        break;
      case 'baseSpeed':
        newStats.baseSpeed = 100 * Math.pow(1.08, level);
        break;
      case 'critChance':
        newStats.critChance = 5 + (level * 2);
        break;
      case 'coinMultiplier':
        newStats.coinMultiplier = 1 + (level * 0.15);
        break;
      case 'xpBoost':
        newStats.xpMultiplier = 1 + (level * 0.2);
        break;
    }
    
    setStats(newStats);
  };

  const setBallTransformation = async (transformationId: string) => {
    setBallTransformationState(transformationId);
    await saveProgress();
  };

  return (
    <GameContext.Provider
      value={{
        playerId,
        coins,
        gems,
        currentPhase,
        unlockedPhases,
        permanentUpgrades,
        ballTransformation,
        stats,
        loading,
        initializePlayer,
        updateCoins,
        updateGems,
        unlockPhase,
        purchaseUpgrade,
        setBallTransformation,
        saveProgress,
      }}
    >
      {children}
    </GameContext.Provider>
  );
};

export const useGame = () => {
  const context = useContext(GameContext);
  if (context === undefined) {
    throw new Error('useGame must be used within a GameProvider');
  }
  return context;
};
