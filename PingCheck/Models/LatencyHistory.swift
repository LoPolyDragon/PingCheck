import Foundation

struct LatencyHistory: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let latency: Double
    let targetHost: String

    init(id: UUID = UUID(), timestamp: Date = Date(), latency: Double, targetHost: String) {
        self.id = id
        self.timestamp = timestamp
        self.latency = latency
        self.targetHost = targetHost
    }
}

struct TracerouteHop: Identifiable {
    let id: UUID
    let hopNumber: Int
    let host: String
    let latency: Double?
    let ipAddress: String?

    init(id: UUID = UUID(), hopNumber: Int, host: String, latency: Double?, ipAddress: String? = nil) {
        self.id = id
        self.hopNumber = hopNumber
        self.host = host
        self.latency = latency
        self.ipAddress = ipAddress
    }

    var displayLatency: String {
        guard let latency = latency else { return "* * *" }
        return String(format: "%.0f ms", latency)
    }
}

enum TimeRange: String, CaseIterable {
    case oneHour = "1h"
    case sixHours = "6h"
    case twentyFourHours = "24h"

    var duration: TimeInterval {
        switch self {
        case .oneHour: return 3600
        case .sixHours: return 21600
        case .twentyFourHours: return 86400
        }
    }

    var displayName: String {
        switch self {
        case .oneHour: return "Last 1 Hour"
        case .sixHours: return "Last 6 Hours"
        case .twentyFourHours: return "Last 24 Hours"
        }
    }
}
