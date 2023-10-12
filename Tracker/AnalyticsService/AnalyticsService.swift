import Foundation
import YandexMobileMetrica

enum Event: String {
    case open
    case close
    case click
}

enum Item: String {
    // swiftlint:disable:next identifier_name
    case add_track
    case track
    case filter
    case edit
    case delete
}

class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: apiKeyYM) else {
            return
        }
        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: Event, parameters: [AnyHashable: Any]) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
