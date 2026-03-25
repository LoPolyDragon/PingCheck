import SwiftUI

struct TracerouteView: View {
    @ObservedObject var viewModel: PingViewModel
    @State private var selectedHost: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Traceroute")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            HStack {
                Picker("Target", selection: $selectedHost) {
                    Text("Select target...").tag("")
                    ForEach(viewModel.settingsManager.targets) { target in
                        Text(target.name).tag(target.host)
                    }
                }
                .frame(maxWidth: .infinity)

                Button(action: {
                    if !selectedHost.isEmpty {
                        viewModel.performTraceroute(to: selectedHost)
                    }
                }) {
                    if viewModel.isTracerouteRunning {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text("Run")
                }
                .disabled(selectedHost.isEmpty || viewModel.isTracerouteRunning)
                .buttonStyle(.borderedProminent)
            }

            if viewModel.isTracerouteRunning {
                VStack {
                    ProgressView("Running traceroute...")
                        .padding()
                }
                .frame(maxWidth: .infinity)
            } else if viewModel.tracerouteHops.isEmpty {
                VStack {
                    Spacer()
                    Text("Select a target and run traceroute")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.tracerouteHops) { hop in
                            HopRow(hop: hop)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if selectedHost.isEmpty, let firstTarget = viewModel.settingsManager.targets.first {
                selectedHost = firstTarget.host
            }
        }
    }
}

struct HopRow: View {
    let hop: TracerouteHop

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(hop.hopNumber)")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(hop.host)
                    .font(.body)
                    .fontWeight(.medium)

                if let ip = hop.ipAddress {
                    Text(ip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(hop.displayLatency)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(hop.latency != nil ? .primary : .secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(6)
    }
}
