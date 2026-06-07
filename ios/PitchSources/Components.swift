import SwiftUI

// MARK: - Button

struct PitchButton: View {
    enum Variant { case primary, ghost, outline }
    let label: String
    var variant: Variant = .primary
    var systemImage: String? = nil
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage).font(.system(size: 15, weight: .bold)) }
                Text(label).font(.system(size: 15, weight: .heavy)).kerning(0.5)
            }
            .foregroundStyle(fg)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.rPill)
                    .stroke(Theme.line, lineWidth: variant == .outline ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.rPill))
        }
        .buttonStyle(.plain)
    }

    private var bg: Color {
        switch variant {
        case .primary: return Theme.accent
        case .ghost: return Theme.surfaceAlt
        case .outline: return .clear
        }
    }
    private var fg: Color { variant == .primary ? Theme.accentText : Theme.text }
}

// MARK: - Chip

struct Chip: View {
    let label: String
    var active: Bool = false
    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 11, weight: .bold))
            .kerning(0.5)
            .foregroundStyle(active ? Theme.accentText : Theme.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(active ? Theme.accent : Theme.surfaceAlt)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(active ? Theme.accent : Theme.line, lineWidth: 1))
    }
}

// MARK: - Avatar (SF Symbol statt Emoji)

struct Avatar: View {
    var size: CGFloat = 44
    var systemName: String = "person.fill"
    var name: String? = nil   // gesetzt → farbiger Kreis mit Initialen (Profilbild-Optik)

    // Avatar-Farbpalette (kräftig, gut unterscheidbar)
    private static let palette: [UInt] = [
        0x2BD576, 0x3A8DFF, 0xFF6B4D, 0xB46BFF, 0xFFB23E,
        0xFF4D8D, 0x18C2C2, 0xC6FF3A, 0x7A5BFF, 0xFF8A3D
    ]

    private var initials: String {
        guard let name, !name.isEmpty else { return "" }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private var color: Color {
        guard let name else { return Theme.surfaceAlt }
        let idx = abs(name.hashValue) % Self.palette.count
        return Color(hex: Self.palette[idx])
    }

    var body: some View {
        Group {
            if let name, !name.isEmpty {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(
                        LinearGradient(colors: [color, color.opacity(0.72)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
            } else {
                Image(systemName: systemName)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(Theme.textMuted)
                    .frame(width: size, height: size)
                    .background(Theme.surfaceAlt)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Theme.line, lineWidth: 1))
            }
        }
    }
}

// MARK: - Section label

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .kerning(1.2)
            .foregroundStyle(Theme.textFaint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
    }
}

// MARK: - Card container

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
            .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
    }
}
