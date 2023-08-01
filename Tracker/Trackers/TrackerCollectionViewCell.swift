import UIKit
protocol TrackerCollectionViewCellDelegate: AnyObject {
    
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "cellTrackerCollection"
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emodjiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var quantityLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var quantityButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.setPreferredSymbolConfiguration((.init(pointSize: 12)), forImageIn: .normal)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapQuantityButton), for: .touchUpInside)
        return button
    }()
    
    private var days: [String] = ["день", "дня", "дней"]
    private var quantity: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            emodjiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emodjiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emodjiLabel.heightAnchor.constraint(equalToConstant: 24),
            emodjiLabel.widthAnchor.constraint(equalToConstant: 24),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            quantityButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            quantityButton.heightAnchor.constraint(equalToConstant: 34),
            quantityButton.widthAnchor.constraint(equalToConstant: 34),
            quantityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            quantityLabel.trailingAnchor.constraint(equalTo: quantityButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: quantityButton.centerYAnchor)
        ])
    }
    
    private func addViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(colorView)
        colorView.addSubview(emodjiLabel)
        colorView.addSubview(titleLabel)
        contentView.addSubview(quantityButton)
        contentView.addSubview(quantityLabel)
        activateConstraints()
    }
    
    @objc
    private func tapQuantityButton() {
        
    }
    
    private func addQuantityLabelText() {
        switch quantity {
        case 1:
            quantityLabel.text = "\(quantity) \(days[0])"
        case 2...4:
            quantityLabel.text = "\(quantity) \(days[1])"
        default:
            quantityLabel.text = "\(quantity) \(days[2])"
        }
    }
    
    func setTracker(_ model: Tracker) {
        titleLabel.text = model.title
        colorView.backgroundColor = model.color
        quantityButton.backgroundColor = model.color
        emodjiLabel.text = model.emodji
    }
    
    func setQuantity(_ sender: Int) {
        quantity = sender
        addQuantityLabelText()
    }
}
