import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: PingViewModel
    @State private var showAddTarget = false
    @State private var newTargetName = ""
    @State private var newTargetHost = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Form {
                Section("Ping Settings") {
                    HStack {
                        Text("Interval:")
                        Spacer()
                        TextField("", value: $viewModel.settingsManager.pingInterval, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                        Text("seconds")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Alerts") {
                    Toggle("Enable Alerts", isOn: $viewModel.alertManager.alertsEnabled)

                    HStack {
                        Text("Threshold:")
                        Spacer()
                        TextField("", value: $viewModel.alertManager.alertThreshold, format: .number)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                        Text("ms")
                            .foregroundColor(.secondary)
                    }
                }

                Section("System") {
                    Toggle("Start at Login", isOn: $viewModel.settingsManager.startAtLogin)
                }

                Section {
                    HStack {
                        Text("Targets")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            showAddTarget = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(.bordered)
                    }

                    ForEach(viewModel.settingsManager.targets) { target in
                        TargetRow(target: target, viewModel: viewModel)
                    }
                }
            }
            .formStyle(.grouped)

            Spacer()

            VStack(spacing: 4) {
                Text("PingCheck v1.0.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("© 2026 LopoDragon")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
        }
        .padding()
        .sheet(isPresented: $showAddTarget) {
            AddTargetSheet(
                isPresented: $showAddTarget,
                viewModel: viewModel,
                targetName: $newTargetName,
                targetHost: $newTargetHost
            )
        }
        .onChange(of: viewModel.settingsManager.pingInterval) { _ in
            viewModel.settingsManager.saveSettings()
        }
        .onChange(of: viewModel.alertManager.alertsEnabled) { _ in
            viewModel.alertManager.saveSettings()
        }
        .onChange(of: viewModel.alertManager.alertThreshold) { _ in
            viewModel.alertManager.saveSettings()
        }
    }
}

struct TargetRow: View {
    let target: PingTarget
    @ObservedObject var viewModel: PingViewModel

    var body: some View {
        HStack {
            Toggle("", isOn: Binding(
                get: { target.isEnabled },
                set: { newValue in
                    var updatedTarget = target
                    updatedTarget.isEnabled = newValue
                    viewModel.settingsManager.updateTarget(updatedTarget)
                }
            ))
            .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(target.name)
                    .font(.body)
                Text(target.host)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                viewModel.settingsManager.removeTarget(target)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

struct AddTargetSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: PingViewModel
    @Binding var targetName: String
    @Binding var targetHost: String

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Ping Target")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name:")
                TextField("e.g., Google DNS", text: $targetName)
                    .textFieldStyle(.roundedBorder)

                Text("Host:")
                TextField("e.g., 8.8.8.8 or google.com", text: $targetHost)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                    targetName = ""
                    targetHost = ""
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Add") {
                    viewModel.settingsManager.addTarget(name: targetName, host: targetHost)
                    isPresented = false
                    targetName = ""
                    targetHost = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(targetName.isEmpty || targetHost.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 350)
    }
}
