import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testLighViewController() {
        let viewController = TrackersViewController()
        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testDarkViewController() {
        let viewController = TrackersViewController()
        assertSnapshot(matching: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
