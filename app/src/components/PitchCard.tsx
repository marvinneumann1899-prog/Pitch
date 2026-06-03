// Die Pitchkarte — Herzstück des Profils (Spieler-Variante)
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, spacing, radius, font } from '../theme';

type Field = { icon: string; label: string; value: string };

export function PitchCard({
  name = 'Marvin Neumann',
  rating = '8.4',
  fields = DEFAULT_FIELDS,
}: { name?: string; rating?: string; fields?: Field[] }) {
  return (
    <View style={s.card}>
      <View style={s.top}>
        {/* Rating + Name (links) */}
        <View style={s.left}>
          <Text style={s.ratingLabel}>RATING</Text>
          <Text style={s.rating}>{rating}</Text>
          <Text style={s.name} numberOfLines={2}>{name}</Text>
          <View style={s.roleTag}><Text style={s.roleTagText}>SPIELER</Text></View>
        </View>
        {/* Bild (rechts, ~35%) */}
        <View style={s.photo}><Text style={s.photoGlyph}>⚽</Text></View>
      </View>

      <View style={s.divider} />

      {/* Felder */}
      <View style={s.fields}>
        {fields.map((f) => (
          <View key={f.label} style={s.fieldRow}>
            <Text style={s.fieldIcon}>{f.icon}</Text>
            <Text style={s.fieldLabel}>{f.label}</Text>
            <Text style={s.fieldValue} numberOfLines={1}>{f.value}</Text>
          </View>
        ))}
      </View>
    </View>
  );
}

const DEFAULT_FIELDS: Field[] = [
  { icon: '🎂', label: 'Alter', value: '23' },
  { icon: '🧭', label: 'Position', value: 'Innenverteidiger' },
  { icon: '📍', label: 'Location', value: 'Düsseldorf' },
  { icon: '🎯', label: 'Ziel', value: 'Verein in Oberliga' },
  { icon: '🏆', label: 'Aktuelle Liga', value: 'Landesliga' },
];

const s = StyleSheet.create({
  card: { backgroundColor: colors.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.line, padding: spacing.lg },
  top: { flexDirection: 'row', gap: spacing.lg },
  left: { flex: 1, justifyContent: 'flex-start' },
  ratingLabel: { color: colors.textFaint, fontSize: font.tiny, fontWeight: '800', letterSpacing: 1.5 },
  rating: { color: colors.accent, fontSize: 52, fontWeight: '900', letterSpacing: -1, lineHeight: 56 },
  name: { color: colors.text, fontSize: font.h2, fontWeight: '800', marginTop: spacing.sm },
  roleTag: { alignSelf: 'flex-start', marginTop: spacing.sm, backgroundColor: colors.surfaceAlt, borderRadius: radius.sm, paddingHorizontal: spacing.sm, paddingVertical: 3 },
  roleTagText: { color: colors.textMuted, fontSize: font.tiny, fontWeight: '800', letterSpacing: 1 },
  photo: { width: '35%', aspectRatio: 0.82, backgroundColor: colors.surfaceAlt, borderRadius: radius.md, borderWidth: 1, borderColor: colors.line, alignItems: 'center', justifyContent: 'center' },
  photoGlyph: { fontSize: 40, opacity: 0.5 },
  divider: { height: 1, backgroundColor: colors.line, marginVertical: spacing.lg },
  fields: { gap: spacing.md },
  fieldRow: { flexDirection: 'row', alignItems: 'center' },
  fieldIcon: { width: 26, fontSize: 15 },
  fieldLabel: { color: colors.textMuted, fontSize: font.small, width: 110 },
  fieldValue: { color: colors.text, fontSize: font.small, fontWeight: '700', flex: 1, textAlign: 'right' },
});
