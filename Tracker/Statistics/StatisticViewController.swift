import UIKit

final class StatisticViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
    }
    
    private func createView() {
        view.backgroundColor = .ypWhite
        title = "Статистика"
        navigationController?.navigationBar.backgroundColor = .ypWhite
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
}
