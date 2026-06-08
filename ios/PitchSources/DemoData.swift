import SwiftUI

// MARK: - Demo-Personen
//
// Realistische, FREI ERFUNDENE Amateurfußball-Profile (NRW). Keine echten Personendaten.
// Zentrale Quelle, damit Feed, Suche, Mitteilungen und Profile dieselben Leute zeigen
// und jedes Profil individuell wirkt (eigene Bio, Werte, Attribute, Stats).

struct DemoPost: Identifiable {
    let id = UUID()
    let category: String      // Highlight / Erfolg / Information
    let caption: String
    let rating: String?       // nur sinnvoll bei Spieler-Highlights
    let icon: String
    let time: String
}

struct DemoProfile {
    let name: String
    let role: String          // Spieler / Coach / Scout / Verein
    let icon: String
    let bio: String
    let fields: [PitchField]
    var attributes: [String] = []   // nur Spieler
    var jersey: String? = nil       // nur Spieler
    let followers: Int
    let network: Int
    let posts: [DemoPost]
}

// Schnellbau-Helfer für Felder
private func f(_ icon: String, _ label: String, _ value: String) -> PitchField {
    PitchField(icon: icon, label: label, value: value)
}

let demoPeople: [DemoProfile] = [

    // ---------- Spieler ----------
    DemoProfile(
        name: "Leon Bäcker", role: "Spieler", icon: "soccerball",
        bio: "Linker Flügelstürmer, schnell und direkt. Suche den Sprung in die Oberliga — diszipliniert, ehrgeizig, immer den Abschluss suchend.",
        fields: [f("calendar","Alter","21"), f("figure.soccer","Position","Linksaußen"),
                 f("mappin.and.ellipse","Location","Düsseldorf"), f("shield.fill","Verein","SV Düsseldorf 04"),
                 f("trophy.fill","Liga","Landesliga")],
        attributes: ["Schnelligkeit","Dribbling","Abschluss"], jersey: "11",
        followers: 312, network: 41,
        posts: [
            DemoPost(category: "Highlight", caption: "Freistoßtor von der Strafraumkante — Wochenende war stark.", rating: "8.9", icon: "soccerball", time: "vor 2 Std"),
            DemoPost(category: "Highlight", caption: "Solo über den Flügel und eiskalt abgeschlossen.", rating: "8.4", icon: "figure.soccer", time: "vor 3 Tagen"),
        ]),

    DemoProfile(
        name: "Jonas Weber", role: "Spieler", icon: "soccerball",
        bio: "Innenverteidiger mit Spieleröffnung. Lese das Spiel früh, gewinne meine Zweikämpfe. Will den nächsten Schritt gehen.",
        fields: [f("calendar","Alter","24"), f("figure.soccer","Position","Innenverteidiger"),
                 f("mappin.and.ellipse","Location","Köln"), f("shield.fill","Verein","FC Pesch"),
                 f("trophy.fill","Liga","Kreisliga A")],
        attributes: ["Zweikampf","Kopfball","Übersicht"], jersey: "4",
        followers: 156, network: 28,
        posts: [
            DemoPost(category: "Highlight", caption: "Zwei Tackles, ein Assist. Defensive stand wie eine Wand.", rating: "7.8", icon: "soccerball", time: "vor 6 Std"),
        ]),

    DemoProfile(
        name: "Marco Stein", role: "Spieler", icon: "soccerball",
        bio: "Box-to-Box im Mittelfeld. Laufstark, robust, immer ansprechbar. Lebe für die englischen Wochen.",
        fields: [f("calendar","Alter","23"), f("figure.soccer","Position","Zentrales Mittelfeld"),
                 f("mappin.and.ellipse","Location","Essen"), f("shield.fill","Verein","ETB SW Essen"),
                 f("trophy.fill","Liga","Bezirksliga")],
        attributes: ["Ausdauer","Passspiel","Physis"], jersey: "8",
        followers: 203, network: 33,
        posts: [
            DemoPost(category: "Highlight", caption: "Doppelpack im Derby. Tag könnte nicht besser sein.", rating: "8.4", icon: "soccerball", time: "vor 8 Std"),
        ]),

    // ---------- Coaches ----------
    DemoProfile(
        name: "Mehmet Demir", role: "Coach", icon: "flame.fill",
        bio: "A-Lizenz-Trainer mit klarer Spielidee: mutig, ballbesitzorientiert, intensiv im Gegenpressing. Entwickle Spieler gezielt weiter.",
        fields: [f("calendar","Alter","41"), f("clock.fill","Erfahrung","12 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Oberliga"), f("mappin.and.ellipse","Location","Düsseldorf"),
                 f("shield.fill","Verein","TuRU Düsseldorf"), f("rectangle.3.group","Aufstellung","4-3-3")],
        followers: 487, network: 76,
        posts: [
            DemoPost(category: "Highlight", caption: "Pressing-Drill aus dem Training. Intensität war top.", rating: nil, icon: "flame.fill", time: "gestern"),
            DemoPost(category: "Information", caption: "Suche für die Rückrunde einen schnellen Außenstürmer.", rating: nil, icon: "binoculars.fill", time: "vor 2 Tagen"),
        ]),

    DemoProfile(
        name: "Andreas Pohl", role: "Coach", icon: "flame.fill",
        bio: "Jugendcoach aus Überzeugung. B-Lizenz. Mir geht es um Persönlichkeit und Spaß — Ergebnisse kommen dann von selbst.",
        fields: [f("calendar","Alter","36"), f("clock.fill","Erfahrung","7 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Bezirksliga (A-Jugend)"), f("mappin.and.ellipse","Location","Neuss"),
                 f("shield.fill","Verein","VfR Neuss"), f("rectangle.3.group","Aufstellung","4-4-2")],
        followers: 198, network: 44,
        posts: [
            DemoPost(category: "Erfolg", caption: "Meine A-Jugend ist Herbstmeister! Stolz auf die Jungs.", rating: nil, icon: "trophy.fill", time: "vor 4 Std"),
        ]),

    DemoProfile(
        name: "Sven Krüger", role: "Coach", icon: "flame.fill",
        bio: "Torwarttrainer. Detailarbeit, Fußarbeit, Strafraumbeherrschung. Keeper sind kein Anhängsel — sie gewinnen Spiele.",
        fields: [f("calendar","Alter","45"), f("clock.fill","Erfahrung","15 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Regionalliga"), f("mappin.and.ellipse","Location","Duisburg"),
                 f("shield.fill","Verein","MSV-Nachwuchs"), f("rectangle.3.group","Spezialgebiet","Torwart")],
        followers: 254, network: 51,
        posts: [
            DemoPost(category: "Information", caption: "Torwart-Workshop am Samstag — noch 3 Plätze frei.", rating: nil, icon: "figure.soccer", time: "vor 1 Tag"),
        ]),

    // ---------- Scout ----------
    DemoProfile(
        name: "Lena Groß", role: "Scout", icon: "binoculars.fill",
        bio: "Talentscout für den Amateur- und Nachwuchsbereich in NRW. Auge fürs Detail, ehrliches Feedback. Ich finde den nächsten Sprung.",
        fields: [f("clock.fill","Erfahrung","6 Jahre"), f("mappin.and.ellipse","Location","Dortmund"),
                 f("building.2.fill","Organisation","NRW Talent Network"), f("binoculars.fill","Fokus-Liga","Landesliga / Oberliga")],
        followers: 612, network: 94,
        posts: [
            DemoPost(category: "Information", caption: "Bin am Wochenende bei den Landesliga-Spielen unterwegs. Wer sticht raus?", rating: nil, icon: "binoculars.fill", time: "vor 4 Std"),
        ]),

    // ---------- Vereine ----------
    DemoProfile(
        name: "TSV Eller 04", role: "Verein", icon: "trophy.fill",
        bio: "Traditionsverein aus Düsseldorf-Eller. Familiär, ehrgeizig, mit klarem Plan nach oben. Wir suchen Verstärkung für die Rückrunde.",
        fields: [f("calendar","Gegründet","1904"), f("trophy.fill","Liga","Bezirksliga"),
                 f("mappin.and.ellipse","Location","Düsseldorf"), f("sportscourt.fill","Heimstätte","Sportpark Eller"),
                 f("person.3.fill","Sucht","Stürmer, IV")],
        followers: 1240, network: 63,
        posts: [
            DemoPost(category: "Erfolg", caption: "Aufstieg in die Bezirksliga klargemacht! Jetzt suchen wir Verstärkung.", rating: nil, icon: "trophy.fill", time: "vor 5 Std"),
            DemoPost(category: "Information", caption: "Tag der offenen Tür am Sonntag — kommt vorbei!", rating: nil, icon: "soccerball", time: "vor 3 Tagen"),
        ]),

    DemoProfile(
        name: "SV Düsseldorf 04", role: "Verein", icon: "trophy.fill",
        bio: "Ambitionierter Landesligist mit starker Jugendarbeit. Bei uns bekommen junge Spieler echte Spielzeit und eine Perspektive.",
        fields: [f("calendar","Gegründet","1904"), f("trophy.fill","Liga","Landesliga"),
                 f("mappin.and.ellipse","Location","Düsseldorf"), f("sportscourt.fill","Heimstätte","Paul-Janes-Stadion"),
                 f("person.3.fill","Sucht","Torwart, Flügel")],
        followers: 2180, network: 88,
        posts: [
            DemoPost(category: "Erfolg", caption: "Unser Torwart hat verlängert! Drei weitere Jahre zwischen den Pfosten.", rating: nil, icon: "trophy.fill", time: "gestern"),
        ]),
]

// Lookup nach Name (Feed/Suche/Mitteilungen referenzieren dieselben Leute)
func demoProfile(for name: String) -> DemoProfile? {
    demoPeople.first { $0.name == name }
}
