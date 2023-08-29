import UIKit

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    func configure(with title: String, isFirstRow: Bool, isLastRow: Bool, isSelected: Bool) {
        textLabel?.text = title
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        backgroundColor = .ypBackground
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectionStyle = .none
        accessoryType = isSelected ? .checkmark : .none
        if isFirstRow && isLastRow {
            layer.cornerRadius = 16
        } else if isFirstRow {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastRow {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }
    }
}
