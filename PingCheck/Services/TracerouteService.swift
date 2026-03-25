import Foundation

class TracerouteService {
    func performTraceroute(to host: String, maxHops: Int = 30) async -> [TracerouteHop] {
        var hops: [TracerouteHop] = []

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/traceroute")
        task.arguments = ["-m", "\(maxHops)", "-q", "1", "-w", "2", host]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                hops = parseTracerouteOutput(output)
            }
        } catch {
            print("Traceroute error: \(error.localizedDescription)")
        }

        return hops
    }

    private func parseTracerouteOutput(_ output: String) -> [TracerouteHop] {
        var hops: [TracerouteHop] = []
        let lines = output.components(separatedBy: .newlines)

        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty { continue }

            let components = line.trimmingCharacters(in: .whitespaces).components(separatedBy: .whitespaces)
            guard components.count > 0 else { continue }

            if let hopNumber = Int(components[0]) {
                var hostname = "* * *"
                var ipAddress: String?
                var latency: Double?

                if components.count > 1 {
                    if components[1] == "*" {
                        hostname = "* * *"
                    } else {
                        hostname = components[1]

                        if components.count > 2 {
                            let ipComponent = components[2]
                            if ipComponent.hasPrefix("(") && ipComponent.hasSuffix(")") {
                                ipAddress = String(ipComponent.dropFirst().dropLast())
                            }
                        }

                        for component in components {
                            if component == "ms" {
                                if let index = components.firstIndex(of: component), index > 0 {
                                    latency = Double(components[index - 1])
                                }
                                break
                            }
                        }
                    }
                }

                let hop = TracerouteHop(
                    hopNumber: hopNumber,
                    host: hostname,
                    latency: latency,
                    ipAddress: ipAddress
                )
                hops.append(hop)
            }
        }

        return hops
    }
}
