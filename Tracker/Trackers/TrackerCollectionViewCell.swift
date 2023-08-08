import UIKit
protocol TrackerCollectionViewCellDelegate: AnyObject {
    func getSelectedDate() -> Date?
    func updateTrackers()
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "CellTrackerCollection"
    weak var delegate: TrackerCollectionViewCellDelegate?
    private let currentDate: Date? = nil
    private var isCompletedToday: Bool = false
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
        label.textColor = .ypWhite
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

    private lazy var quantityDayLabel: UILabel = {
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

    private lazy var quantityDayButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 16
        button.tintColor = .ypWhite
        button.addTarget(self, action: #selector(tapQuantityButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int, at indexPath: IndexPath) {
        self.isCompletedToday = isCompletedToday
        self.trackerId = tracker.id
        self.indexPath = indexPath
        let color = tracker.color
        addSubviews()
        trackerView.backgroundColor = color
        quantityDayButton.backgroundColor = color
        titleLabel.text = tracker.title
        emodjiLabel.text = tracker.emodji
        let daysText = getDaysText(completedDays)
        quantityDayLabel.text = daysText
        checkCompletedToday()
        checkDate()
    }

    private func addSubviews() {
        addTrackerView()
        addStackView()
        addEmojiLabel()
        addTrackerTitleLabel()
        addCounterDayLabel()
        addAppendDayButton()
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
        stackView.addArrangedSubview(quantityDayLabel)
    }

   private func addAppendDayButton() {
        stackView.addArrangedSubview(quantityDayButton)
        NSLayoutConstraint.activate([
            quantityDayButton.widthAnchor.constraint(equalToConstant: 34),
            quantityDayButton.heightAnchor.constraint(equalToConstant: 34),
            quantityDayButton.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 8)
        ])
    }

    private func getDaysText(_ completedDays: Int) -> String {
        let lastTwoDigits = completedDays % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(completedDays) дней"
        } else {
            switch completedDays % 10 {
            case 1:
                return "\(completedDays) день"
            case 2...4:
                return "\(completedDays) дня"
            default:
                return "\(completedDays) дней"
            }
        }
    }

    private func checkCompletedToday() {
        let opacity: Float = isCompletedToday ? 0.3 : 1.0
        let image = isCompletedToday ? doneImage : plusImage
        quantityDayButton.setImage(image, for: .normal)
        quantityDayButton.layer.opacity = opacity
    }

    private func checkDate() {
        let selectedDate = delegate?.getSelectedDate() ?? Date()
        quantityDayButton.isEnabled = selectedDate <= currentDate ?? Date()
    }

    @objc
    private func tapQuantityButton() {
        guard let trackerId, let indexPath else {
            assert(false, "ID not found")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
}
