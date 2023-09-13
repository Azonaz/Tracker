import UIKit

final class NewTrackerEmodjiCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "newTrackerEmodjiCollectionCell"

    private lazy var emodjiLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
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

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            emodjiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emodjiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emodjiLabel.heightAnchor.constraint(equalToConstant: 52),
            emodjiLabel.widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func createView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(emodjiLabel)
        activateConstraints()
    }

    func addEmodji(_ model: String) {
        emodjiLabel.text = model
    }
}
