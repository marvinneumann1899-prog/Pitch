import React, { useState } from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { colors, spacing, font } from './src/theme';
import { SignUpScreen } from './src/screens/SignUpScreen';
import { OnboardingPitchScreen } from './src/screens/OnboardingPitchScreen';
import { FeedScreen } from './src/screens/FeedScreen';
import { ProfileScreen } from './src/screens/ProfileScreen';

type Phase = 'auth' | 'onboarding' | 'main';
type Tab = 'feed' | 'create' | 'profile';

export default function App() {
  const [phase, setPhase] = useState<Phase>('auth');
  const [tab, setTab] = useState<Tab>('feed');

  return (
    <View style={s.root}>
      <StatusBar style="light" />

      {phase === 'auth' && <SignUpScreen onContinue={() => setPhase('onboarding')} />}
      {phase === 'onboarding' && (
        <OnboardingPitchScreen onDone={() => { setTab('feed'); setPhase('main'); }} />
      )}

      {phase === 'main' && (
        <>
          <View style={s.screen}>
            {tab === 'feed' && <FeedScreen />}
            {tab === 'create' && <OnboardingPitchScreen onDone={() => setTab('feed')} />}
            {tab === 'profile' && <ProfileScreen />}
          </View>
          <TabBar tab={tab} onChange={setTab} />
        </>
      )}
    </View>
  );
}

function TabBar({ tab, onChange }: { tab: Tab; onChange: (t: Tab) => void }) {
  return (
    <View style={s.tabbar}>
      <TabItem glyph="⌂" label="Feed" active={tab === 'feed'} onPress={() => onChange('feed')} />
      <CreateItem active={tab === 'create'} onPress={() => onChange('create')} />
      <TabItem glyph="◉" label="Profil" active={tab === 'profile'} onPress={() => onChange('profile')} />
    </View>
  );
}

function TabItem({ glyph, label, active, onPress }: { glyph: string; label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable style={s.tabItem} onPress={onPress}>
      <Text style={[s.tabGlyph, active && { color: colors.text }]}>{glyph}</Text>
      <Text style={[s.tabLabel, active && { color: colors.text }]}>{label}</Text>
    </Pressable>
  );
}

function CreateItem({ active, onPress }: { active: boolean; onPress: () => void }) {
  return (
    <Pressable style={s.tabItem} onPress={onPress}>
      <View style={[s.createBtn, active && { backgroundColor: colors.text }]}>
        <Text style={s.createGlyph}>＋</Text>
      </View>
    </Pressable>
  );
}

const s = StyleSheet.create({
  root: { flex: 1, backgroundColor: colors.bg },
  screen: { flex: 1 },
  tabbar: { flexDirection: 'row', alignItems: 'center', backgroundColor: colors.surface, borderTopWidth: 1, borderTopColor: colors.line, paddingBottom: spacing.xxl, paddingTop: spacing.md },
  tabItem: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 3 },
  tabGlyph: { color: colors.textFaint, fontSize: 22, lineHeight: 24 },
  tabLabel: { color: colors.textFaint, fontSize: font.tiny, fontWeight: '700', letterSpacing: 0.5 },
  createBtn: { width: 48, height: 48, borderRadius: 16, backgroundColor: colors.accent, alignItems: 'center', justifyContent: 'center' },
  createGlyph: { color: colors.accentText, fontSize: 28, fontWeight: '900', marginTop: -2 },
});
