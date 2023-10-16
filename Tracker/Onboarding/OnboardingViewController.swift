import UIKit

final class OnboardingViewController: UIViewController {
    private let pageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    init(pageImageView: UIImage, text: String) {
        self.pageImageView.image = pageImageView
        self.textLabel.text = text
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func createView() {
        [pageImageView, textLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        activateConstrants()
    }

    private func activateConstrants() {
        NSLayoutConstraint.activate([
            pageImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageImageView.topAnchor.constraint(equalTo: view.topAnchor),
            pageImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -280)
        ])
    }
}
