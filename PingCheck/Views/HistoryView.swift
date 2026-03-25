import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: PingViewModel
    @State private var showExportDialog = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            HStack {
                Text("\(viewModel.historyService.history.count) records")
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: {
                    showExportDialog = true
                }) {
                    Label("Export CSV", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.historyService.history.isEmpty)

                Button(action: {
                    viewModel.clearHistory()
                }) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.historyService.history.isEmpty)
            }

            if viewModel.historyService.history.isEmpty {
                VStack {
                    Spacer()
                    Text("No history available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(viewModel.historyService.history.reversed()) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.targetHost)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Text(item.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                +
                                Text(" ")
                                +
                                Text(item.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(String(format: "%.0f ms", item.latency))
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(colorForLatency(item.latency))
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .fileExporter(
            isPresented: $showExportDialog,
            document: CSVDocument(csv: viewModel.historyService.exportToCSV()),
            contentType: .commaSeparatedText,
            defaultFilename: "PingCheck-History-\(dateString()).csv"
        ) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
        }
    }

    private func colorForLatency(_ latency: Double) -> Color {
        if latency < 50 { return .green }
        if latency < 150 { return .yellow }
        return .red
    }

    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }

    var csv: String

    init(csv: String) {
        self.csv = csv
    }

    init(configuration: ReadConfiguration) throws {
        csv = ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = csv.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
