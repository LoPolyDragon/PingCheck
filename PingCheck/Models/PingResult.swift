import Foundation

struct PingResult: Identifiable, Codable {
    let id: UUID
    let targetHost: String
    let timestamp: Date
    let latency: Double?
    let success: Bool
    let errorMessage: String?

    init(id: UUID = UUID(), targetHost: String, timestamp: Date = Date(), latency: Double?, success: Bool, errorMessage: String? = nil) {
        self.id = id
        self.targetHost = targetHost
        self.timestamp = timestamp
        self.latency = latency
        self.success = success
        self.errorMessage = errorMessage
    }

    var displayLatency: String {
        guard let latency = latency else { return "—" }
        return String(format: "%.0f ms", latency)
    }

    var colorStatus: ColorStatus {
        guard let latency = latency else { return .red }
        if latency < 50 { return .green }
        if latency < 150 { return .yellow }
        return .red
    }
}

enum ColorStatus {
    case green
    case yellow
    case red
}
