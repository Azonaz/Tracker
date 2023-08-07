import Foundation

struct TrackerRecord {
    let id: UUID
    let date: String
}

extension TrackerRecord: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
