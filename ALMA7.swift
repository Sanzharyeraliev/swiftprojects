// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int
    var module: Module?
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: Level 1 · Decoding Telemetry

func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP" else {
        return nil
    }
    return (sensor: parts.0, value: value)
}

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsed = parseLog(rawLog)
print("Valid: \(parsed.valid.count), invalid: \(parsed.invalidCount)")
let A = parsed.invalidCount


// MARK: Level 2 · Analysis

func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minVal = first
    var maxVal = first
    var sum = 0
    for value in values {
        if value < minVal { minVal = value }
        if value > maxVal { maxVal = value }
        sum += value
    }
    let avg = Double(sum) / Double(values.count)
    return (min: minVal, max: maxVal, average: avg)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) ?? (min: 0, max: 0, average: 0.0))
print(stats() == nil ? "nil" : "not nil")

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
print("O2 values: \(o2Values)")
let B = Int(stats(of: o2Values)?.average ?? 0.0)

let sorted1 = parsed.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

let sorted2 = parsed.valid.sorted(by: { a, b in
    return a.value > b.value
})

let sorted3 = parsed.valid.sorted(by: { a, b in
    a.value > b.value
})

let sorted4 = parsed.valid.sorted(by: { $0.value > $1.value })

let sorted5 = parsed.valid.sorted { $0.value > $1.value }

func sameReadings(_ a: [Reading], _ b: [Reading]) -> Bool {
    if a.count != b.count { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value { return false }
    }
    return true
}

let ladderMatches = sameReadings(sorted1, sorted2)
    && sameReadings(sorted2, sorted3)
    && sameReadings(sorted3, sorted4)
    && sameReadings(sorted4, sorted5)

print("Ladder results match: \(ladderMatches)")


// MARK: Level 3 · Temperature Stabilization

func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let protocolFn = chooseProtocol(for: temp)
        temp = protocolFn(temp)
        steps += 1
    }
    let stable = temp >= 18 && temp <= 24
    return (finalTemp: temp, steps: steps, isStable: stable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempReadings = select(parsed.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let lowestTemp = stats(of: tempValues)?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("Lowest temp: \(lowestTemp), steps to stable: \(C)")


// MARK: Level 4 · The Crew

func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    let state = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

for member in crew {
    print(status(of: member))
}

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    if amount <= 0 { return 0 }
    let available = min(amount, source)
    let space = min(available, 100 - target)
    if space <= 0 { return 0 }
    source -= space
    target += space
    return space
}

var labOxygen = lab.oxygenTank?.level ?? 0
var habOxygen = hab.oxygenTank?.level ?? 0
let transferred = transferOxygen(from: &labOxygen, to: &habOxygen, amount: 30)
print("Transferred: \(transferred), Lab: \(labOxygen), Hab: \(habOxygen)")
let D = habOxygen

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var result: [String] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        result.append(member.name)
    }
    var sorted: [String] = []
    var remaining = result
    while !remaining.isEmpty {
        var bestIndex = 0
        var bestPriority = roster[remaining[0]]?.priority ?? Int.max
        for i in 1..<remaining.count {
            let p = roster[remaining[i]]?.priority ?? Int.max
            if p < bestPriority {
                bestPriority = p
                bestIndex = i
            }
        }
        sorted.append(remaining[bestIndex])
        remaining.remove(at: bestIndex)
    }
    return sorted
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook

/*
 1. member.module! — force unwrap. У Nurlan module == nil, runtime crash.
 2. member.module!.oxygenTank! — второй force unwrap. У Dana модуль есть,
    но oxygenTank == nil, снова crash.
 3. result! в конце firstCritical — если критических нет, result == nil,
    снова crash. Функция должна возвращать String?.
 4. Логическая ошибка: цикл не прерывается после нахождения критического,
    result перезаписывается — возвращается ПОСЛЕДНИЙ критический, а не
    первый. На стартовых данных не видно, потому что критический один.
 */

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print(reportOxygen(for: crew[0]))
print(reportOxygen(for: crew[1]))

print(firstCritical(in: crew) ?? "none")

let testCrew = [
    CrewMember(name: "Alpha", role: "Test", priority: 1, module: Module(name: "T1", oxygenTank: Tank(level: 10))),
    CrewMember(name: "Beta",  role: "Test", priority: 2, module: Module(name: "T2", oxygenTank: Tank(level: 5))),
    CrewMember(name: "Gamma", role: "Test", priority: 3, module: nil)
]
print("First critical (should be Alpha): \(firstCritical(in: testCrew) ?? "none")")
print("First critical (nobody critical): \(firstCritical(in: [testCrew[2]]) ?? "none")")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var counter = 0
    return { level in
        if level < threshold {
            counter += 1
            print("Alarm #\(counter)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    guard let выходит из функции, если nil, поэтому дальше переменная
    гарантированно существует и не вложена в блок. if let оставляет код
    внутри блока. if let хуже при нескольких опциональных проверках
    получилась бы лесенка вложенных if let.

 2. Почему нельзя передать [Int] в stats(_ values: Int...):
    Variadic принимает список отдельных аргументов, а не массив.
    Внутри функции values имеет тип [Int], но снаружи массив не передать.
    Для массива есть перегрузка stats(of:).

 3. Почему transferOxygen(from: &x, to: &x, amount: 5) не компилируется:
    Два inout-параметра не могут ссылаться на одну переменную —
    overlapping access. Swift запрещает, чтобы не было гонки.

 4. Почему oxygenLevel(of: dana) ?? "no data" не компилируется:
    oxygenLevel возвращает Int?, а "no data" — String. ?? требует
    одинаковых типов. Нужно oxygenLevel(of: dana) ?? 0.

 5. Полный тип chooseProtocol:
    (Int) -> (Int) -> Int
    Принимает Int, возвращает функцию (Int) -> Int.

 Bonus. Где живёт счётчик после возврата makeAlarm:
    counter захвачен замыканием. Swift хранит захваченные переменные
    в куче в коробке, которая живёт, пока существует замыкание.
    Поэтому счётчик не уничтожается после выхода из makeAlarm.
*/