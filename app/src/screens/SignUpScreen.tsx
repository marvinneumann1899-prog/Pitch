import React from 'react';
import { View, Text, TextInput, StyleSheet, SafeAreaView } from 'react-native';
import { colors, spacing, radius, font } from '../theme';
import { Button } from '../components/ui';

export function SignUpScreen({ onContinue }: { onContinue: () => void }) {
  return (
    <SafeAreaView style={s.safe}>
      <View style={s.container}>
        <View style={s.brand}>
          <View style={s.logo}><Text style={s.logoText}>P</Text></View>
          <Text style={s.wordmark}>PITCH</Text>
          <Text style={s.slogan}>Pitch your play</Text>
        </View>

        <View style={s.form}>
          <TextInput
            style={s.input} placeholder="E-Mail" placeholderTextColor={colors.textFaint}
            autoCapitalize="none" keyboardType="email-address"
          />
          <TextInput
            style={s.input} placeholder="Passwort" placeholderTextColor={colors.textFaint}
            secureTextEntry
          />
          <Button label="Konto erstellen" onPress={onContinue} />

          <View style={s.dividerRow}>
            <View style={s.line} /><Text style={s.or}>ODER</Text><View style={s.line} />
          </View>

          <Button label=" Mit Apple anmelden" variant="outline" onPress={onContinue} />
        </View>

        <Text style={s.foot}>Schon dabei?  <Text style={s.footLink}>Einloggen</Text></Text>
      </View>
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.bg },
  container: { flex: 1, paddingHorizontal: spacing.xl, justifyContent: 'center' },
  brand: { alignItems: 'center', marginBottom: spacing.huge },
  logo: { width: 72, height: 72, borderRadius: radius.lg, backgroundColor: colors.accent, alignItems: 'center', justifyContent: 'center', marginBottom: spacing.lg },
  logoText: { color: colors.accentText, fontSize: 40, fontWeight: '900' },
  wordmark: { color: colors.text, fontSize: font.display, fontWeight: '900', letterSpacing: 4 },
  slogan: { color: colors.textMuted, fontSize: font.body, marginTop: spacing.xs, letterSpacing: 0.5 },
  form: { gap: spacing.md },
  input: { height: 52, backgroundColor: colors.surface, borderRadius: radius.md, borderWidth: 1, borderColor: colors.line, paddingHorizontal: spacing.lg, color: colors.text, fontSize: font.body },
  dividerRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md, marginVertical: spacing.xs },
  line: { flex: 1, height: 1, backgroundColor: colors.line },
  or: { color: colors.textFaint, fontSize: font.tiny, fontWeight: '800', letterSpacing: 1 },
  foot: { color: colors.textMuted, fontSize: font.small, textAlign: 'center', marginTop: spacing.xxl },
  footLink: { color: colors.accent, fontWeight: '800' },
});
