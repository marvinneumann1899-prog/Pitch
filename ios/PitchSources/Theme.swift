import SwiftUI

// Pitch Design-System mit umschaltbaren Paletten.
// „Grün" (lime, unsere Version) bleibt erhalten; „classic" = Farben von Marvins Bruder.
// Umschalten: Theme.active = .lime  oder  .classic

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

    // Unsere Version – dark + electric lime
    static let lime = Palette(
        dark: true, bg: 0x0B0B0C, surface: 0x141419, surfaceAlt: 0x1C1C24, line: 0x2A2A33,
        text: 0xFFFFFF, textMuted: 0x9A9AA3, textFaint: 0x62626B,
        accent: 0xC6FF3A, accentText: 0x0B0B0C, danger: 0xFF4D4D, success: 0x2BD576
    )

    // Marvins Bruder – Primär #CC0000 (rot, aus „#CCOOO"), Sekundär #E8F4FD (hellblau) als heller Look
    static let classic = Palette(
        dark: false, bg: 0xE8F4FD, surface: 0xFFFFFF, surfaceAlt: 0xDCEAF8, line: 0xC4D8EA,
        text: 0x0E2233, textMuted: 0x5B7088, textFaint: 0x9FB4C8,
        accent: 0xCC0000, accentText: 0xFFFFFF, danger: 0xCC0000, success: 0x1B9E5A
    )
}

enum Theme {
    // >>> AKTIVE PALETTE HIER UMSCHALTEN <<<
    static var active: Palette = .lime

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

    // Radius
    static let rSm: CGFloat = 10
    static let rMd: CGFloat = 16
    static let rLg: CGFloat = 22
    static let rPill: CGFloat = 999
}

// Headline-Schriften: breite, konstruierte Caps (KickBase-Charakter). Bleiben für beide Paletten gleich.
extension Font {
    static func pitchDisplay(_ size: CGFloat, _ weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }
    static func pitchHead(_ size: CGFloat, _ weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight).width(.expanded)
    }
}
