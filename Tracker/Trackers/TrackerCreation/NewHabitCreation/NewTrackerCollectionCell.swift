import UIKit

final class NewTrackerCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "newTrackerCollectionCell"

    private lazy var emodjiLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var colorView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            emodjiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emodjiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emodjiLabel.heightAnchor.constraint(equalToConstant: 52),
            emodjiLabel.widthAnchor.constraint(equalToConstant: 52),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func createView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emodjiLabel)
        contentView.addSubview(colorView)
        activateConstraints()
    }

    func addEmodji(_ model: String) {
        emodjiLabel.text = model
    }

    func addColor(_ model: UIColor) {
        colorView.backgroundColor = model
    }
}
