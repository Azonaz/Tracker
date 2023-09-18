import Foundation

enum Weekday: String, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var weekdayFullName: String {
            switch self {
            case .monday: return NSLocalizedString("monday", comment: "")
            case .tuesday: return NSLocalizedString("tuesday", comment: "")
            case .wednesday: return NSLocalizedString("wednesday", comment: "")
            case .thursday: return NSLocalizedString("thursday", comment: "")
            case .friday: return NSLocalizedString("friday", comment: "")
            case .saturday: return NSLocalizedString("saturday", comment: "")
            case .sunday: return NSLocalizedString("sunday", comment: "")
            }
        }

    var weekdayShortName: String {
            switch self {
            case .monday: return NSLocalizedString("mon", comment: "")
            case .tuesday: return NSLocalizedString("tue", comment: "")
            case .wednesday: return NSLocalizedString("wed", comment: "")
            case .thursday: return NSLocalizedString("thu", comment: "")
            case .friday: return NSLocalizedString("fri", comment: "")
            case .saturday: return NSLocalizedString("sat", comment: "")
            case .sunday: return NSLocalizedString("sun", comment: "")
            }
        }

    var weekdayInNumber: Int {
        switch self {
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        case .sunday: return 1
        }
    }
}
