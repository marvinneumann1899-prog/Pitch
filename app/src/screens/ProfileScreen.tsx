import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { colors, spacing, radius, font } from '../theme';
import { Button } from '../components/ui';
import { PitchCard } from '../components/PitchCard';

export function ProfileScreen() {
  return (
    <SafeAreaView style={s.safe}>
      <ScrollView contentContainerStyle={s.scroll} showsVerticalScrollIndicator={false}>
        <View style={s.header}>
          <Text style={s.title}>Profil</Text>
          <Text style={s.gear}>⚙︎</Text>
        </View>

        <PitchCard />

        {/* Stats unter der Karte */}
        <View style={s.stats}>
          <Stat value="248" label="Follower" />
          <View style={s.statDivider} />
          <Stat value="73" label="Kontakte" />
          <View style={s.statDivider} />
          <Stat value="12" label="Pitches" />
        </View>

        {/* Aktionen */}
        <View style={s.row}>
          <Button label="Folgen" variant="ghost" style={{ flex: 1 }} />
          <Button label="🎯 Pitch" style={{ flex: 1 }} />
        </View>

        {/* Exposé + Fupa */}
        <View style={s.linkCard}>
          <View style={s.linkRow}>
            <Text style={s.linkGlyph}>📁</Text>
            <View style={{ flex: 1 }}>
              <Text style={s.linkTitle}>Exposé</Text>
              <Text style={s.linkSub}>Deine Highlights als Dateien — privat & für erfolgreiche Pitches</Text>
            </View>
            <Text style={s.chevron}>›</Text>
          </View>
          <View style={s.linkDivider} />
          <View style={s.linkRow}>
            <Text style={s.linkGlyph}>🔗</Text>
            <View style={{ flex: 1 }}>
              <Text style={s.linkTitle}>Fupa verknüpfen</Text>
              <Text style={s.linkSub}>Dein Fupa-Profil direkt verlinken</Text>
            </View>
            <Text style={s.chevron}>›</Text>
          </View>
        </View>

        <View style={{ height: spacing.huge }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <View style={s.stat}>
      <Text style={s.statValue}>{value}</Text>
      <Text style={s.statLabel}>{label}</Text>
    </View>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.bg },
  scroll: { paddingHorizontal: spacing.xl, paddingTop: spacing.lg, gap: spacing.lg },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  title: { color: colors.text, fontSize: font.h1, fontWeight: '900', letterSpacing: 0.5 },
  gear: { color: colors.textMuted, fontSize: 22 },
  stats: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.line, paddingVertical: spacing.lg },
  stat: { flex: 1, alignItems: 'center' },
  statValue: { color: colors.text, fontSize: font.h2, fontWeight: '900' },
  statLabel: { color: colors.textMuted, fontSize: font.tiny, fontWeight: '700', letterSpacing: 0.5, marginTop: 2 },
  statDivider: { width: 1, height: 32, backgroundColor: colors.line },
  row: { flexDirection: 'row', gap: spacing.md },
  linkCard: { backgroundColor: colors.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.line, padding: spacing.lg },
  linkRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, paddingVertical: spacing.xs },
  linkGlyph: { fontSize: 20 },
  linkTitle: { color: colors.text, fontSize: font.body, fontWeight: '800' },
  linkSub: { color: colors.textMuted, fontSize: font.tiny, marginTop: 1 },
  chevron: { color: colors.textFaint, fontSize: 24 },
  linkDivider: { height: 1, backgroundColor: colors.line, marginVertical: spacing.sm },
});
