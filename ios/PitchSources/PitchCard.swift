import SwiftUI

struct PitchField: Identifiable {
    let id = UUID()
    let icon: String   // SF Symbol
    let label: String
    let value: String
}

let defaultPitchFields: [PitchField] = [
    .init(icon: "calendar", label: "Alter", value: "23"),
    .init(icon: "figure.soccer", label: "Position", value: "Innenverteidiger"),
    .init(icon: "mappin.and.ellipse", label: "Location", value: "Düsseldorf"),
    .init(icon: "shield.fill", label: "Aktueller Verein", value: "SV Düsseldorf 04"),
    .init(icon: "trophy.fill", label: "Aktuelle Liga", value: "Landesliga"),
]

// Die Pitchkarte – Herzstück des Profils (Spieler-Variante).
struct PitchCard: View {
    var name: String = "Marvin Neumann"
    var rating: String? = "8.4"   // nil = neue Karte, noch kein Rating
    var fields: [PitchField] = defaultPitchFields

    var body: some View {
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
                    Text("SPIELER")
                        .font(.system(size: 11, weight: .heavy)).kerning(1)
                        .foregroundStyle(Theme.textMuted)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Theme.surfaceAlt)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rSm))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Bild (rechts ~35%)
                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Theme.textFaint)
                    .frame(width: 110, height: 134)
                    .background(Theme.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
            }

            Rectangle().fill(Theme.line).frame(height: 1)

            // Felder
            VStack(spacing: 12) {
                ForEach(fields) { f in
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
    }
}

#Preview {
    ZStack { Theme.bg.ignoresSafeArea(); PitchCard().padding() }
        .preferredColorScheme(Theme.scheme)
}
