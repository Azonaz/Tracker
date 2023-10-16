import UIKit

final class StatisticViewController: UIViewController {

    let descriptions = ["bestPeriod", "perfectDays", "trackersСompleted", "averageValue"]
    private let trackerRecordStore: TrackerRecordStoreProtocol = TrackerRecordStore()

    private lazy var statisticCardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var placeholderImage: UIImageView = {
        let image = UIImageView()
        image.image = .emptyStatistics
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private lazy var placeholderText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = statisticPlaceholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(placeholderImage)
        stackView.addArrangedSubview(placeholderText)
        return stackView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticCardStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        configureStatisticCardViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }

    private func createView() {
        view.backgroundColor = .ypWhite
        title = NSLocalizedString("statistic", comment: "")
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        [placeholderStackView, statisticCardStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticCardStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            statisticCardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticCardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func checkPlaceholder() {
        if doneTrackersCount() == "0" {
            placeholderStackView.isHidden = false
            statisticCardStackView.isHidden = true
        } else {
            placeholderStackView.isHidden = true
            statisticCardStackView.isHidden = false
        }
    }

    private func createStatisticCardView(with data: String, description: String) -> StatisticCardView {
        let statisticCardView = StatisticCardView()
        statisticCardStackView.addArrangedSubview(statisticCardView)
        statisticCardView.translatesAutoresizingMaskIntoConstraints = false
        statisticCardView.leadingAnchor.constraint(equalTo: statisticCardStackView.leadingAnchor).isActive = true
        statisticCardView.trailingAnchor.constraint(equalTo: statisticCardStackView.trailingAnchor).isActive = true
        statisticCardView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        statisticCardView.resultLabel.text = data
        statisticCardView.descriptionLabel.text = NSLocalizedString(description, comment: "")
        return statisticCardView
    }

    private func configureStatisticCardViews() {
        checkPlaceholder()
        let doneTrackers = doneTrackersCount()
        let statisticData: [String] = ["0", "0", doneTrackers, "0"]
        for (index, description) in descriptions.enumerated() {
            if let data = statisticData[safe: index] {
                _ = createStatisticCardView(with: data, description: description)
            }
        }
    }

    private func doneTrackersCount() -> String {
        return String(trackerRecordStore.doneTrackersCount())
    }
}
