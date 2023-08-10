import UIKit

class MockData {
    static let shared = MockData()

    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Дом", trackers: [
            Tracker(id: UUID(), title: "Кот", color: .colorSelection1, emodji: emodjies[0],
                    schedule: [Weekday.monday, Weekday.wednesday]),
            Tracker(id: UUID(), title: "Цветы", color: .colorSelection2, emodji: emodjies[1],
                    schedule: [Weekday.monday, Weekday.saturday]),
            Tracker(id: UUID(), title: "Уборка", color: .colorSelection3, emodji: emodjies[4],
                    schedule: [Weekday.tuesday, Weekday.friday])
        ]),
        TrackerCategory(title: "Важное", trackers: [
            Tracker(id: UUID(), title: "Бот", color: .colorSelection4, emodji: emodjies[7],
                    schedule: [Weekday.monday, Weekday.saturday, Weekday.sunday]),
            Tracker(id: UUID(), title: "Гот", color: .colorSelection6, emodji: emodjies[9],
                    schedule: [Weekday.wednesday, Weekday.sunday])
        ]),
        TrackerCategory(title: "Здоровье", trackers: [
            Tracker(id: UUID(), title: "Витаминки", color: .colorSelection7, emodji: emodjies[8],
                    schedule: [Weekday.monday, Weekday.sunday])
        ])
    ]

    func update(categories: [TrackerCategory]) {
        self.categories.append(contentsOf: categories)
    }

    private init() { }
}
