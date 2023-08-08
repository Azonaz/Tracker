import UIKit

class ScheduleCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleCell"

    let switchWeekday: UISwitch = {
        let button = UISwitch()
        button.onTintColor = .ypBlue
        return button
    }()

    func configure( with title: String, isFirstRow: Bool, isLastRow: Bool) {
        textLabel?.text = title
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        backgroundColor = .ypBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true
        selectionStyle = .none
        accessoryView = switchWeekday
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if isFirstRow {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width + 40)
        } else {
            layer.cornerRadius = 0
        }
    }
}
