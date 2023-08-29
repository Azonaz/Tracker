import UIKit

final class NewTrackerColorCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "newTrackerColorCollectionCell"

    private lazy var colorView: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
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
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func createView() {
        contentView.backgroundColor = .clear
        contentView.addSubview(colorView)
        activateConstraints()
    }

    func addColor(_ model: UIColor) {
        colorView.backgroundColor = model
    }
}
