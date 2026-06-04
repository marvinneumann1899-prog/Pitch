import SwiftUI

struct PitchField: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
}

// Rollenspezifische Standard-Felder
func defaultFields(for role: String) -> [PitchField] {
    switch role {
    case "Trainer":
        return [
            .init(icon: "calendar",            label: "Alter",                   value: "34"),
            .init(icon: "clock.fill",           label: "Erfahrung",               value: "8 Jahre"),
            .init(icon: "trophy.fill",          label: "Aktuelle Liga",           value: "Kreisliga"),
            .init(icon: "mappin.and.ellipse",   label: "Location",                value: "Düsseldorf"),
            .init(icon: "shield.fill",          label: "Aktueller Verein",        value: "SV Düsseldorf 04"),
            .init(icon: "rectangle.3.group",    label: "Aufstellung",             value: "4-3-3"),
        ]
    case "Scout":
        return [
            .init(icon: "clock.fill",           label: "Erfahrung",               value: "5 Jahre"),
            .init(icon: "mappin.and.ellipse",   label: "Location",                value: "Düsseldorf"),
            .init(icon: "building.2.fill",      label: "Organisation",            value: "FC Beispiel"),
            .init(icon: "binoculars.fill",      label: "Fokus-Liga",              value: "Landesliga / Oberliga"),
        ]
    default: // Spieler
        return [
            .init(icon: "calendar",            label: "Alter",                   value: "23"),
            .init(icon: "figure.soccer",        label: "Position",                value: "Innenverteidiger"),
            .init(icon: "mappin.and.ellipse",   label: "Location",                value: "Düsseldorf"),
            .init(icon: "shield.fill",          label: "Aktueller Verein",        value: "SV Düsseldorf 04"),
            .init(icon: "trophy.fill",          label: "Aktuelle Liga",           value: "Landesliga"),
        ]
    }
}

// Diagonale Ecken-Akzente: oben-rechts + unten-links, jeweils von Mitte zu Mitte
private struct CornerAccents: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // Oben-rechts: Mitte oben → Ecke oben-rechts → Mitte rechts
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        // Unten-links: Mitte unten → Ecke unten-links → Mitte links
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        return p
    }
}

struct PitchCard: View {
    var name: String = "Marvin Neumann"
    var rating: String? = "8.4"
    var fields: [PitchField]? = nil
    var profileImage: UIImage? = nil
    var roleLabel: String = "Spieler"

    private var resolvedFields: [PitchField] {
        fields ?? defaultFields(for: roleLabel)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    // Rating + Name (links)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("RATING")
                            .font(.system(size: 11, weight: .heavy)).kerning(1.5)
                            .foregroundStyle(Theme.textFaint)
                        if let rating {
                            Text(rating)
                                .font(.pitchDisplay(52)).kerning(-1)
                                .foregroundStyle(Theme.accent)
                        } else {
                            Text("–")
                                .font(.pitchDisplay(52)).kerning(-1)
                                .foregroundStyle(Theme.textFaint)
                        }
                        Text(name)
                            .font(.pitchHead(20))
                            .foregroundStyle(Theme.text)
                            .padding(.top, 8)
                        Text(roleLabel.uppercased())
                            .font(.system(size: 11, weight: .heavy)).kerning(1)
                            .foregroundStyle(Theme.textMuted)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Theme.surfaceAlt)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.rSm))
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Bild (~35%)
                    ZStack {
                        if let img = profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Theme.surfaceAlt
                            VStack(spacing: 6) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Theme.accent.opacity(0.7))
                                Text("Foto")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Theme.textFaint)
                            }
                        }
                    }
                    .frame(width: 110, height: 134)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rMd)
                        .stroke(profileImage != nil ? Theme.accent : Theme.line, lineWidth: 1))
                }

                Rectangle().fill(Theme.line).frame(height: 1)

                VStack(spacing: 12) {
                    ForEach(resolvedFields) { f in
                        HStack(spacing: 0) {
                            Image(systemName: f.icon)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 26, alignment: .leading)
                            Text(f.label)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.textMuted)
                                .frame(width: 120, alignment: .leading)
                            Text(f.value)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.text)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(16)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
            .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))

            // Diagonale Ecken-Akzente (oben-rechts + unten-links)
            CornerAccents()
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .padding(1)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            PitchCard(roleLabel: "Spieler").padding(.horizontal)
            PitchCard(name: "M. Demir", rating: nil, roleLabel: "Trainer").padding(.horizontal)
            PitchCard(name: "L. Groß", rating: nil, roleLabel: "Scout").padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Theme.bg)
    .preferredColorScheme(Theme.scheme)
}
