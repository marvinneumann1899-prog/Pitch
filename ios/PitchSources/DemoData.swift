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

    // ---------- Coaches (AIDropzone) ----------
    DemoProfile(
        name: "Patrick Heigl", role: "Coach", icon: "flame.fill",
        bio: "Cheftrainer mit Hang zum mutigen Offensivfußball. Klare Ansprache, hohe Intensität, kurze Wege. Ich entwickle Spieler über Verantwortung.",
        fields: [f("calendar","Alter","38"), f("clock.fill","Erfahrung","9 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Kreisliga A"), f("mappin.and.ellipse","Location","Hohenlohe"),
                 f("shield.fill","Verein","TSV Waldenburg"), f("rectangle.3.group","Aufstellung","4-2-3-1")],
        followers: 173, network: 38,
        posts: [
            DemoPost(category: "Highlight", caption: "Umschaltspiel sitzt — so wollen wir Fußball spielen.", rating: nil, icon: "flame.fill", time: "vor 6 Std"),
            DemoPost(category: "Information", caption: "Suche zur neuen Saison zwei Außenverteidiger mit Tempo.", rating: nil, icon: "binoculars.fill", time: "vor 2 Tagen"),
        ]),

    DemoProfile(
        name: "Ali Küstner", role: "Coach", icon: "flame.fill",
        bio: "Trainer aus Leidenschaft. Ballbesitz, sauberes Positionsspiel, ruhige Hand am Spielfeldrand. Fußball ist für mich Kopf und Herz.",
        fields: [f("calendar","Alter","43"), f("clock.fill","Erfahrung","13 Jahre"),
                 f("trophy.fill","Aktuelle Liga","Kreisliga B"), f("mappin.and.ellipse","Location","Schwäbisch Hall"),
                 f("shield.fill","Verein","TSV Untersteinbach"), f("rectangle.3.group","Aufstellung","3-4-3")],
        followers: 211, network: 47,
        posts: [
            DemoPost(category: "Erfolg", caption: "Verdienter Heimsieg, drei Punkte bleiben da. Stark, Jungs.", rating: nil, icon: "trophy.fill", time: "vor 1 Tag"),
        ]),

    // ---------- Vereine (AIDropzone) ----------
    DemoProfile(
        name: "TSV Waldenburg", role: "Verein", icon: "trophy.fill",
        bio: "Dorfverein mit großem Herz im Hohenlohekreis. Bei uns zählen Zusammenhalt und Bock auf Fußball. Neue Gesichter immer willkommen.",
        fields: [f("calendar","Gegründet","1947"), f("trophy.fill","Liga","Kreisliga A"),
                 f("mappin.and.ellipse","Location","Waldenburg"), f("sportscourt.fill","Heimstätte","Sportplatz Waldenburg"),
                 f("person.3.fill","Sucht","Mittelfeld, Sturm")],
        followers: 642, network: 31,
        posts: [
            DemoPost(category: "Information", caption: "Trainingsauftakt Dienstag 19 Uhr — alle Neuen herzlich willkommen!", rating: nil, icon: "soccerball", time: "vor 4 Std"),
        ]),

    DemoProfile(
        name: "TSV Untersteinbach", role: "Verein", icon: "trophy.fill",
        bio: "Bodenständiger Verein mit aktiver Jugend. Wir leben Amateurfußball — ehrlich, kämpferisch, mit klarer Perspektive für junge Spieler.",
        fields: [f("calendar","Gegründet","1925"), f("trophy.fill","Liga","Kreisliga B"),
                 f("mappin.and.ellipse","Location","Pfedelbach"), f("sportscourt.fill","Heimstätte","Steinbachstadion"),
                 f("person.3.fill","Sucht","Torwart, Abwehr")],
        followers: 488, network: 26,
        posts: [
            DemoPost(category: "Erfolg", caption: "Aufstiegsrennen bleibt spannend — danke an die starke Kulisse!", rating: nil, icon: "trophy.fill", time: "vor 1 Tag"),
        ]),

    DemoProfile(
        name: "TSV Pfedelbach", role: "Verein", icon: "trophy.fill",
        bio: "Traditionsclub mit Ambitionen. Geordnete Strukturen, guter Platz, treue Fans. Wer den nächsten Schritt sucht, ist bei uns richtig.",
        fields: [f("calendar","Gegründet","1921"), f("trophy.fill","Liga","Kreisliga A"),
                 f("mappin.and.ellipse","Location","Pfedelbach"), f("sportscourt.fill","Heimstätte","Sportzentrum Pfedelbach"),
                 f("person.3.fill","Sucht","Flügel, IV")],
        followers: 734, network: 35,
        posts: [
            DemoPost(category: "Information", caption: "Heimspiel am Sonntag 15 Uhr — kommt vorbei und supportet!", rating: nil, icon: "soccerball", time: "vor 5 Std"),
        ]),
]

// Lookup nach Name (Feed/Suche/Mitteilungen referenzieren dieselben Leute)
func demoProfile(for name: String) -> DemoProfile? {
    demoPeople.first { $0.name == name }
}
