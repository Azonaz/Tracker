import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBarController()
    }

    func addTabBarController() {
        tabBar.backgroundColor = .ypWhite
        tabBar.barTintColor = .ypBlue
        let borderLine = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: 1))
        borderLine.backgroundColor = .ypLightGray
        tabBar.addSubview(borderLine)
        let trackerViewController = TrackersViewController()
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        trackerNavigationController.tabBarItem = UITabBarItem(title: "Трекеры",
                                                              image: .tabTracker,
                                                              tag: 0)
        let staticticViewController = StatisticViewController()
        let statisticNavigationController = UINavigationController(rootViewController: staticticViewController)
        statisticNavigationController.tabBarItem = UITabBarItem(title: "Статистика",
                                                                image: .tabStatistic,
                                                                tag: 1)
        self.viewControllers = [trackerNavigationController, statisticNavigationController]
    }
}
