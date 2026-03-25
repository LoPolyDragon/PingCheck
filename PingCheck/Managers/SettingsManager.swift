import Foundation
import ServiceManagement

class SettingsManager: ObservableObject {
    @Published var pingInterval: Double = 1.0
    @Published var startAtLogin: Bool = false {
        didSet {
            updateLoginItem()
        }
    }
    @Published var targets: [PingTarget] = PingTarget.defaultTargets

    private let targetsKey = "PingTargets"
    private let pingIntervalKey = "PingInterval"
    private let startAtLoginKey = "StartAtLogin"

    init() {
        loadSettings()
    }

    func addTarget(name: String, host: String) {
        let target = PingTarget(name: name, host: host)
        targets.append(target)
        saveSettings()
    }

    func removeTarget(_ target: PingTarget) {
        targets.removeAll { $0.id == target.id }
        saveSettings()
    }

    func updateTarget(_ target: PingTarget) {
        if let index = targets.firstIndex(where: { $0.id == target.id }) {
            targets[index] = target
            saveSettings()
        }
    }

    func saveSettings() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(targets)
            UserDefaults.standard.set(data, forKey: targetsKey)
        } catch {
            print("Failed to save targets: \(error.localizedDescription)")
        }

        UserDefaults.standard.set(pingInterval, forKey: pingIntervalKey)
        UserDefaults.standard.set(startAtLogin, forKey: startAtLoginKey)
    }

    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: targetsKey) {
            do {
                let decoder = JSONDecoder()
                targets = try decoder.decode([PingTarget].self, from: data)
            } catch {
                print("Failed to load targets: \(error.localizedDescription)")
                targets = PingTarget.defaultTargets
            }
        }

        if UserDefaults.standard.object(forKey: pingIntervalKey) != nil {
            pingInterval = UserDefaults.standard.double(forKey: pingIntervalKey)
        }

        if UserDefaults.standard.object(forKey: startAtLoginKey) != nil {
            startAtLogin = UserDefaults.standard.bool(forKey: startAtLoginKey)
        }
    }

    private func updateLoginItem() {
        if #available(macOS 13.0, *) {
            do {
                if startAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update login item: \(error.localizedDescription)")
            }
        }
    }
}
