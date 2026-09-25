// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: Level 1 · The Deck Register

enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = mass / 500
        let clamped = step > 3 ? 3 : step
        return AlarmLevel(rawValue: clamped) ?? .green
    }
}

print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))


// MARK: Level 2 · The Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else { return .unknown(raw: line) }
        return .crate(id: id, massKg: mass)

    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else { return .unknown(raw: line) }
        return .container(code: parts[1], massKg: mass)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let perUnit = Int(parts[3]) else { return .unknown(raw: line) }
        return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)

    default:
        return .unknown(raw: line)
    }
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    if case .unknown = entry { unknownCount += 1 }
}
print("Total manifest mass: \(totalMass), unknown lines: \(unknownCount)")
let A = totalMass


// MARK: Level 3 · Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen -= amount
        if oxygen < 0 { oxygen = 0 }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Warning: unknown deck '\(record.deck)' for \(record.name)")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}

for member in crewRoster {
    print("\(member.name): \(member.deck.rawValue), O2 \(member.oxygen)")
}

var original = CrewSnapshot(name: "Timur", deck: .engine, oxygen: 62)
var copy = original
copy.breathe(20)
print("Copy: \(copy.oxygen), original: \(original.oxygen)")

func drain(_ snapshot: CrewSnapshot) -> CrewSnapshot {
    var local = snapshot
    local.breathe(30)
    return local
}
let drained = drain(original)
print("Returned from plain function: \(drained.oxygen), original: \(original.oxygen)")

func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
}
drainInPlace(&original)
print("After inout: \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil { return false }
        if chargeLevel < 20 { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let current = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return current
    }
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)
print("Start: \(pod.chargeLevel)")

let timur = CrewSnapshot(name: "Timur", deck: .engine, oxygen: 62)
let dana = CrewSnapshot(name: "Dana", deck: .lab, oxygen: 48)
let nurlan = CrewSnapshot(name: "Nurlan", deck: .cargo, oxygen: 17)

pod.load(timur); pod.fire()
print("After Timur: \(pod.chargeLevel)")

pod.load(dana); pod.fire()
print("After Dana: \(pod.chargeLevel)")

pod.load(nurlan); pod.fire()
print("After Nurlan: \(pod.chargeLevel)")

pod.fire()
print("After empty fire: \(pod.chargeLevel)")

let C = pod.chargeLevel

let podRef = pod
podRef.chargeLevel = 5
print("pod: \(pod.chargeLevel), podRef: \(podRef.chargeLevel)")

var snapA = CrewSnapshot(name: "Test", deck: .bridge, oxygen: 100)
var snapB = snapA
snapB.oxygen = 50
print("snapA: \(snapA.oxygen), snapB: \(snapB.oxygen)")


// MARK: Level 5 · Station Systems

final class Station {
    let callSign: String

    var hullIntegrity: Int {
        willSet {
            print("hullIntegrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 { hullIntegrity = 100 }
            if hullIntegrity < 0 { hullIntegrity = 0 }
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "Diagnostics for \(callSign):\n"
        for deck in Deck.allCases {
            let level = oxygenByDeck[deck] ?? 0
            report += "  \(deck.rawValue): \(level)%\n"
        }
        return report
    }()

    var oxygenByDeck: [Deck: Int]

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values { sum += value }
        return sum
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, hullIntegrity: Int, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        self.oxygenByDeck = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Skipping unknown deck: \(reading.deck)")
                continue
            }
            oxygenByDeck[deck] = reading.oxygen
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 87, readings: deckReadings)
let B = station.averageOxygen
print("Starting averageOxygen: \(B)")

print(station.fullDiagnostics)
print(station.fullDiagnostics)

station.hullIntegrity = 130
print("After 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("After -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("After 55: \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports

/*
 Report 1:
   Expected: цикл изменит элементы roster, кислород экипажа снизится.
   Actual: `for var member in roster` создаёт копию каждого элемента;
   изменения применяются к копии и теряются. roster не меняется.
   Rule: struct — value type. При итерации `for ... in` элемент — копия.
   Fix:
     for i in 0..<roster.count {
         roster[i].oxygen -= 10
     }

 Report 2:
   Expected: podA.chargeLevel == 100, podB — отдельная копия.
   Actual: podA и podB ссылаются на один объект (reference type),
   изменение через podB меняет podA. Выведет 0.
   Rule: class — reference type, `let podB = podA` копирует ссылку.
   Fix: если нужны два независимых пода — создать второй через init.

 Report 3:
   Expected: метод add дополнит entries.
   Actual: не компилируется. Метод не помечен `mutating`, но меняет
   stored property структуры.
   Rule: методы struct, изменяющие self, обязаны быть `mutating`.
   Fix:
     mutating func add(_ entry: String) {
         entries.append(entry)
     }

 Report 4:
   Expected: оба присваивания — ошибки, раз объявлены через let.
   Actual: `snapshot.oxygen = 40` — ошибка компиляции, `pod.chargeLevel = 10`
   — компилируется.
   Rule: для struct `let` замораживает саму величину — менять нельзя ни одно
   поле. Для class `let` замораживает только ссылку — свойства объекта
   менять можно, если они объявлены `var`.
   Fix: либо `var snapshot = ...`, либо не менять snapshot.
 */


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private: снаружи нельзя ни прочитать, ни заменить список, ни очистить его.
    private var entries: [String] = []
    // private(set): снаружи можно читать, но нельзя менять (в т.ч. вернуть false).
    private(set) var isSealed = false

    // fileprivate: доступен только внутри этого файла — нужен для auditTranscript.
    fileprivate func formattedTranscript() -> String {
        var result = ""
        for entry in entries { result += entry + "\n" }
        return result
    }

    var entryCount: Int {
        entries.count
    }

    var transcript: String {
        formattedTranscript()
    }

    func add(_ entry: String) {
        if isSealed { return }
        entries.append(entry)
    }

    func seal() {
        isSealed = true
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    "Audit (\(recorder.entryCount) entries):\n" + recorder.formattedTranscript()
}

let recorder = FlightRecorder()
recorder.add("Day 9: teleporter nominal")
recorder.add("Day 10: incident reported")
print(auditTranscript(of: recorder))
recorder.seal()
recorder.add("This should not appear")
print(recorder.entryCount)
print(recorder.transcript)

/*
 // Снаружи типа следующие строки не компилируются:
 // recorder.entries = []
 //    error: 'entries' is inaccessible due to 'private' protection level
 // recorder.isSealed = false
 //    error: cannot assign to property: 'isSealed' setter is inaccessible
 // recorder.formattedTranscript()
 //    error: 'formattedTranscript' is inaccessible due to 'fileprivate' protection level
 */


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

final class BonusPod {
    let id: String
    var chargeLevel: Int

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
    }

    deinit {
        print("deinit: \(id)")
    }
}

print("Before do-block")
var held: BonusPod?
do {
    let temp = BonusPod(id: "B-1", chargeLevel: 50)
    held = temp
    print("Inside do-block: \(temp.id)")
}
print("After do-block (still alive, held)")
held = nil
print("After releasing held (deinit should fire above)")

func samePod(_ a: TeleportPod, _ b: TeleportPod) -> Bool {
    a === b
}

let podX = TeleportPod(id: "X", chargeLevel: 30)
let podY = podX
let podZ = TeleportPod(id: "X", chargeLevel: 30)
print("podX === podY: \(samePod(podX, podY))")
print("podX === podZ: \(samePod(podX, podZ))")

/*
 === не применим к CrewSnapshot, потому что === работает только со ссылками
 на объекты классов. CrewSnapshot — struct (value type), у него нет ссылки,
 которую можно было бы сравнить. Два одинаковых struct — это два независимых
 значения, у каждого свой адрес в стеке/куче, и язык не даёт оператора для их
 сравнения по идентичности.
 */


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. CrewSnapshot это struct, поэтому Swift сам создаёт инициализатор
    с параметрами name, deck, oxygen. TeleportPod это class, у классов
    такого автоматического инициализатора нет, поэтому его пишем руками.

 2. mutating говорит компилятору, что метод меняет self. У struct self это
    само значение, и чтобы его изменить, его надо передать как inout.
    Классам mutating не нужен, потому что self это ссылка на объект,
    а свойства меняются внутри объекта, сама ссылка при этом не меняется.

 3. В Report 4:
    - Для struct let замораживает всё значение целиком, поэтому нельзя
      менять ни одно свойство.
    - Для class let замораживает только ссылку, переназначить переменную
      нельзя, но свойства объекта менять можно, если они объявлены как var.
    Поэтому snapshot.oxygen = 40 не компилируется, а pod.chargeLevel = 10
    компилируется.

 4. lazy обязан быть var, потому что значение вычисляется позже, при первом
    обращении, и записывается в свойство, то есть свойство меняется.
    lazy меняет поведение программы, когда вычисление имеет побочные эффекты.
    Например, fullDiagnostics печатает Running full scan... только при первом
    обращении. Если к свойству не обращаться, оно вообще не вычислится,
    это уже не про скорость, а про логику.

 5. private был бы слишком строг для formattedTranscript(). Функция
    auditTranscript(of:) объявлена снаружи FlightRecorder, в том же файле,
    и должна читать транскрипт. С private свободная функция доступа не
    получит. fileprivate открывает метод всему файлу, но не выпускает
    его за пределы модуля.

 Bonus. deinit срабатывает на строке held = nil, потому что после этого
 на объект не остаётся сильных ссылок и ARC освобождает память. Внутри
 do-блока объект ещё жив, потому что held держит вторую ссылку. Оператор ===
 не работает на CrewSnapshot, потому что это struct, у значения нет
 идентичности, есть только содержимое.
*/