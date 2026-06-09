import SwiftUI

// Pitch Design-System — Hell-Glas (Liquid Glass), Stand 08.06.2026.
// Heller, luftiger Grund + transluzentes Glas (SwiftUI Materials) + giftgrüner Akzent,
// der vor allem als Beleuchtung/Glow wirkt. Frühere Paletten (lime/classic) bleiben wählbar.

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }
}

struct Palette {
    let dark: Bool
    let bg, surface, surfaceAlt, line, text, textMuted, textFaint, accent, accentText, danger, success: Color

    init(dark: Bool, bg: UInt, surface: UInt, surfaceAlt: UInt, line: UInt,
         text: UInt, textMuted: UInt, textFaint: UInt,
         accent: UInt, accentText: UInt, danger: UInt, success: UInt) {
        self.dark = dark
        self.bg = Color(hex: bg); self.surface = Color(hex: surface); self.surfaceAlt = Color(hex: surfaceAlt)
        self.line = Color(hex: line); self.text = Color(hex: text); self.textMuted = Color(hex: textMuted)
        self.textFaint = Color(hex: textFaint); self.accent = Color(hex: accent); self.accentText = Color(hex: accentText)
        self.danger = Color(hex: danger); self.success = Color(hex: success)
    }

    // Pitch-DNA — Schwarz (primär) + Neongrün #C6FF3A (sekundär), dunkles Liquid Glass
    static let glass = Palette(
        dark: true, bg: 0x000000, surface: 0x141417, surfaceAlt: 0x1E1E22, line: 0x2C2C31,
        text: 0xFFFFFF, textMuted: 0x9A9AA3, textFaint: 0x66666E,
        accent: 0xC6FF3A, accentText: 0x0A0A0A, danger: 0xFF4D4D, success: 0xC6FF3A
    )

    // (Archiv) dark + electric lime
    static let lime = Palette(
        dark: true, bg: 0x0B0B0C, surface: 0x141419, surfaceAlt: 0x1C1C24, line: 0x2A2A33,
        text: 0xFFFFFF, textMuted: 0x9A9AA3, textFaint: 0x62626B,
        accent: 0xC6FF3A, accentText: 0x0B0B0C, danger: 0xFF4D4D, success: 0x2BD576
    )
}

enum Theme {
    // >>> AKTIVE PALETTE <<<
    static var active: Palette = .glass

    static var bg: Color { active.bg }
    static var surface: Color { active.surface }
    static var surfaceAlt: Color { active.surfaceAlt }
    static var line: Color { active.line }
    static var text: Color { active.text }
    static var textMuted: Color { active.textMuted }
    static var textFaint: Color { active.textFaint }
    static var accent: Color { active.accent }
    static var accentText: Color { active.accentText }
    static var danger: Color { active.danger }
    static var success: Color { active.success }
    static var scheme: ColorScheme { active.dark ? .dark : .light }

    // Neongrün — Pitch-Signatur, auch für Glow/Beleuchtung
    static let glow = Color(hex: 0xC6FF3A)

    // Radius
    static let rSm: CGFloat = 12
    static let rMd: CGFloat = 18
    static let rLg: CGFloat = 26
    static let rXL: CGFloat = 34
    static let rPill: CGFloat = 999
}

// MARK: - Liquid-Glass-Bausteine

// Ambient-Hintergrund: schwarzer Grund mit weichen Neongrün-Lichtflecken.
// Liegt ganz unten, gibt der App den verschmolzenen, lebendigen Look (Pitch-DNA).
struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Color.black
            Circle().fill(Theme.glow.opacity(0.22))
                .frame(width: 380).blur(radius: 140)
                .offset(x: -150, y: -280)
            Circle().fill(Theme.glow.opacity(0.10))
                .frame(width: 320).blur(radius: 150)
                .offset(x: 180, y: 360)
        }
        .ignoresSafeArea()
    }
}

// Dunkle Glas-Karte: transluzentes dunkles Material statt anthrazit-Fläche + harter Linie.
// Apple-Liquid-Glass-Rand: heller Specular-Rim oben-links, dezenter Glanz unten-rechts.
// Gibt der Kante den lichtbrechenden Look (wie iOS Control Center).
struct GlassRim: View {
    var radius: CGFloat
    var strength: Double = 1
    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [Color.white.opacity(0.65 * strength),
                             Color.white.opacity(0.16 * strength),
                             Color.white.opacity(0.05 * strength),
                             Color.white.opacity(0.30 * strength)],
                    startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: 1)
    }
}

struct GlassCard: ViewModifier {
    var radius: CGFloat = Theme.rLg
    var strong: Bool = false
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(strong ? 0.10 : 0.05))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(GlassRim(radius: radius))
            .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)
    }
}

// Dunkles Glas über Medien: lässt die Bildfarben durchscheinen, weiße Schrift bleibt lesbar.
struct MediaGlass: ViewModifier {
    var radius: CGFloat = Theme.rMd
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.28))
            .environment(\.colorScheme, .dark)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(GlassRim(radius: radius, strength: 1.05))
    }
}

extension View {
    func glassCard(_ radius: CGFloat = Theme.rLg, strong: Bool = false) -> some View {
        modifier(GlassCard(radius: radius, strong: strong))
    }
    func mediaGlass(_ radius: CGFloat = Theme.rMd) -> some View {
        modifier(MediaGlass(radius: radius))
    }
}

// Headline-Schriften: breite, konstruierte Caps.
extension Font {
    static func pitchDisplay(_ size: CGFloat, _ weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }
    static func pitchHead(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }
}
