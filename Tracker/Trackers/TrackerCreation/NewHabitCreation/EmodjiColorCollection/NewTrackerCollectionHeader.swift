import UIKit

final class NewTrackerCollectionHeader: UICollectionReusableView {
    static let reuseIdentifier = "newTrackerCollectionHeader"

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createView() {
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
