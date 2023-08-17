import UIKit

final class NewTrackerSubtitleCell: UITableViewCell {
    static let reuseIdentifier = "NewHabitCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, categorySubtitle: String, scheduleSubtitle: String,
                   isFirstRow: Bool, isLastRow: Bool) {
        textLabel?.text = title
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        detailTextLabel?.textColor = .ypGray
        backgroundColor = .ypBackground
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        if isFirstRow {
            detailTextLabel?.text = categorySubtitle
            if !isLastRow {
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        } else {
            detailTextLabel?.text = scheduleSubtitle
            if isLastRow {
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
    }
}
