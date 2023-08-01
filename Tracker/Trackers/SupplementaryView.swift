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

    override init(frame: CGRect) {
        super.init(frame: frame)
        addHeaderLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addHeaderLabel() {
        addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    func addHeader(_ header: String) {
        headerLabel.text = header
    }
}
