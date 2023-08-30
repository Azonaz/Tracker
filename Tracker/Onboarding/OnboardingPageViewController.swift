import UIKit

final class OnboardingPageViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = {
        return [firstPage, secondPage]
    }()

    private lazy var firstPage: UIViewController = {
        let controller = UIViewController()
        let pageImage = UIImageView(frame: view.bounds)
        pageImage.image = .onboarding1
        pageImage.center = view.center
        pageImage.contentMode = .scaleAspectFill
        pageImage.clipsToBounds = true
        controller.view.addSubview(pageImage)
        controller.view.addSubview(firstLabel)
        controller.view.sendSubviewToBack(pageImage)
        return controller
    }()

    private lazy var secondPage: UIViewController = {
        let controller = UIViewController()
        let pageImage = UIImageView(frame: view.bounds)
        pageImage.image = .onboarding2
        pageImage.center = view.center
        pageImage.contentMode = .scaleAspectFill
        pageImage.clipsToBounds = true
        controller.view.addSubview(pageImage)
        controller.view.addSubview(secondLabel)
        controller.view.sendSubviewToBack(pageImage)
        return controller
    }()

    private lazy var firstLabel: UILabel = {
        let label = UILabel()
        label.text = "Отслеживайте только то, что хотите"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var secondLabel: UILabel = {
        let label = UILabel()
        label.text = "Даже если это не литры воды и йога"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var onButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(tapOnButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        dataSource = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        createView()
    }

    private func createView() {
        view.addSubview(pageControl)
        view.addSubview(onButton)
        activateConstrants()
    }

    private func activateConstrants() {
        NSLayoutConstraint.activate([
            firstLabel.leadingAnchor.constraint(equalTo: firstPage.view.leadingAnchor, constant: 16),
            firstLabel.trailingAnchor.constraint(equalTo: firstPage.view.trailingAnchor, constant: -16),
            firstLabel.bottomAnchor.constraint(equalTo: firstPage.view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -280),
            secondLabel.leadingAnchor.constraint(equalTo: secondPage.view.leadingAnchor, constant: 16),
            secondLabel.trailingAnchor.constraint(equalTo: secondPage.view.trailingAnchor, constant: -16),
            secondLabel.bottomAnchor.constraint(equalTo: secondPage.view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -280),
            onButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onButton.heightAnchor.constraint(equalToConstant: 60),
            pageControl.bottomAnchor.constraint(equalTo: onButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    @objc
    private func tapOnButton() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid config")
        }
        UserDefaults.standard.set(true, forKey: "shownOnboardingEarlier")
        window.rootViewController = TabBarController()
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
}
