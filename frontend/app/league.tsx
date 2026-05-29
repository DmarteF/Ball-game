import React, { useMemo, useRef } from 'react';
import { FlatList, Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { useRouter } from 'expo-router';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useGame } from '@/src/contexts/GameContext';
import { DIVISIONS, getDaysRemainingInSeason, getDivisionReward, getDivisionMinScore, rewardToLabel } from '@/src/game/league';
import { getSkinById } from '@/src/game/skins';
import { playSound } from '@/src/utils/audio';
import { SkinIcon } from '@/src/components/SkinIcon';
import { UiIcon } from '@/src/components/UiIcon';
import { ProfileAvatar } from '@/src/components/ProfileAvatar';
import { getSafePaddingBottom, getSafePaddingTop } from '@/src/utils/gameplayLayout';

export default function LeagueScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const game = useGame();
  const listRef = useRef<FlatList>(null);
  const standings = useMemo(() => game.getLeagueStandings(), [game.league, game.nickname, game.avatar, game.avatarImageUri, game.level, game.lifetimeStats, game.unlockedSkins]);
  const playerIndex = standings.findIndex(item => item.id === game.playerId);
  const player = standings[playerIndex] || game.getLeaguePlayer();
  const above = playerIndex > 0 ? standings[playerIndex - 1] : undefined;
  const topThree = standings.slice(0, 3);
  const pending = game.league.pendingSeasonReward;
  const claimedDivisions = new Set(game.league.claimedDivisionRewards);
  const nextDivisionReward = DIVISIONS.find(item => item.name !== 'Bronze' && !claimedDivisions.has(item.name) && getDivisionReward(item.name).length > 0);
  const divisionIndex = DIVISIONS.findIndex(item => item.name === player.division);
  const nextDivision = DIVISIONS[divisionIndex + 1];
  const currentMin = getDivisionMinScore(player.division);
  const nextMin = nextDivision?.minScore || currentMin;
  const divisionProgress = nextDivision ? Math.min(1, (player.trophies - currentMin) / Math.max(1, nextMin - currentMin)) : 1;

  const goToPlayer = () => {
    if (playerIndex >= 0) listRef.current?.scrollToIndex({ index: playerIndex, animated: true, viewPosition: 0.45 });
  };

  const collectDivision = async () => {
    if (!nextDivisionReward) return;
    const ok = await game.collectDivisionReward(nextDivisionReward.name);
    playSound(ok ? 'buttonConfirm' : 'buttonError');
  };

  const collectSeason = async (equip = false) => {
    const ok = await game.collectPendingSeasonReward(equip);
    playSound(ok ? 'legendaryDrop' : 'buttonError');
  };

  const Row = ({ item, index }: any) => {
    const isPlayer = item.id === game.playerId;
    const skin = getSkinById(item.favoriteSkin);
    const previous = index > 0 ? standings[index - 1] : undefined;
    return (
      <View style={[styles.row, isPlayer && styles.playerRow]}>
        <Text style={styles.position}>#{index + 1}</Text>
        <ProfileAvatar avatar={item.avatar} imageUri={item.avatarImageUri} size={34} style={styles.avatarPhoto} />
        <View style={styles.rowInfo}>
          <Text style={styles.name} numberOfLines={1}>{isPlayer ? `${item.name} (Você)` : item.name}</Text>
          <View style={styles.metaRow}>
            <SkinIcon skin={skin} size={16} style={styles.metaSkin} />
            <Text style={styles.meta}>{skin.name} • Fase {item.maxPhase} • Comp {item.competitionWins}V</Text>
          </View>
        </View>
        <View style={styles.scoreBox}>
          <View style={styles.scoreRow}><Text style={styles.score}>{item.trophies.toLocaleString('pt-BR')}</Text><UiIcon iconKey="ui_achievements" fallback="🏆" size={14} /></View>
          <Text style={styles.division}>{item.division}</Text>
          {previous && <Text style={styles.diff}>+{(previous.trophies - item.trophies).toLocaleString('pt-BR')}</Text>}
        </View>
      </View>
    );
  };

  return (
    <LinearGradient colors={['#08121d', '#1a0a2e', '#16003b']} style={styles.container}>
      <View style={[styles.header, { paddingTop: getSafePaddingTop(insets, 56) }]}>
        <TouchableOpacity onPress={() => router.back()}><Text style={styles.backText}>← VOLTAR</Text></TouchableOpacity>
        <Text style={styles.title}>LIGA NEON</Text>
        <Text style={styles.subtitle}>Liga local contra rivais fictícios • {standings.length} participantes</Text>
      </View>

      <View style={styles.summary}>
        <View>
          <Text style={styles.summaryLabel}>Sua posição</Text>
          <Text style={styles.summaryValue}>#{playerIndex + 1}/{standings.length}</Text>
        </View>
        <View>
          <Text style={styles.summaryLabel}>Troféus</Text>
          <Text style={styles.summaryValue}>{player.trophies.toLocaleString('pt-BR')}</Text>
        </View>
        <View>
          <Text style={styles.summaryLabel}>Temporada</Text>
          <Text style={styles.summaryValue}>{getDaysRemainingInSeason()}d</Text>
        </View>
      </View>

      <View style={styles.trophyPanel}>
        <View style={styles.trophyHeader}>
          <Text style={styles.trophyTitle}>{player.division}</Text>
          <Text style={styles.trophyText}>{nextDivision ? `${Math.max(0, nextMin - player.trophies)} troféus até ${nextDivision.name}` : 'Divisão máxima'}</Text>
        </View>
        <View style={styles.progressTrack}><View style={[styles.progressFill, { width: `${divisionProgress * 100}%` }]} /></View>
        <TouchableOpacity style={styles.competeButton} onPress={() => { playSound('buttonConfirm'); router.push('/compete' as any); }}>
          <Text style={styles.competeText}>COMPETIR</Text>
        </TouchableOpacity>
        <Text style={styles.streakText}>Sequência: {game.league.history.currentWinStreak || 0} vitórias • Melhor: {game.league.history.bestWinStreak || 0}</Text>
      </View>

      <View style={styles.topThree}>
        {topThree.map((item, index) => (
          <View key={item.id} style={styles.podium}>
            <Text style={styles.medal}>{index === 0 ? '🥇' : index === 1 ? '🥈' : '🥉'}</Text>
            <Text style={styles.podiumName} numberOfLines={1}>{item.id === game.playerId ? 'Você' : item.name}</Text>
            <Text style={styles.podiumScore}>{item.trophies.toLocaleString('pt-BR')} 🏆</Text>
          </View>
        ))}
      </View>

      <View style={styles.rewardCard}>
        <Text style={styles.rewardTitle}>Recompensa estimada</Text>
        <Text style={styles.rewardText}>{playerIndex === 0 ? 'Skin especial + gemas + baú da divisão' : playerIndex < 10 ? 'Gemas e baú raro/épico' : playerIndex < 50 ? 'Moedas, fragmentos e chave comum' : 'Participação com moedas/XP'}</Text>
        {above && <Text style={styles.rewardHint}>Faltam {(above.trophies - player.trophies).toLocaleString('pt-BR')} troféus para subir uma posição.</Text>}
        {nextDivisionReward && (
          <TouchableOpacity style={styles.smallButton} onPress={collectDivision}>
            <Text style={styles.smallButtonText}>Coletar prêmio {nextDivisionReward.name}: {getDivisionReward(nextDivisionReward.name).map(rewardToLabel).join(', ')}</Text>
          </TouchableOpacity>
        )}
      </View>

      <FlatList
        ref={listRef}
        data={standings}
        keyExtractor={item => item.id}
        renderItem={Row}
        contentContainerStyle={[styles.listContent, { paddingBottom: getSafePaddingBottom(insets, 92) + 72 }]}
        initialNumToRender={16}
        maxToRenderPerBatch={18}
        windowSize={8}
        getItemLayout={(_, index) => ({ length: 76, offset: 76 * index, index })}
        onScrollToIndexFailed={info => setTimeout(() => listRef.current?.scrollToIndex({ index: info.index, animated: true }), 250)}
      />

      <TouchableOpacity style={[styles.playerDock, { bottom: getSafePaddingBottom(insets, 18) }]} onPress={goToPlayer}>
        <Text style={styles.dockText}>Minha posição #{playerIndex + 1} • {player.trophies.toLocaleString('pt-BR')} troféus • {player.division}</Text>
      </TouchableOpacity>

      <Modal visible={!!pending} transparent animationType="fade">
        <View style={styles.modalOverlay}>
          <View style={styles.seasonModal}>
            <Text style={styles.seasonTitle}>{pending?.firstInitialChampionUltimate ? 'ULTIMATE DESBLOQUEADA' : 'TEMPORADA ENCERRADA'}</Text>
            <Text style={styles.seasonText}>Divisão final: {pending?.finalDivision}</Text>
            <Text style={styles.seasonText}>Posição final: #{pending?.finalPosition}</Text>
            <Text style={styles.seasonText}>Nova divisão: {pending?.newDivision}</Text>
            {pending?.rewards.map(reward => <Text key={rewardToLabel(reward)} style={styles.rewardLine}>{rewardToLabel(reward)}</Text>)}
            {pending?.skinId && <Text style={styles.skinReward}>Skin: {getSkinById(pending.skinId).name}</Text>}
            {pending?.skinId ? (
              <TouchableOpacity style={styles.collectButton} onPress={() => collectSeason(true)}>
                <Text style={styles.collectText}>COLETAR E EQUIPAR</Text>
              </TouchableOpacity>
            ) : (
              <TouchableOpacity style={styles.collectButton} onPress={() => collectSeason(false)}>
                <Text style={styles.collectText}>COLETAR</Text>
              </TouchableOpacity>
            )}
          </View>
        </View>
      </Modal>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { paddingTop: 56, paddingHorizontal: 18, paddingBottom: 10 },
  backText: { color: '#00f0ff', fontWeight: 'bold', fontSize: 16 },
  title: { color: '#00f0ff', fontSize: 31, fontWeight: 'bold', marginTop: 8 },
  subtitle: { color: '#ffffffaa', marginTop: 3, fontSize: 12, fontWeight: 'bold' },
  summary: { marginHorizontal: 16, flexDirection: 'row', justifyContent: 'space-between', backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#00f0ff44', borderRadius: 12, padding: 12 },
  summaryLabel: { color: '#ffffff88', fontSize: 11, fontWeight: 'bold' },
  summaryValue: { color: '#ffffff', fontSize: 18, fontWeight: 'bold', marginTop: 2 },
  trophyPanel: { marginHorizontal: 16, marginTop: 10, backgroundColor: '#ffffff12', borderWidth: 1, borderColor: '#00ff8866', borderRadius: 12, padding: 12, gap: 9 },
  trophyHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', gap: 10 },
  trophyTitle: { color: '#00ff88', fontSize: 18, fontWeight: 'bold' },
  trophyText: { color: '#ffffffaa', fontSize: 12, fontWeight: 'bold', flex: 1, textAlign: 'right' },
  progressTrack: { height: 8, borderRadius: 4, backgroundColor: '#ffffff18', overflow: 'hidden' },
  progressFill: { height: 8, borderRadius: 4, backgroundColor: '#00ff88' },
  competeButton: { height: 48, borderRadius: 10, backgroundColor: '#00f0ff', alignItems: 'center', justifyContent: 'center' },
  competeText: { color: '#001018', fontSize: 17, fontWeight: 'bold', letterSpacing: 1 },
  streakText: { color: '#ffffff99', fontSize: 12, textAlign: 'center', fontWeight: 'bold' },
  topThree: { flexDirection: 'row', gap: 8, paddingHorizontal: 16, paddingTop: 10 },
  podium: { flex: 1, backgroundColor: '#ffffff10', borderWidth: 1, borderColor: '#ffd70066', borderRadius: 10, padding: 10, alignItems: 'center' },
  medal: { fontSize: 24 },
  podiumName: { color: '#ffffff', fontWeight: 'bold', marginTop: 4, maxWidth: '100%' },
  podiumScore: { color: '#ffd700', fontSize: 12, marginTop: 3, fontWeight: 'bold' },
  rewardCard: { margin: 16, marginBottom: 8, backgroundColor: '#00ff8814', borderWidth: 1, borderColor: '#00ff8866', borderRadius: 12, padding: 12 },
  rewardTitle: { color: '#00ff88', fontSize: 15, fontWeight: 'bold' },
  rewardText: { color: '#ffffff', marginTop: 4, fontWeight: 'bold' },
  rewardHint: { color: '#ffffffaa', marginTop: 4, fontSize: 12 },
  smallButton: { marginTop: 10, backgroundColor: '#00f0ff', borderRadius: 8, padding: 10 },
  smallButtonText: { color: '#001018', fontSize: 12, fontWeight: 'bold', textAlign: 'center' },
  listContent: { paddingHorizontal: 16, paddingBottom: 92 },
  row: { height: 68, flexDirection: 'row', alignItems: 'center', backgroundColor: '#ffffff10', borderWidth: 1, borderColor: '#ffffff22', borderRadius: 10, paddingHorizontal: 10, marginBottom: 8, gap: 8 },
  playerRow: { borderColor: '#00ff88', backgroundColor: '#00ff8820' },
  position: { width: 42, color: '#00f0ff', fontWeight: 'bold' },
  avatarPhoto: { borderColor: '#ffffff55' },
  rowInfo: { flex: 1 },
  name: { color: '#ffffff', fontSize: 14, fontWeight: 'bold' },
  metaRow: { flexDirection: 'row', alignItems: 'center', gap: 4, marginTop: 2 },
  metaSkin: { borderWidth: 0, backgroundColor: 'transparent' },
  meta: { color: '#ffffff99', fontSize: 11, marginTop: 2 },
  scoreBox: { alignItems: 'flex-end', minWidth: 82 },
  scoreRow: { flexDirection: 'row', alignItems: 'center', gap: 4 },
  score: { color: '#ffd700', fontSize: 12, fontWeight: 'bold' },
  division: { color: '#ffffff', fontSize: 10, marginTop: 2 },
  diff: { color: '#ffffff77', fontSize: 10, marginTop: 2 },
  playerDock: { position: 'absolute', left: 14, right: 14, bottom: 18, backgroundColor: '#00f0ff', borderRadius: 12, padding: 13, alignItems: 'center' },
  dockText: { color: '#001018', fontWeight: 'bold', textAlign: 'center' },
  modalOverlay: { flex: 1, backgroundColor: '#000000cc', alignItems: 'center', justifyContent: 'center', padding: 18 },
  seasonModal: { width: '100%', maxWidth: 390, backgroundColor: '#1a0a2e', borderWidth: 1, borderColor: '#ffd70088', borderRadius: 16, padding: 20, alignItems: 'center' },
  seasonTitle: { color: '#ffd700', fontSize: 24, fontWeight: 'bold', textAlign: 'center' },
  seasonText: { color: '#ffffff', marginTop: 7, fontWeight: 'bold' },
  rewardLine: { color: '#00ff88', marginTop: 6, fontWeight: 'bold' },
  skinReward: { color: '#ffffff', fontSize: 18, fontWeight: 'bold', marginTop: 10, textAlign: 'center' },
  collectButton: { width: '100%', backgroundColor: '#ffd700', borderRadius: 10, padding: 13, alignItems: 'center', marginTop: 16 },
  collectText: { color: '#001018', fontWeight: 'bold' },
});
