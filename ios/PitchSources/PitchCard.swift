import SwiftUI

struct PitchField: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    let value: String
}

// Max. auswählbare Attribute
let maxAttributes = 3

// Auswählbare Attribute je Rolle (Label/Tag, keine Zahlenwerte).
// Nur Spieler + Coach haben Attribute — Scout/Verein keine.
func attributesFor(role: String) -> [String] {
    switch role {
    case "Trainer", "Coach":
        return ["Taktik", "Motivation", "Mannschaftsführung", "Trainingssteuerung",
                "Kommunikation", "Spielanalyse", "Disziplin", "Spielerentwicklung"]
    case "Spieler":
        return ["Schnelligkeit", "Physis", "Dribbling", "Schuss", "Passspiel", "Übersicht",
                "Zweikampf", "Kopfball", "Technik", "Ausdauer", "Antritt", "Abschluss",
                "Spielintelligenz", "Flanken", "Standards", "Defensive"]
    default:
        return []   // Scout, Vereinsverantwortlicher: keine Attribute
    }
}

// Rollenspezifische Standard-Felder
func defaultFields(for role: String) -> [PitchField] {
    switch role {
    case "Trainer":
        return [
            .init(icon: "calendar",            label: "Alter",                   value: "34"),
            .init(icon: "clock.fill",           label: "Erfahrung",               value: "8 Jahre"),
            .init(icon: "trophy.fill",          label: "Aktuelle Liga",           value: "Kreisliga"),
            .init(icon: "mappin.and.ellipse",   label: "Ort",                value: "Düsseldorf"),
            .init(icon: "shield.fill",          label: "Aktueller Verein",        value: "SV Düsseldorf 04"),
            .init(icon: "rectangle.3.group",    label: "Aufstellung",             value: "4-3-3"),
        ]
    case "Scout":
        return [
            .init(icon: "clock.fill",           label: "Erfahrung",               value: "5 Jahre"),
            .init(icon: "mappin.and.ellipse",   label: "Ort",                value: "Düsseldorf"),
            .init(icon: "building.2.fill",      label: "Organisation",            value: "FC Beispiel"),
            .init(icon: "binoculars.fill",      label: "Fokus-Liga",              value: "Landesliga / Oberliga"),
        ]
    case "Verein", "Vereinsverantwortlicher":
        return [
            .init(icon: "calendar",             label: "Gegründet",               value: "1904"),
            .init(icon: "trophy.fill",          label: "Liga",                    value: "Bezirksliga"),
            .init(icon: "mappin.and.ellipse",   label: "Ort",                value: "Düsseldorf"),
            .init(icon: "sportscourt.fill",     label: "Heimstätte",              value: "Sportpark Eller"),
            .init(icon: "person.3.fill",        label: "Sucht",                   value: "Stürmer, IV"),
        ]
    default: // Spieler
        return [
            .init(icon: "calendar",            label: "Alter",                   value: "23"),
            .init(icon: "figure.soccer",        label: "Position",                value: "Innenverteidiger"),
            .init(icon: "mappin.and.ellipse",   label: "Ort",                value: "Düsseldorf"),
            .init(icon: "shield.fill",          label: "Aktueller Verein",        value: "SV Düsseldorf 04"),
            .init(icon: "trophy.fill",          label: "Aktuelle Liga",           value: "Landesliga"),
        ]
    }
}

// Diagonale Ecken-Akzente: oben-rechts + unten-links, jeweils von Mitte zu Mitte
private struct CornerAccents: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        return p
    }
}

struct PitchCard: View {
    var name: String = "Marvin Neumann"
    var fields: [PitchField]? = nil
    var profileImage: UIImage? = nil
    var roleLabel: String = "Spieler"
    var jerseyNumber: String? = "10"          // nur Spieler; nil = ausgeblendet
    var attributes: [String] = ["Schnelligkeit", "Zweikampf", "Kopfball"]
    var onAddAttribute: (() -> Void)? = nil    // non-nil = + Chip (eigenes Profil/Edit)
    var photoFallback: Bool = false            // true = Demo-Porträt laden, wenn kein eigenes Bild
    var imageName: String? = nil               // gebündeltes Profilbild (z. B. "p_nick")

    private var resolvedFields: [PitchField] {
        fields ?? defaultFields(for: roleLabel)
    }
    // Trikotnummer nur bei Spieler
    private var showJersey: Bool { roleLabel == "Spieler" && (jerseyNumber?.isEmpty == false) }
    // Attribute nur bei Rollen, die welche haben (Spieler, Coach)
    private var roleHasAttributes: Bool { !attributesFor(role: roleLabel).isEmpty }
    // Name aufteilen: erstes Wort = Vorname, Rest = Nachname
    private var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
    private var lastName: String {
        let parts = name.split(separator: " ").map(String.init)
        return parts.count > 1 ? parts.dropFirst().joined(separator: " ") : ""
    }

    private var photoPlaceholder: some View {
        ZStack {
            Theme.surfaceAlt
            VStack(spacing: 6) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22)).foregroundStyle(Theme.accent.opacity(0.7))
                Text("Foto").font(.system(size: 10, weight: .semibold)).foregroundStyle(Theme.textFaint)
            }
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 14) {
                // Kopf: Name + Rolle + #Nummer (links), Bild (rechts)
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Vorname oben, Nachname unten
                        VStack(alignment: .leading, spacing: -2) {
                            Text(firstName)
                                .font(.pitchHead(22))
                                .foregroundStyle(Theme.text)
                            if !lastName.isEmpty {
                                Text(lastName)
                                    .font(.pitchHead(22))
                                    .foregroundStyle(Theme.text)
                            }
                        }
                        .lineLimit(1)
                        HStack(spacing: 8) {
                            Text(roleLabel.uppercased())
                                .font(.system(size: 11, weight: .heavy)).kerning(1)
                                .foregroundStyle(Theme.accentText)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Theme.accent)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.rSm))
                            if showJersey {
                                Text("#\(jerseyNumber!)")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundStyle(Theme.text)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Bild (~35%)
                    ZStack {
                        if let img = profileImage {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else if let ui = bundledImage(imageName) {
                            Image(uiImage: ui).resizable().scaledToFill()
                        } else if photoFallback {
                            RemoteImage(url: avatarPhotoURL(name)) { photoPlaceholder }
                        } else {
                            photoPlaceholder
                        }
                    }
                    .frame(width: 104, height: 124)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rMd)
                        .stroke(profileImage != nil ? Theme.accent : Theme.line, lineWidth: 1))
                }

                // Attribute (Tags, max. 3) — über dem Strich. Nur Spieler + Coach.
                if roleHasAttributes && (!attributes.isEmpty || onAddAttribute != nil) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: 8)], alignment: .leading, spacing: 8) {
                        ForEach(attributes, id: \.self) { attr in
                            Text(attr)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(Theme.accent.opacity(0.12))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.accent.opacity(0.4), lineWidth: 1))
                        }
                        // + Chip nur solange unter Maximum (max. 3)
                        if let onAddAttribute, attributes.count < maxAttributes {
                            Button(action: onAddAttribute) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus").font(.system(size: 10, weight: .heavy))
                                    Text("Attribut").font(.system(size: 11, weight: .bold))
                                }
                                .foregroundStyle(Theme.textMuted)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .frame(maxWidth: .infinity)
                                .background(Theme.surfaceAlt)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.line, style: StrokeStyle(lineWidth: 1, dash: [3])))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Rectangle().fill(Theme.line).frame(height: 1)

                // Felder (Angaben)
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

            CornerAccents()
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .padding(1)
        }
    }
}

// Schlichtes Akteur-Profil für Coach / Scout / Verein.
// Kein Trading-Card-Look (keine Ecken-Akzente), keine Attribute, keine Trikotnummer.
struct ActorCard: View {
    var name: String = "Name"
    var roleLabel: String = "Coach"        // "Trainer"/"Coach", "Scout", "Verein"
    var profileImage: UIImage? = nil
    var fields: [PitchField]? = nil
    var bio: String = ""
    var photoFallback: Bool = false            // true = Demo-Porträt laden (Fremdprofil)
    var imageName: String? = nil               // gebündeltes Profilbild

    private var resolvedFields: [PitchField] { fields ?? defaultFields(for: roleLabel) }
    private var roleIcon: String {
        switch roleLabel {
        case "Verein", "Vereinsverantwortlicher": return "shield.fill"
        case "Scout":                             return "binoculars.fill"
        default:                                  return "flame.fill"
        }
    }

    private var crestPlaceholder: some View {
        ZStack {
            Theme.surfaceAlt
            Image(systemName: roleIcon).font(.system(size: 24)).foregroundStyle(Theme.accent.opacity(0.8))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    if let img = profileImage {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else if let ui = bundledImage(imageName) {
                        Image(uiImage: ui).resizable().scaledToFill()
                    } else if !isClubName(name) && photoFallback {
                        RemoteImage(url: avatarPhotoURL(name)) { crestPlaceholder }  // Person → Foto
                    } else {
                        crestPlaceholder            // Verein oder eigenes/Onboarding → Icon
                    }
                }
                .frame(width: 64, height: 64).clipShape(Circle())
                .overlay(Circle().stroke(profileImage != nil ? Theme.accent : Theme.line, lineWidth: 1))

                VStack(alignment: .leading, spacing: 7) {
                    Text(name).font(.pitchHead(20)).foregroundStyle(Theme.text).lineLimit(2)
                    Text(roleLabel.uppercased())
                        .font(.system(size: 11, weight: .heavy)).kerning(1)
                        .foregroundStyle(Theme.accentText)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rSm))
                }
                Spacer(minLength: 0)
            }

            if !bio.isEmpty {
                Text(bio).font(.system(size: 13)).foregroundStyle(Theme.text).lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            .frame(width: 130, alignment: .leading)
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

// Attribut-Auswahl (Sheet) — Tags an/abwählen, max. 3, rollenabhängig
struct AttributePicker: View {
    @Binding var selected: [String]
    var role: String = "Spieler"
    @Environment(\.dismiss) private var dismiss

    private var options: [String] { attributesFor(role: role) }
    private var full: Bool { selected.count >= maxAttributes }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ATTRIBUTE").font(.pitchHead(18)).kerning(0.5).foregroundStyle(Theme.text)
                        Text("Wähle bis zu \(maxAttributes) · \(selected.count)/\(maxAttributes)")
                            .font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                    }
                    Spacer()
                    Button("Fertig") { dismiss() }
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], alignment: .leading, spacing: 10) {
                        ForEach(options, id: \.self) { attr in
                            let active = selected.contains(attr)
                            let locked = !active && full   // Maximum erreicht → nicht anwählbar
                            Button {
                                withAnimation(.easeOut(duration: 0.12)) {
                                    if active { selected.removeAll { $0 == attr } }
                                    else if !full { selected.append(attr) }
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: active ? "checkmark" : "plus")
                                        .font(.system(size: 10, weight: .heavy))
                                    Text(attr).font(.system(size: 12, weight: .bold))
                                }
                                .foregroundStyle(active ? Theme.accentText : (locked ? Theme.textFaint : Theme.text))
                                .padding(.horizontal, 12).padding(.vertical, 9)
                                .frame(maxWidth: .infinity)
                                .background(active ? Theme.accent : Theme.surface)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(active ? Color.clear : Theme.line, lineWidth: 1))
                                .opacity(locked ? 0.5 : 1)
                            }
                            .buttonStyle(.plain)
                            .disabled(locked)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .preferredColorScheme(Theme.scheme)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            PitchCard(roleLabel: "Spieler", onAddAttribute: {}).padding(.horizontal)
            PitchCard(name: "M. Demir", roleLabel: "Trainer", attributes: ["Taktik", "Motivation"]).padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Theme.bg)
    .preferredColorScheme(Theme.scheme)
}
