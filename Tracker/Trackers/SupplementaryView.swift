import UIKit

final class SupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = "SupplementaryView"

    private lazy var headerLabel: UILabel = {
       let label = UILabel()
        label.tintColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

     func addHeaderLabel() {
         addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }

    func configure(from title: String) {
        headerLabel.text = title
        addHeaderLabel()
    }
}
