import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { DualArenaState, getArenaProgress } from '@/src/game/dualArena';

interface DualArenaViewProps {
  arena: DualArenaState;
  meta: string;
  accent: string;
  leader?: boolean;
}

export function DualArenaView({ arena, meta, accent, leader }: DualArenaViewProps) {
  const progress = getArenaProgress(arena);
  const active = arena.rings.filter(ring => ring.status === 'active' && ring.hp > 0);

  return (
    <View style={[styles.panel, { borderColor: leader ? '#ffd700' : accent + '88' }]}>
      <View style={styles.header}>
        <Text style={styles.name} numberOfLines={1}>{arena.skinIcon} {arena.name}</Text>
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
            const opacity = Math.max(isSolid ? 0.72 : 0.36, ring.hp / ring.maxHp);
            const rotationDeg = (ring.rotation * 180) / Math.PI;
            const gapOffsetDeg = ((ring.gapStart + ring.gapSize / 2) * 180) / Math.PI;
            return (
              <Circle
                key={ring.id}
                cx={arena.center}
                cy={arena.center}
                r={ring.radius}
                stroke={isSolid ? '#ff4d00' : ring.color}
                strokeWidth={isSolid ? ring.thickness + 1 : ring.thickness}
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
              borderColor: arena.skinColor,
              shadowColor: arena.skinColor,
            },
          ]}
        >
          <Text style={styles.ballIcon}>{arena.skinIcon}</Text>
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
    backgroundColor: '#ffffff10',
    borderWidth: 1.5,
    borderRadius: 14,
    padding: 10,
  },
  header: { width: '100%', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', gap: 8, marginBottom: 8 },
  name: { color: '#ffffff', fontWeight: 'bold', flex: 1 },
  meta: { color: '#ffffffaa', fontWeight: 'bold', fontSize: 11 },
  stage: { backgroundColor: '#00000055', borderWidth: 2, borderColor: '#ffffff18', overflow: 'hidden' },
  ball: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#ffffff',
    borderWidth: 1,
    shadowOpacity: 0.9,
    shadowRadius: 10,
  },
  ballIcon: { fontSize: 10, lineHeight: 12 },
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
  progressTrack: { height: 16, backgroundColor: '#00000066', borderRadius: 8, overflow: 'hidden', justifyContent: 'center' },
  progressFill: { position: 'absolute', left: 0, top: 0, bottom: 0 },
  progressText: { color: '#ffffff', fontSize: 11, fontWeight: 'bold', textAlign: 'center' },
  stats: { color: '#ffffff99', fontSize: 11, fontWeight: 'bold', textAlign: 'center', marginTop: 4 },
});
