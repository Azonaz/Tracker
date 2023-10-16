import UIKit

final class OnboardingPageViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingViewController(pageImageView: .onboarding1, text: firstPageOnboardingText)
        let secondPage = OnboardingViewController(pageImageView: .onboarding2, text: secondPageOnboardingText)
        return [firstPage, secondPage]
    }()

    private lazy var onButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .black
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitle(onboardingButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(tapOnButton), for: .touchUpInside)
        return button
    }()

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
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
        [pageControl, onButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0) }
        activateConstrants()
    }

    private func activateConstrants() {
        NSLayoutConstraint.activate([
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
