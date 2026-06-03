import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, SafeAreaView, ScrollView, Pressable } from 'react-native';
import { colors, spacing, radius, font } from '../theme';
import { Button, Chip, SectionLabel } from '../components/ui';
import { PitchCard } from '../components/PitchCard';

const ROLES = ['Spieler', 'Coach', 'Scout', 'Verein'];

export function OnboardingPitchScreen({ onDone }: { onDone: () => void }) {
  const [role, setRole] = useState('Spieler');
  const [name, setName] = useState('Marvin Neumann');

  return (
    <SafeAreaView style={s.safe}>
      <ScrollView contentContainerStyle={s.scroll} showsVerticalScrollIndicator={false}>
        <Text style={s.title}>Deine Pitchkarte</Text>
        <Text style={s.subtitle}>Das Herzstück deines Profils. So sehen dich andere.</Text>

        <SectionLabel>Rolle</SectionLabel>
        <View style={s.roles}>
          {ROLES.map((r) => (
            <Pressable key={r} onPress={() => setRole(r)}><Chip label={r} active={role === r} /></Pressable>
          ))}
        </View>

        <SectionLabel>Live-Vorschau</SectionLabel>
        <PitchCard name={name} />

        <SectionLabel>Angaben</SectionLabel>
        <View style={s.fields}>
          <Field label="Name" value={name} onChange={setName} />
          <Field label="Alter" value="23" />
          <Field label="Position" value="Innenverteidiger" />
          <Field label="Location" value="Düsseldorf" />
          <Field label="Ziel" value="Verein in Oberliga" />
          <Field label="Aktuelle Liga" value="Landesliga" />
        </View>

        <Button label="Pitchkarte fertigstellen" onPress={onDone} style={{ marginTop: spacing.lg }} />
        <View style={{ height: spacing.huge }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function Field({ label, value, onChange }: { label: string; value: string; onChange?: (t: string) => void }) {
  return (
    <View style={s.field}>
      <Text style={s.fieldLabel}>{label}</Text>
      <TextInput
        style={s.fieldInput} defaultValue={value} onChangeText={onChange}
        placeholderTextColor={colors.textFaint}
      />
    </View>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.bg },
  scroll: { paddingHorizontal: spacing.xl, paddingTop: spacing.lg },
  title: { color: colors.text, fontSize: font.h1, fontWeight: '900', letterSpacing: 0.5 },
  subtitle: { color: colors.textMuted, fontSize: font.small, marginTop: spacing.xs, marginBottom: spacing.xl },
  roles: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm, marginBottom: spacing.xl },
  fields: { gap: spacing.sm, marginBottom: spacing.sm },
  field: { backgroundColor: colors.surface, borderRadius: radius.md, borderWidth: 1, borderColor: colors.line, paddingHorizontal: spacing.lg, paddingVertical: spacing.sm },
  fieldLabel: { color: colors.textFaint, fontSize: font.tiny, fontWeight: '700', letterSpacing: 0.5 },
  fieldInput: { color: colors.text, fontSize: font.body, fontWeight: '600', paddingVertical: spacing.xs, marginTop: 2 },
});
