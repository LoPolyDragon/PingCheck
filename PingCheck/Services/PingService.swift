import Foundation
import Network

class PingService: ObservableObject {
    private var pingTasks: [String: Task<Void, Never>] = [:]

    func ping(host: String, timeout: TimeInterval = 2.0) async -> PingResult {
        let startTime = Date()

        do {
            let address = try await resolveHost(host)
            let latency = await measureICMPLatency(to: address, timeout: timeout)

            if let latency = latency {
                return PingResult(
                    targetHost: host,
                    timestamp: startTime,
                    latency: latency * 1000,
                    success: true
                )
            } else {
                return PingResult(
                    targetHost: host,
                    timestamp: startTime,
                    latency: nil,
                    success: false,
                    errorMessage: "Request timed out"
                )
            }
        } catch {
            return PingResult(
                targetHost: host,
                timestamp: startTime,
                latency: nil,
                success: false,
                errorMessage: error.localizedDescription
            )
        }
    }

    private func resolveHost(_ host: String) async throws -> String {
        if isIPAddress(host) {
            return host
        }

        return try await withCheckedThrowingContinuation { continuation in
            let host = NWEndpoint.Host(host)
            let parameters = NWParameters()
            let connection = NWConnection(host: host, port: .https, using: parameters)

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if let endpoint = connection.currentPath?.remoteEndpoint,
                       case .hostPort(let host, _) = endpoint {
                        continuation.resume(returning: "\(host)")
                    } else {
                        continuation.resume(throwing: NSError(domain: "PingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to resolve host"]))
                    }
                    connection.cancel()
                case .failed(let error):
                    continuation.resume(throwing: error)
                    connection.cancel()
                default:
                    break
                }
            }

            connection.start(queue: .global())
        }
    }

    private func measureICMPLatency(to host: String, timeout: TimeInterval) async -> TimeInterval? {
        let startTime = Date()

        return await withCheckedContinuation { continuation in
            let host = NWEndpoint.Host(host)
            let port = NWEndpoint.Port(rawValue: 0)!
            let parameters = NWParameters.udp
            parameters.allowLocalEndpointReuse = true

            let connection = NWConnection(host: host, port: port, using: parameters)
            var hasReturned = false

            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if !hasReturned {
                    hasReturned = true
                    connection.cancel()
                    continuation.resume(returning: nil)
                }
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if !hasReturned {
                        hasReturned = true
                        timeoutTask.cancel()
                        let latency = Date().timeIntervalSince(startTime)
                        connection.cancel()
                        continuation.resume(returning: latency)
                    }
                case .failed:
                    if !hasReturned {
                        hasReturned = true
                        timeoutTask.cancel()
                        connection.cancel()
                        continuation.resume(returning: nil)
                    }
                default:
                    break
                }
            }

            connection.start(queue: .global())
        }
    }

    private func isIPAddress(_ string: String) -> Bool {
        let parts = string.split(separator: ".")
        guard parts.count == 4 else { return false }
        return parts.allSatisfy { part in
            if let number = Int(part), number >= 0, number <= 255 {
                return true
            }
            return false
        }
    }

    func startContinuousPing(host: String, interval: TimeInterval = 1.0, callback: @escaping (PingResult) -> Void) {
        stopPing(host: host)

        let task = Task {
            while !Task.isCancelled {
                let result = await ping(host: host)
                callback(result)

                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }

        pingTasks[host] = task
    }

    func stopPing(host: String) {
        pingTasks[host]?.cancel()
        pingTasks.removeValue(forKey: host)
    }

    func stopAllPings() {
        pingTasks.values.forEach { $0.cancel() }
        pingTasks.removeAll()
    }
}
