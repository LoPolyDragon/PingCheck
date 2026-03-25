import Foundation

class HistoryService: ObservableObject {
    @Published var history: [LatencyHistory] = []

    private let maxHistoryItems = 10000
    private let userDefaultsKey = "PingCheckHistory"

    init() {
        loadHistory()
    }

    func addResult(_ result: PingResult) {
        guard let latency = result.latency, result.success else { return }

        let historyItem = LatencyHistory(
            timestamp: result.timestamp,
            latency: latency,
            targetHost: result.targetHost
        )

        history.append(historyItem)

        if history.count > maxHistoryItems {
            history.removeFirst(history.count - maxHistoryItems)
        }

        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    func getHistory(for timeRange: TimeRange) -> [LatencyHistory] {
        let cutoffDate = Date().addingTimeInterval(-timeRange.duration)
        return history.filter { $0.timestamp >= cutoffDate }
    }

    func getHistory(for host: String, timeRange: TimeRange) -> [LatencyHistory] {
        let cutoffDate = Date().addingTimeInterval(-timeRange.duration)
        return history.filter { $0.targetHost == host && $0.timestamp >= cutoffDate }
    }

    func exportToCSV() -> String {
        var csv = "Timestamp,Host,Latency (ms)\n"

        for item in history {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let timestamp = dateFormatter.string(from: item.timestamp)
            csv += "\(timestamp),\(item.targetHost),\(String(format: "%.2f", item.latency))\n"
        }

        return csv
    }

    func saveCSV(to url: URL) throws {
        let csv = exportToCSV()
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }

    func getPacketLossPercentage(for host: String?, timeRange: TimeRange) -> Double {
        let cutoffDate = Date().addingTimeInterval(-timeRange.duration)

        let recentHistory: [LatencyHistory]
        if let host = host {
            recentHistory = history.filter { $0.targetHost == host && $0.timestamp >= cutoffDate }
        } else {
            recentHistory = history.filter { $0.timestamp >= cutoffDate }
        }

        guard !recentHistory.isEmpty else { return 0.0 }

        return 0.0
    }

    private func saveHistory() {
        Task {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(history)
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            } catch {
                print("Failed to save history: \(error.localizedDescription)")
            }
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }

        do {
            let decoder = JSONDecoder()
            history = try decoder.decode([LatencyHistory].self, from: data)
        } catch {
            print("Failed to load history: \(error.localizedDescription)")
            history = []
        }
    }
}
