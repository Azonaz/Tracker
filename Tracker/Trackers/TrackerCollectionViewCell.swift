import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func getSelectedDate() -> Date
    func updateTrackers()
    func doneTracker(id: UUID, at indexPath: IndexPath)
    func undoneTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CellTrackerCollection"
    weak var delegate: TrackerCollectionViewCellDelegate?
    private let currentDate: Date? = nil
    private var isDoneToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?

    private lazy var trackerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var emodjiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var countDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var plusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize) ?? UIImage()
        return image
    }()

    private lazy var doneImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 12)
        let image = UIImage(systemName: "checkmark", withConfiguration: pointSize) ?? UIImage()
        return image
    }()

    private lazy var countDayButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(tapCountDayButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    func configure(with tracker: Tracker, isDoneToday: Bool, doneDays: Int, at indexPath: IndexPath) {
        self.isDoneToday = isDoneToday
        self.trackerId = tracker.id
        self.indexPath = indexPath
        let color = tracker.color
        createSubviews()
        trackerView.backgroundColor = color
        countDayButton.backgroundColor = color
        titleLabel.text = tracker.title
        emodjiLabel.text = tracker.emodji
        let daysText = getDaysText(doneDays)
        countDayLabel.text = daysText
        checkDoneToday()
        checkDate()
    }

    private func createSubviews() {
        addTrackerView()
        addStackView()
        addEmojiLabel()
        addTrackerTitleLabel()
        addCounterDayLabel()
        addCountDayButton()
    }

    private func addTrackerView() {
        contentView.addSubview(trackerView)
        NSLayoutConstraint.activate([
            trackerView.heightAnchor.constraint(equalToConstant: 90),
            trackerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func addStackView() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: trackerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }

    private func addEmojiLabel() {
        trackerView.addSubview(emodjiLabel)
        NSLayoutConstraint.activate([
            emodjiLabel.widthAnchor.constraint(equalToConstant: 24),
            emodjiLabel.heightAnchor.constraint(equalToConstant: 24),
            emodjiLabel.topAnchor.constraint(equalTo: trackerView.topAnchor, constant: 12),
            emodjiLabel.leadingAnchor.constraint(equalTo: trackerView.leadingAnchor, constant: 12)
        ])
    }

    private func addTrackerTitleLabel() {
        trackerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: emodjiLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: trackerView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerView.trailingAnchor, constant: -12)
        ])
    }

    private func addCounterDayLabel() {
        stackView.addArrangedSubview(countDayLabel)
    }

    private func addCountDayButton() {
        stackView.addArrangedSubview(countDayButton)
        NSLayoutConstraint.activate([
            countDayButton.widthAnchor.constraint(equalToConstant: 34),
            countDayButton.heightAnchor.constraint(equalToConstant: 34),
            countDayButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 8)
        ])
    }

    func getDaysText(_ doneDays: Int) -> String {
        let formatDaysString: String = NSLocalizedString("daysAmount", comment: "")
        let resultDaysString: String = String.localizedStringWithFormat(formatDaysString, doneDays)
        return resultDaysString
    }

    private func checkDoneToday() {
        let opacity: Float = isDoneToday ? 0.3 : 1.0
        let image = isDoneToday ? doneImage : plusImage
        countDayButton.setImage(image, for: .normal)
        countDayButton.layer.opacity = opacity
    }

    private func checkDate() {
        let selectedDate = delegate?.getSelectedDate() ?? Date()
        countDayButton.isEnabled = selectedDate <= currentDate ?? Date()
    }

    @objc
    private func tapCountDayButton() {
        guard let trackerId, let indexPath else {
            assert(false, "ID not found")
            return
        }
        if isDoneToday {
            delegate?.undoneTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.doneTracker(id: trackerId, at: indexPath)
        }
    }
}
