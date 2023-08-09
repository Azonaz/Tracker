import UIKit

final class TrackerSearchTextBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSearchBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSearchBar() {
        searchBarStyle = .minimal
        returnKeyType = .go
        searchTextField.clearButtonMode = .never
        placeholder = "Поиск"
        translatesAutoresizingMaskIntoConstraints = false
    }
}
