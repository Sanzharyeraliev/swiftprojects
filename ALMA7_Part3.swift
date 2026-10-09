// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development - Module 5 - Lab Assignment
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: Level 1 - The Power Cell

// PowerCell is a class because the battery is shared mutable state: one cell
// per drone, every reference must see the same charge.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        if charge < 0 { self.charge = 0 }
        else if charge > 100 { self.charge = 100 }
        else { self.charge = charge }
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 { return false }
        if charge < amount { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 { return }
        charge += amount
        if charge > 100 { charge = 100 }
    }
}

// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

let testCell = PowerCell(charge: 120)
print("Clamped init: \(testCell.level())")
print("Spend 30: \(testCell.spend(30)), level: \(testCell.level())")
print("Spend 200: \(testCell.spend(200)), level: \(testCell.level())")
testCell.recharge(by: 50)
print("After recharge 50: \(testCell.level())")


// MARK: Level 2 - The Fleet

// `final` on runOnce() guarantees the ritual (spend then work) is identical
// for every drone. Subclasses change cost and work, never the order.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String { "\(id): \(cell.level())%" }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        if !cell.spend(powerCost) { return 0 }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id): seam welded" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: unknown drone kind '\(record.kind)' for id \(record.id)")
    }
}

for drone in fleet {
    print("Drone \(drone.statusLine)")
}


// MARK: Level 3 - The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)
print("Total work units: \(A)")

for drone in fleet {
    print(drone.statusLine)
}

var totalCharge = 0
for drone in fleet {
    totalCharge += drone.cell.level()
}
let B = totalCharge
print("Total remaining charge: \(B)")

var readyCount = 0
for drone in fleet {
    if drone.cell.level() >= drone.powerCost {
        readyCount += 1
    }
}
let C = readyCount
print("Drones ready for one more task: \(C)")


// MARK: Level 4 - Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Drone is a class: self is a reference, so methods can mutate stored state
// without the `mutating` keyword. Structs get `self` as a value and need it.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { HealthRule.statusCode(for: cell.level()) }
    func diagnose() -> String { "\(componentID): code \(statusCode)" }
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { HealthRule.statusCode(for: chargeLevel) }
    func diagnose() -> String { "\(componentID): sensor, code \(statusCode)" }

    mutating func recharge(by amount: Int) {
        if amount <= 0 { return }
        chargeLevel += amount
        if chargeLevel > 100 { chargeLevel = 100 }
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// [Drone] is a class array; SensorModule is a struct with no common ancestor,
// so only a protocol type can hold both.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var result = ""
    for component in components {
        result += component.diagnose() + "\n"
    }
    return result
}


// MARK: Level 5 - Shared Behaviour

struct HealthRule {
    static func statusCode(for level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}

extension Diagnosable {
    func diagnose() -> String { "\(componentID): code \(statusCode)" }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { HealthRule.statusCode(for: signalStrength) }
    func diagnose() -> String { "Legacy beacon \(name): signal \(signalStrength), code \(statusCode)" }
}

var allComponents: [Diagnosable] = []
for drone in fleet { allComponents.append(drone) }
for sensor in sensors { allComponents.append(sensor) }
allComponents.append(beacon)

print(diagnosticsReport(allComponents))

var sumStatus = 0
for component in allComponents {
    sumStatus += component.statusCode
}
let D = sumStatus
print("Sum of status codes: \(D)")

extension Int {
    var powerBar: String {
        var filled = self / 10
        if filled < 0 { filled = 0 }
        if filled > 10 { filled = 10 }
        var bar = ""
        for _ in 0..<filled { bar += "#" }
        for _ in filled..<10 { bar += "." }
        return bar
    }
}

print("42 -> \(42.powerBar)")
print("-5 -> \((-5).powerBar)")
print("250 -> \(250.powerBar)")


// MARK: Level 6 - Incident Reports

/*
 Report 1:
   Expected: PatchDrone overrides performTask, returns 30.
   Actual: does not compile. performTask exists in Drone, but without
   the override keyword the compiler does not see this as an override.
   Rule: if a method already exists in the parent, its override requires override.
   Fix:
     class PatchDrone: Drone {
         override func performTask() -> Int { return 30 }
     }

 Report 2:
   Expected: HeavyWelder overrides runOnce and returns 999.
   Actual: does not compile for two reasons. WelderDrone is marked final,
   so it cannot be subclassed. And runOnce in Drone is marked final,
   so it cannot be overridden.
   Rule: final on a class forbids subclassing; final on a method forbids
   overriding.
   Fix: remove final from WelderDrone and from runOnce, or do not subclass.

 Report 3:
   Expected: first.weldSeam() calls the WelderDrone method.
   Actual: does not compile. reportFleet is [Drone], so first is Drone.
   Drone has no weldSeam - only WelderDrone does.
   Rule: the array stores elements as Drone, so through first only Drone
   members are visible.
   Fix:
     if let welder = first as? WelderDrone {
         print(welder.weldSeam())
     }
   as? returns an optional because the array might hold a non-WelderDrone,
   and then the cast would fail.

 Report 4:
   Expected: parts[0].label() returns "thruster T-1" from Thruster.
   Actual: returns "generic component" from the extension. label() is not
   declared in the protocol, so it is not part of the contract. Calling it
   through [Labelled] makes Swift use the extension version, not the
   concrete type version.
   Rule: a method declared only in a protocol extension is dispatched
   statically, by the variable's type, not by the real object type.
   Fix: add func label() -> String to the Labelled protocol declaration.
 */


// MARK: Finale - Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly:
// 1. Runtime: in Drone.init, check type(of: self) == Drone.self, fatalError.
// 2. Compile time: make Drone.init private; subclasses have their own init.

protocol DroneProtocol {
    var id: String { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension DroneProtocol {
    func runOnce() -> Int { performTask() }
}

struct StructWelder: DroneProtocol {
    let id: String
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

// Class design wins here: drones share one mutable battery (PowerCell),
// and that shared reference is exactly what classes give for free.
// With structs each drone would carry its own copy of the cell state and
// mission control could not observe charge changes from a shared reference.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. A class satisfies `mutating` without the keyword because `self` in a
    class is a reference: mutating a property does not replace the value of
    self. A struct has `self` as a value, so changing it requires `mutating`.

 2. Inheritance: passing implementation down the tree - a subclass inherits
    stored properties, init, and methods from one parent. Protocols: a single
    type can conform to many protocols, and protocols unite classes, structs
    and enums, which a class hierarchy cannot do.

 3. `final` prevents overriding a method or subclassing a class. On runOnce()
    it protected the ritual: spend power then work. A subclass cannot skip
    the spend step or change the order.

 4. In Report 4 label() was declared only in the protocol extension, not in
    the protocol itself. Calling it through [Labelled] used static dispatch
    and picked the extension version. Adding label() to the protocol
    declaration turns it into a contract requirement, and then dynamic
    dispatch picks the real type's version.
*/