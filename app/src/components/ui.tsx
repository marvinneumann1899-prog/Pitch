// Wiederverwendbare UI-Primitive im Pitch-Look
import React from 'react';
import { Text, View, Pressable, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { colors, spacing, radius, font, headline } from '../theme';

export function Button({
  label, onPress, variant = 'primary', style,
}: { label: string; onPress?: () => void; variant?: 'primary' | 'ghost' | 'outline'; style?: ViewStyle }) {
  const v = btn[variant];
  return (
    <Pressable onPress={onPress} style={({ pressed }) => [s.btn, v.box, pressed && { opacity: 0.85 }, style]}>
      <Text style={[s.btnLabel, v.label]}>{label}</Text>
    </Pressable>
  );
}

export function Chip({ label, active = false }: { label: string; active?: boolean }) {
  return (
    <View style={[s.chip, active && { backgroundColor: colors.accent, borderColor: colors.accent }]}>
      <Text style={[s.chipText, active && { color: colors.accentText }]}>{label}</Text>
    </View>
  );
}

export function Avatar({ size = 44, label }: { size?: number; label?: string }) {
  return (
    <View style={[s.avatar, { width: size, height: size, borderRadius: size / 2 }]}>
      <Text style={[s.avatarText, { fontSize: size * 0.4 }]}>{label ?? '⚽'}</Text>
    </View>
  );
}

export function Card({ children, style }: { children: React.ReactNode; style?: ViewStyle }) {
  return <View style={[s.card, style]}>{children}</View>;
}

export function SectionLabel({ children }: { children: React.ReactNode }) {
  return <Text style={s.sectionLabel}>{String(children).toUpperCase()}</Text>;
}

const s = StyleSheet.create({
  btn: { height: 52, borderRadius: radius.pill, alignItems: 'center', justifyContent: 'center', paddingHorizontal: spacing.xl },
  btnLabel: { fontSize: font.body, fontWeight: '800', letterSpacing: 0.5 },
  chip: { paddingHorizontal: spacing.md, paddingVertical: 6, borderRadius: radius.pill, borderWidth: 1, borderColor: colors.line, backgroundColor: colors.surfaceAlt },
  chipText: { color: colors.textMuted, fontSize: font.tiny, fontWeight: '700', letterSpacing: 0.5 },
  avatar: { backgroundColor: colors.surfaceAlt, borderWidth: 1, borderColor: colors.line, alignItems: 'center', justifyContent: 'center' },
  avatarText: { color: colors.text },
  card: { backgroundColor: colors.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.line, padding: spacing.lg },
  sectionLabel: { color: colors.textFaint, fontSize: font.tiny, fontWeight: '800', letterSpacing: 1.2, marginBottom: spacing.sm },
});

const btn: Record<string, { box: ViewStyle; label: TextStyle }> = {
  primary: { box: { backgroundColor: colors.accent }, label: { color: colors.accentText } },
  ghost: { box: { backgroundColor: colors.surfaceAlt }, label: { color: colors.text } },
  outline: { box: { backgroundColor: 'transparent', borderWidth: 1.5, borderColor: colors.line }, label: { color: colors.text } },
};
