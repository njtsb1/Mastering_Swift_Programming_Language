import Foundation

// MARK: - Enums
enum TruckBrand: String {
    case scania
    case volvo
    case mercedesBenz = "Mercedes-Benz"
    case volkswagen
    case iveco
    case daf = "DAF"
    case ford
}

// MARK: - Structs
struct SportTruck {
    var brand: TruckBrand
    var model: String
    var topSpeed: Double
}

// MARK: - Protocols & Extensions
protocol TruckProtocol {
    var truck: SportTruck { get }
    func accelerate() async
}

protocol TruckPilot {
    var name: String { get }
    func ride(truck: TruckProtocol) async
}

// Default protocol implementation supporting safe modern swift concurrency features
extension TruckProtocol {
    func accelerate() async {
        // Simulating an asynchronous processing delay before updating telemetry
        try? await Task.sleep(nanoseconds: 500_000_000)
        print("Accelerating the \(truck.brand.rawValue.capitalized) \(truck.model) up to \(truck.topSpeed) km/h (Electronically limited).")
    }
}

// MARK: - Implementations
struct TruckImpl: TruckProtocol {
    var truck: SportTruck
}

struct TruckPilotImpl: TruckPilot {
    var name: String
    
    func ride(truck: TruckProtocol) async {
        print("\(name) is driving the \(truck.truck.brand.rawValue.capitalized) \(truck.truck.model).")
        await truck.accelerate()
    }
}

// MARK: - Execution Flow

// Instantiating the new sport trucks dataset (All limited to 160.0 km/h)
let truck1 = SportTruck(brand: .scania, model: "T113 360cv", topSpeed: 160.0)
let truck2 = SportTruck(brand: .volvo, model: "NH12 360cv", topSpeed: 160.0)
let truck3 = SportTruck(brand: .mercedesBenz, model: "LS1938 380cv", topSpeed: 160.0)
let truck4 = SportTruck(brand: .volkswagen, model: "Worker 40.300 300cv", topSpeed: 160.0)
let truck5 = SportTruck(brand: .iveco, model: "Stralis 360cv", topSpeed: 160.0)
let truck6 = SportTruck(brand: .daf, model: "95 XF 380cv", topSpeed: 160.0)
let truck7 = SportTruck(brand: .ford, model: "Cargo 4331 330cv", topSpeed: 160.0)

// Instantiating the complete list of pilots
let pilots: [TruckPilot] = [
    TruckPilotImpl(name: "Drugovich"),
    TruckPilotImpl(name: "Giaffone"),
    TruckPilotImpl(name: "Cirino"),
    TruckPilotImpl(name: "Fleck"),
    TruckPilotImpl(name: "Fogaça"),
    TruckPilotImpl(name: "Totti"),
    TruckPilotImpl(name: "Marquez")
]

// All trucks available for the simulation
let allTrucks = [truck1, truck2, truck3, truck4, truck5, truck6, truck7]

// Simulating highly efficient multi-threaded async executions using Structured Concurrency (TaskGroup)
Task {
    print("=== Starting Real Multi-threaded Truck Simulation ===")
    
    await withTaskGroup(of: Void.self) { group in
        for pilot in pilots {
            // Adds concurrent child tasks into the group pool to execute simultaneously without blocks
            group.addTask {
                for truck in allTrucks {
                    await pilot.ride(truck: TruckImpl(truck: truck))
                }
            }
        }
    }
}
