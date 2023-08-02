import UIKit

final class NewHabitCell: UITableViewCell {
    static let reuseIdentifier = "NewHabitCell"
    
    private lazy var chevronImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = .chevron
        imageView.tintColor = .ypGray
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        createCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createCell() {
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.textColor = .ypBlack
        detailTextLabel?.textColor = .ypGray
        layoutMargins = .zero
        separatorInset = .zero
        contentView.addSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
