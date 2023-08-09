import UIKit

final class NewHabitCell: UITableViewCell {
    static let reuseIdentifier = "NewHabitCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String, categorySubtitle: String, scheduleSubtitle: String, isFirstRow: Bool) {
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
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if isFirstRow {
            detailTextLabel?.text = categorySubtitle
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            detailTextLabel?.text = scheduleSubtitle
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: bounds.width + 40)
        }
    }

    func configureEvent(with title: String, categorySubtitle: String) {
        textLabel?.text = title
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        detailTextLabel?.text = categorySubtitle
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        detailTextLabel?.textColor = .ypGray
        backgroundColor = .ypBackground
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }
}
