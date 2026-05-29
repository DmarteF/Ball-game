import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import Svg, { Circle } from 'react-native-svg';
import { DualArenaState, getArenaProgress } from '@/src/game/dualArena';
import { SkinIcon } from '@/src/components/SkinIcon';
import { getRingVisualColor } from '@/src/game/rings';

interface DualArenaViewProps {
  arena: DualArenaState;
  meta: string;
  accent: string;
  leader?: boolean;
}

export function DualArenaView({ arena, meta, accent, leader }: DualArenaViewProps) {
  const progress = getArenaProgress(arena);
  const active = arena.rings.filter(ring => ring.status === 'active' && ring.hp > 0);
  const now = Date.now();

  return (
    <View style={[styles.panel, { borderColor: leader ? '#ffd700' : accent + '88' }]}>
      <View style={styles.header}>
        <View style={styles.nameRow}>
          <SkinIcon skin={{ icon: arena.skinIcon, imageAsset: arena.skinImageAsset, primaryColor: arena.skinColor }} size={20} style={styles.nameSkin} />
          <Text style={styles.name} numberOfLines={1}>{arena.name}</Text>
        </View>
        <Text style={styles.meta}>{meta} • {active.length} anéis</Text>
      </View>
      <View style={[styles.stage, { width: arena.size, height: arena.size, borderRadius: arena.size / 2 }]}>
        <Svg width={arena.size} height={arena.size} style={StyleSheet.absoluteFill}>
          {arena.rings.map((ring) => {
            if (ring.status !== 'active' || ring.hp <= 0) return null;
            const circumference = 2 * Math.PI * ring.radius;
            const isSolid = ring.type === 'solid';
            const gapLength = isSolid ? 0 : (ring.gapSize / (Math.PI * 2)) * circumference;
            const arcLength = circumference - gapLength;
            const opacity = Math.max(isSolid ? 0.65 : 0.4, ring.hp / ring.maxHp);
            const rotationDeg = (ring.rotation * 180) / Math.PI;
            const gapOffsetDeg = ((ring.gapStart + ring.gapSize / 2) * 180) / Math.PI;
            return (
              <Circle
                key={ring.id}
                cx={arena.center}
                cy={arena.center}
                r={ring.radius}
                stroke={getRingVisualColor(ring, now)}
                strokeWidth={ring.thickness}
                fill="none"
                opacity={opacity}
                strokeDasharray={isSolid ? undefined : `${arcLength} ${gapLength}`}
                strokeDashoffset={-(gapOffsetDeg / 360) * circumference}
                transform={`rotate(${rotationDeg} ${arena.center} ${arena.center})`}
                strokeLinecap={isSolid ? 'butt' : 'round'}
              />
            );
          })}
        </Svg>
        <View
          style={[
            styles.ball,
            {
              left: arena.ball.x - arena.ballRadius,
              top: arena.ball.y - arena.ballRadius,
              width: arena.ballRadius * 2,
              height: arena.ballRadius * 2,
              borderRadius: arena.ballRadius,
              shadowColor: arena.skinColor,
            },
          ]}
        >
          <View style={[styles.skinTrail, { backgroundColor: arena.skinColor }]} />
          <View style={[styles.ballGlow, { shadowColor: arena.skinColor, borderRadius: arena.ballRadius }]}>
            <LinearGradient colors={['#ffffff', arena.skinColor, accent]} style={styles.ballGradient}>
              <SkinIcon skin={{ icon: arena.skinIcon, imageAsset: arena.skinImageAsset, primaryColor: arena.skinColor }} size={arena.ballRadius * 1.8} style={styles.ballIconImage} />
            </LinearGradient>
          </View>
        </View>
        {arena.lastSolidBreak > 0 && (
          <View style={styles.solidBadge}>
            <Text style={styles.solidText}>SÓLIDO QUEBRADO</Text>
          </View>
        )}
      </View>
      <View style={styles.footer}>
        <View style={styles.progressTrack}>
          <View style={[styles.progressFill, { width: `${progress * 100}%`, backgroundColor: accent }]} />
          <Text style={styles.progressText}>{Math.floor(progress * 100)}%</Text>
        </View>
        <Text style={styles.stats}>ATK {arena.atk} • Gold {arena.gold} • Combo x{arena.combo}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  panel: {
    width: '100%',
    alignItems: 'center',
    backgroundColor: 'transparent',
    borderWidth: 0,
    borderRadius: 0,
    padding: 4,
  },
  header: { width: '100%', alignItems: 'center', gap: 3, marginBottom: 8 },
  nameRow: { maxWidth: '100%', flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 5 },
  nameSkin: { borderWidth: 0, backgroundColor: 'transparent' },
  name: { color: '#ffffff', fontWeight: 'bold', textAlign: 'center', flexShrink: 1 },
  meta: { color: '#ffffffaa', fontWeight: 'bold', fontSize: 11, textAlign: 'center' },
  stage: { backgroundColor: '#00000033', borderWidth: 2, borderColor: '#ffffff11', overflow: 'hidden', position: 'relative' },
  ball: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    shadowOpacity: 0.9,
    shadowRadius: 15,
    elevation: 10,
  },
  skinTrail: {
    position: 'absolute',
    left: -7,
    top: -7,
    right: -7,
    bottom: -7,
    borderRadius: 999,
    opacity: 0.18,
  },
  ballGlow: {
    width: '100%',
    height: '100%',
    overflow: 'hidden',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 1,
    shadowRadius: 15,
  },
  ballGradient: { width: '100%', height: '100%', justifyContent: 'center', alignItems: 'center' },
  ballIconImage: { borderWidth: 0, backgroundColor: 'transparent' },
  solidBadge: {
    position: 'absolute',
    alignSelf: 'center',
    bottom: 10,
    backgroundColor: '#ff4d0033',
    borderWidth: 1,
    borderColor: '#ff8a00',
    borderRadius: 10,
    paddingVertical: 4,
    paddingHorizontal: 8,
  },
  solidText: { color: '#ffd6b0', fontSize: 10, fontWeight: 'bold' },
  footer: { width: '100%', marginTop: 8 },
  progressTrack: { height: 14, backgroundColor: '#ffffff11', borderRadius: 7, overflow: 'hidden', justifyContent: 'center', borderWidth: 1, borderColor: '#ffffff22' },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  progressText: { color: '#ffffff', fontSize: 11, fontWeight: 'bold', textAlign: 'center' },
  stats: { color: '#ffffff99', fontSize: 11, fontWeight: 'bold', textAlign: 'center', marginTop: 4 },
});
