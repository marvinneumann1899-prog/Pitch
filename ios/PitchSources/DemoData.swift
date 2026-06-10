import SwiftUI

// MARK: - Demo-Personen (Marvins echte Freunde — Bilder gebündelt aus AIDropzone)
//
// Profil-/Clipbilder liegen in PitchSources/Media (siehe bundledImage()).
// Zentrale Quelle: Feed, Suche, Profile zeigen dieselben Leute.

struct DemoPost: Identifiable {
    let id = UUID()
    let category: String      // Highlight / Erfolg / Information
    let caption: String
    let rating: String?
    let icon: String
    let time: String
    var image: String? = nil  // gebündelter Clip (z. B. "clip1")
}

struct DemoProfile {
    let name: String
    let role: String          // Spieler / Coach / Verein
    let icon: String
    let bio: String
    let fields: [PitchField]
    var attributes: [String] = []   // nur Spieler
    var jersey: String? = nil
    let followers: Int
    let network: Int
    var image: String? = nil  // gebündeltes Profilbild (z. B. "p_nick")
    let posts: [DemoPost]
}

private func f(_ icon: String, _ label: String, _ value: String) -> PitchField {
    PitchField(icon: icon, label: label, value: value)
}

let demoPeople: [DemoProfile] = [

    // ---------- Spieler (TSV Untersteinbach & Co.) ----------
    DemoProfile(
        name: "Nick Neumann", role: "Spieler", icon: "soccerball",
        bio: "Linksaußen mit Tempo und Zug zum Tor. Diszipliniert, ehrgeizig, immer den Abschluss suchend. Will den nächsten Schritt gehen.",
        fields: [f("calendar","Alter","21"), f("figure.soccer","Position","Linksaußen"),
                 f("mappin.and.ellipse","Ort","Untersteinbach"), f("shield.fill","Verein","TSV Untersteinbach"),
                 f("trophy.fill","Liga","Kreisliga A")],
        attributes: ["Schnelligkeit","Dribbling","Abschluss"], jersey: "11",
        followers: 284, network: 39, image: "p_nick",
        posts: [
            DemoPost(category: "Highlight", caption: "Solo über den Flügel und eiskalt gemacht. Wochenende war stark.", rating: "8.7", icon: "soccerball", time: "vor 2 Std", image: "clip1"),
            DemoPost(category: "Highlight", caption: "Freistoß sitzt — Training zahlt sich aus.", rating: "8.3", icon: "soccerball", time: "vor 3 Tagen", image: "clip4"),
        ]),

    DemoProfile(
        name: "Sebastian Herzog", role: "Spieler", icon: "soccerball",
        bio: "Zentraler Stürmer, kopfballstark und abschlusssicher. Lebe für die Box und die wichtigen Tore.",
        fields: [f("calendar","Alter","22"), f("figure.soccer","Position","Mittelstürmer"),
                 f("mappin.and.ellipse","Ort","Untersteinbach"), f("shield.fill","Verein","TSV Untersteinbach"),
                 f("trophy.fill","Liga","Kreisliga A")],
        attributes: ["Abschluss","Kopfball","Physis"], jersey: "9",
        followers: 312, network: 44, image: "p_herzog",
        posts: [
            DemoPost(category: "Highlight", caption: "Doppelpack im Derby — Tag könnte nicht besser sein.", rating: "9.1", icon: "soccerball", time: "vor 5 Std", image: "clip2"),
        ]),

    DemoProfile(
        name: "Christian Rau", role: "Spieler", icon: "soccerball",
        bio: "Spielmacher im Zentrum. Übersicht, ruhiger Fuß, gefährliche Standards. Ich mache das Spiel.",
        fields: [f("calendar","Alter","24"), f("figure.soccer","Position","Zentrales Mittelfeld"),
                 f("mappin.and.ellipse","Ort","Schwäbisch Hall"), f("shield.fill","Verein","SV APAG"),
                 f("trophy.fill","Liga","Bezirksliga")],
        attributes: ["Passspiel","Übersicht","Standards"], jersey: "10",
        followers: 256, network: 41, image: "p_rau",
        posts: [
            DemoPost(category: "Highlight", caption: "Traumpass aufs Tablett serviert. Assist des Tages.", rating: "8.5", icon: "soccerball", time: "vor 6 Std", image: "clip3"),
        ]),

    DemoProfile(
        name: "Hagen Philipp", role: "Spieler", icon: "soccerball",
        bio: "Box-to-Box-Mittelfeld, laufstark und robust. Kompromisslos im Zweikampf, immer ansprechbar. Lebe für die englischen Wochen.",
        fields: [f("calendar","Alter","22"), f("figure.soccer","Position","Zentrales Mittelfeld"),
                 f("mappin.and.ellipse","Ort","Untersteinbach"), f("shield.fill","Verein","TSV Untersteinbach"),
                 f("trophy.fill","Liga","Kreisliga A")],
        attributes: ["Ausdauer","Zweikampf","Passspiel"], jersey: "8",
        followers: 221, network: 36, image: "p_hagen",
        posts: [
            DemoPost(category: "Highlight", caption: "Box-to-Box bis zum Schluss. Drei Punkte bleiben da.", rating: "8.2", icon: "soccerball", time: "gestern", image: "clip6"),
        ]),

    DemoProfile(
        name: "Paul Sonnwald", role: "Spieler", icon: "soccerball",
        bio: "Rechter Verteidiger mit Offensivdrang. Sichere Flanken, viel Tempo über außen.",
        fields: [f("calendar","Alter","21"), f("figure.soccer","Position","Rechtsverteidiger"),
                 f("mappin.and.ellipse","Ort","Untersteinbach"), f("shield.fill","Verein","TSV Untersteinbach"),
                 f("trophy.fill","Liga","Kreisliga A")],
        attributes: ["Schnelligkeit","Flanken","Ausdauer"], jersey: "2",
        followers: 167, network: 29, image: "p_philipp",
        posts: [
            DemoPost(category: "Highlight", caption: "Über außen durchgezogen und Flanke serviert.", rating: "7.8", icon: "soccerball", time: "gestern", image: "clip1"),
        ]),

    // ---------- Trainer ----------
    DemoProfile(
        name: "Patrick Heigl", role: "Coach", icon: "flame.fill",
        bio: "Cheftrainer mit Hang zum mutigen Offensivfußball. Klare Ansprache, hohe Intensität. Ich entwickle Spieler über Verantwortung.",
        fields: [f("calendar","Alter","38"), f("clock.fill","Erfahrung","9 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Kreisliga A"), f("mappin.and.ellipse","Ort","Untersteinbach"),
                 f("shield.fill","Verein","TSV Untersteinbach"), f("rectangle.3.group","Aufstellung","4-2-3-1")],
        followers: 173, network: 38, image: "c_heigl",
        posts: [
            DemoPost(category: "Information", caption: "Suche zur Rückrunde zwei schnelle Außenspieler.", rating: nil, icon: "binoculars.fill", time: "vor 6 Std", image: "clip2"),
        ]),

    DemoProfile(
        name: "Ali Küstner", role: "Coach", icon: "flame.fill",
        bio: "Trainer aus Leidenschaft. Ballbesitz, sauberes Positionsspiel, ruhige Hand am Spielfeldrand. Fußball ist Kopf und Herz.",
        fields: [f("calendar","Alter","43"), f("clock.fill","Erfahrung","13 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Kreisliga A"), f("mappin.and.ellipse","Ort","Waldenburg"),
                 f("shield.fill","Verein","TSV Waldenburg"), f("rectangle.3.group","Aufstellung","3-4-3")],
        followers: 211, network: 47, image: "c_kuestner",
        posts: [
            DemoPost(category: "Erfolg", caption: "Verdienter Heimsieg, drei Punkte bleiben da. Stark, Jungs.", rating: nil, icon: "trophy.fill", time: "vor 1 Tag", image: "clip3"),
        ]),

    // ---------- Verein ----------
    DemoProfile(
        name: "TSV Untersteinbach", role: "Verein", icon: "trophy.fill",
        bio: "Bodenständiger Verein mit aktiver Jugend. Wir leben Amateurfußball — ehrlich, kämpferisch, mit klarer Perspektive für junge Spieler.",
        fields: [f("calendar","Gegründet","1925"), f("trophy.fill","Liga","Kreisliga A"),
                 f("mappin.and.ellipse","Ort","Pfedelbach"), f("sportscourt.fill","Heimstätte","Sportplatz Untersteinbach"),
                 f("person.3.fill","Sucht","Torwart, Abwehr")],
        followers: 642, network: 31,
        posts: [
            DemoPost(category: "Information", caption: "Trainingsauftakt Dienstag 19 Uhr — alle Neuen herzlich willkommen!", rating: nil, icon: "soccerball", time: "vor 4 Std", image: "clip5"),
        ]),
]

func demoProfile(for name: String) -> DemoProfile? {
    demoPeople.first { $0.name == name }
}
