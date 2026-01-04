import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "775a36da-b7fe-491e-8b2d-fd16221351e9") else {
            print("ANALYTICS ERROR: Failed to create AppMetrica configuration")
            return
        }
        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params: [String: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("ANALYTICS ERROR: \(error.localizedDescription)")
        })

        print("ANALYTICS EVENT: \(event)")
        print("ANALYTICS PARAMS: \(params)")
    }
}

// MARK: - Event Types
extension AnalyticsService {
    enum EventType: String {
        case open
        case close
        case click
    }

    enum Screen: String {
        case main = "Main"
    }

    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
}

// MARK: - Convenience Methods
extension AnalyticsService {
    func reportScreenOpen(_ screen: Screen) {
        let params: [String: Any] = [
            "event": EventType.open.rawValue,
            "screen": screen.rawValue
        ]
        report(event: EventType.open.rawValue, params: params)
    }

    func reportScreenClose(_ screen: Screen) {
        let params: [String: Any] = [
            "event": EventType.close.rawValue,
            "screen": screen.rawValue
        ]
        report(event: EventType.close.rawValue, params: params)
    }

    func reportClick(screen: Screen, item: Item) {
        let params: [String: Any] = [
            "event": EventType.click.rawValue,
            "screen": screen.rawValue,
            "item": item.rawValue
        ]
        report(event: EventType.click.rawValue, params: params)
    }
}
