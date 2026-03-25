import Foundation
import UserNotifications

class AlertManager: ObservableObject {
    @Published var alertThreshold: Double = 200.0
    @Published var alertsEnabled: Bool = true

    private var lastAlertTime: Date?
    private let alertCooldown: TimeInterval = 300

    init() {
        loadSettings()
        requestNotificationPermission()
    }

    func checkLatency(_ result: PingResult) {
        guard alertsEnabled else { return }
        guard let latency = result.latency else { return }

        if latency >= alertThreshold {
            sendAlert(for: result)
        }
    }

    private func sendAlert(for result: PingResult) {
        guard canSendAlert() else { return }

        let content = UNMutableNotificationContent()
        content.title = "High Latency Detected"
        content.body = "Ping to \(result.targetHost): \(result.displayLatency)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            }
        }

        lastAlertTime = Date()
    }

    private func canSendAlert() -> Bool {
        guard let lastAlert = lastAlertTime else { return true }
        return Date().timeIntervalSince(lastAlert) >= alertCooldown
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(alertThreshold, forKey: "AlertThreshold")
        UserDefaults.standard.set(alertsEnabled, forKey: "AlertsEnabled")
    }

    private func loadSettings() {
        if UserDefaults.standard.object(forKey: "AlertThreshold") != nil {
            alertThreshold = UserDefaults.standard.double(forKey: "AlertThreshold")
        }
        if UserDefaults.standard.object(forKey: "AlertsEnabled") != nil {
            alertsEnabled = UserDefaults.standard.bool(forKey: "AlertsEnabled")
        }
    }
}
