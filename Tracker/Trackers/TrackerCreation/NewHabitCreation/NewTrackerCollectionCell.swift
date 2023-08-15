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

    private lazy var emodjiRectangleView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var colorRectangleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.alpha = 0.3
        view.isHidden = true
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
            emodjiRectangleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emodjiRectangleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emodjiRectangleView.heightAnchor.constraint(equalToConstant: 52),
            emodjiRectangleView.widthAnchor.constraint(equalToConstant: 52),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorRectangleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorRectangleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorRectangleView.heightAnchor.constraint(equalToConstant: 52),
            colorRectangleView.widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func createView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emodjiRectangleView)
        contentView.addSubview(emodjiLabel)
        contentView.addSubview(colorRectangleView)
        contentView.addSubview(colorView)
        activateConstraints()
    }

    func addEmodji(_ model: String) {
        emodjiLabel.text = model
    }

    func addColor(_ model: UIColor) {
        colorView.backgroundColor = model
        colorRectangleView.layer.borderColor = model.cgColor
    }
}
