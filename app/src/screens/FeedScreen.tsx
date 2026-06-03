import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { colors, spacing, radius, font } from '../theme';
import { Avatar, Chip } from '../components/ui';

type Post = {
  user: string; role: string; time: string; category: string;
  rating: string; caption: string; glyph: string;
};

const POSTS: Post[] = [
  { user: 'Leon Bäcker', role: 'Spieler', time: 'vor 2 Std', category: 'Highlight', rating: '8.9', caption: 'Freistoßtor von der Strafraumkante 🎯 Wochenende war gut.', glyph: '⚽' },
  { user: 'TSV Eller 04', role: 'Verein', time: 'vor 5 Std', category: 'Erfolg', rating: '9.2', caption: 'Aufstieg in die Bezirksliga klargemacht! Wir suchen Verstärkung.', glyph: '🏆' },
  { user: 'Coach Demir', role: 'Coach', time: 'gestern', category: 'Highlight', rating: '8.1', caption: 'Pressing-Drill aus dem Training. Intensität first.', glyph: '🔥' },
];

export function FeedScreen() {
  return (
    <SafeAreaView style={s.safe}>
      <View style={s.header}>
        <Text style={s.wordmark}>PITCH</Text>
        <View style={s.bell}><Text style={s.bellGlyph}>🔔</Text><View style={s.dot} /></View>
      </View>
      <ScrollView contentContainerStyle={s.scroll} showsVerticalScrollIndicator={false}>
        {POSTS.map((p, i) => <PostCard key={i} post={p} />)}
        <View style={{ height: spacing.huge }} />
      </ScrollView>
    </SafeAreaView>
  );
}

function PostCard({ post }: { post: Post }) {
  return (
    <View style={s.card}>
      <View style={s.cardHead}>
        <Avatar size={40} label={post.glyph} />
        <View style={{ flex: 1 }}>
          <Text style={s.user}>{post.user}</Text>
          <Text style={s.meta}>{post.role} · {post.time}</Text>
        </View>
        <Chip label={post.category} />
      </View>

      {/* Clip-Fläche */}
      <View style={s.media}>
        <Text style={s.mediaGlyph}>{post.glyph}</Text>
        <View style={s.ratingBadge}><Text style={s.ratingBadgeText}>★ {post.rating}</Text></View>
        <View style={s.playBtn}><Text style={s.playGlyph}>▶</Text></View>
      </View>

      <Text style={s.caption}>{post.caption}</Text>

      <View style={s.actions}>
        <Action glyph="＋" label="Vernetzen" />
        <Action glyph="💬" label="Kommentar" />
        <Action glyph="🎯" label="Pitch" accent />
      </View>
    </View>
  );
}

function Action({ glyph, label, accent }: { glyph: string; label: string; accent?: boolean }) {
  return (
    <View style={s.action}>
      <Text style={[s.actionGlyph, accent && { color: colors.accent }]}>{glyph}</Text>
      <Text style={[s.actionLabel, accent && { color: colors.accent }]}>{label}</Text>
    </View>
  );
}

const s = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.bg },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: spacing.xl, paddingVertical: spacing.md, borderBottomWidth: 1, borderBottomColor: colors.line },
  wordmark: { color: colors.text, fontSize: font.h2, fontWeight: '900', letterSpacing: 3 },
  bell: { width: 40, height: 40, alignItems: 'center', justifyContent: 'center' },
  bellGlyph: { fontSize: 18 },
  dot: { position: 'absolute', top: 8, right: 8, width: 9, height: 9, borderRadius: 5, backgroundColor: colors.accent, borderWidth: 1.5, borderColor: colors.bg },
  scroll: { padding: spacing.lg, gap: spacing.lg },
  card: { backgroundColor: colors.surface, borderRadius: radius.lg, borderWidth: 1, borderColor: colors.line, padding: spacing.lg, gap: spacing.md },
  cardHead: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  user: { color: colors.text, fontSize: font.body, fontWeight: '800' },
  meta: { color: colors.textMuted, fontSize: font.tiny, marginTop: 1 },
  media: { height: 200, backgroundColor: colors.surfaceAlt, borderRadius: radius.md, alignItems: 'center', justifyContent: 'center', overflow: 'hidden' },
  mediaGlyph: { fontSize: 64, opacity: 0.35 },
  ratingBadge: { position: 'absolute', top: spacing.md, left: spacing.md, backgroundColor: colors.bg, borderRadius: radius.pill, paddingHorizontal: spacing.md, paddingVertical: 5, borderWidth: 1, borderColor: colors.line },
  ratingBadgeText: { color: colors.accent, fontSize: font.small, fontWeight: '900' },
  playBtn: { position: 'absolute', width: 56, height: 56, borderRadius: 28, backgroundColor: 'rgba(11,11,12,0.55)', alignItems: 'center', justifyContent: 'center', borderWidth: 1, borderColor: colors.line },
  playGlyph: { color: colors.text, fontSize: 20, marginLeft: 3 },
  caption: { color: colors.text, fontSize: font.small, lineHeight: 20 },
  actions: { flexDirection: 'row', justifyContent: 'space-between', borderTopWidth: 1, borderTopColor: colors.line, paddingTop: spacing.md },
  action: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  actionGlyph: { color: colors.textMuted, fontSize: 15 },
  actionLabel: { color: colors.textMuted, fontSize: font.small, fontWeight: '700' },
});
