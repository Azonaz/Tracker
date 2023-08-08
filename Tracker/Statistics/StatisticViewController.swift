import UIKit

final class StatisticViewController: UIViewController {

    private lazy var placeholderView: UIView = {
        PlaceholderView(
            image: .emptyStatistics,
            title: "Анализировать пока нечего"
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        title = "Статистика"
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(placeholderView)
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
