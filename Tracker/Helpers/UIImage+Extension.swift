import UIKit

extension UIImage {
    static var emptyStatistics: UIImage { UIImage(named: "EmptyStatistics") ?? UIImage() }
    static var emptyTrackers: UIImage { UIImage(named: "EmptyTrackers") ?? UIImage() }
    static var notFounded: UIImage { UIImage(named: "NotFounded") ?? UIImage() }
    static var onboarding1: UIImage { UIImage(named: "Onboarding1") ?? UIImage() }
    static var onboarding2: UIImage { UIImage(named: "Onboarding2") ?? UIImage() }
    static var pinImage: UIImage { UIImage(named: "Pin") ?? UIImage() }
    static var chevron = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
    static var checkImage = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
    static var plusTracker = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
    static var tabStatistic = UIImage(systemName: "hare.fill")?.withRenderingMode(.alwaysTemplate)
    static var tabTracker = UIImage(systemName: "record.circle.fill")?.withRenderingMode(.alwaysTemplate)

}
