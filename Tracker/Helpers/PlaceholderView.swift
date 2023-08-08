import UIKit

final class PlaceholderView: UIView {
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = 200
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(image: UIImage, title: String) {
        super.init(frame: .zero)
        placeholderImageView.image = image
        placeholderTitleLabel.text = title
        translatesAutoresizingMaskIntoConstraints = false
        addPlaceholderView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addPlaceholderView() {
        self.addSubview(placeholderImageView)
        self.addSubview(placeholderTitleLabel)
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderTitleLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderTitleLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor)
        ])
    }
}
