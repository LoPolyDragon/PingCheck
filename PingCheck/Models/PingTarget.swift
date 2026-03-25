import Foundation

struct PingTarget: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var host: String
    var isEnabled: Bool

    init(id: UUID = UUID(), name: String, host: String, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.host = host
        self.isEnabled = isEnabled
    }

    static let defaultTargets: [PingTarget] = [
        PingTarget(name: "Google DNS", host: "8.8.8.8"),
        PingTarget(name: "Cloudflare DNS", host: "1.1.1.1")
    ]
}
