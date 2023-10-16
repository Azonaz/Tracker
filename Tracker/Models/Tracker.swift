import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emodji: String
    let schedule: [Weekday]
    let isPinned: Bool
}
