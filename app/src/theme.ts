// Pitch — Design-System (KickBase-clean: dark, monochrom, 1 Akzent)
// Alles als Token, damit Farben/Spacing zentral änderbar sind (Farben laut Marvin noch "offen").

export const colors = {
  bg: '#0B0B0C',
  surface: '#141419',
  surfaceAlt: '#1C1C24',
  line: '#2A2A33',
  text: '#FFFFFF',
  textMuted: '#9A9AA3',
  textFaint: '#62626B',
  accent: '#C6FF3A',      // Akzent (electric lime) – jederzeit swappbar
  accentText: '#0B0B0C',
  danger: '#FF4D4D',
  success: '#2BD576',
};

export const spacing = {
  xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24, xxxl: 32, huge: 40,
};

export const radius = {
  sm: 10, md: 16, lg: 22, pill: 999,
};

export const font = {
  display: 34,
  h1: 26,
  h2: 20,
  body: 15,
  small: 13,
  tiny: 11,
};

// sportlicher, "fetter" Headline-Look bis echte Schrift (KickBase-Optik) eingebaut wird
export const headline = {
  fontWeight: '800' as const,
  letterSpacing: 0.5,
};
