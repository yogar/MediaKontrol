import Foundation

actor DestinationRegistry {
    private var destinations: [String: any MediaDestination] = [:]
    private(set) var activeDestinationId: String?

    var allDestinations: [any MediaDestination] {
        Array(destinations.values)
    }

    var activeDestination: (any MediaDestination)? {
        guard let id = activeDestinationId else { return nil }
        return destinations[id]
    }

    func register(_ destination: any MediaDestination) {
        destinations[destination.id] = destination
        if activeDestinationId == nil {
            activeDestinationId = destination.id
        }
    }

    func setActive(id: String) {
        guard destinations[id] != nil else { return }
        activeDestinationId = id
    }

    func availableDestinations() async -> [any MediaDestination] {
        var available: [any MediaDestination] = []
        for destination in destinations.values {
            if await destination.isAvailable() {
                available.append(destination)
            }
        }
        return available
    }
}
