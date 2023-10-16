import UIKit

final class StatisticCardView: UIView {

    let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setGradientBorder()
    }

    private func createView() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.cornerRadius = 16
        [resultLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        activateConstraints()
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }

    private func setGradientBorder() {
        let gradient = createGradientImage(bounds: bounds, colors: [.gradientRed, .gradientGreen, .gradientBlue])
        layer.borderColor = UIColor(patternImage: gradient).cgColor
    }

    private func createGradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.colors = colors.map(\.cgColor)
        return UIGraphicsImageRenderer(bounds: bounds).image { rendererContext in
            let context = rendererContext.cgContext
            gradient.render(in: context)
        }
    }
}
