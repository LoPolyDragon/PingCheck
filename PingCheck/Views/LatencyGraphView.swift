import SwiftUI
import Charts

struct LatencyGraphView: View {
    @ObservedObject var viewModel: PingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Latency Graph")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.displayName).tag(range)
                }
            }
            .pickerStyle(.segmented)

            let history = viewModel.getHistoryForGraph()

            if history.isEmpty {
                VStack {
                    Spacer()
                    Text("No data available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                Chart {
                    ForEach(history) { item in
                        LineMark(
                            x: .value("Time", item.timestamp),
                            y: .value("Latency", item.latency)
                        )
                        .foregroundStyle(by: .value("Host", item.targetHost))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour().minute())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let latency = value.as(Double.self) {
                                Text("\(Int(latency)) ms")
                            }
                        }
                    }
                }
                .frame(height: 300)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average Latency")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let avg = calculateAverage(history: history) {
                            Text(String(format: "%.0f ms", avg))
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Text("—")
                                .font(.title3)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Data Points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(history.count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }

    private func calculateAverage(history: [LatencyHistory]) -> Double? {
        guard !history.isEmpty else { return nil }
        let sum = history.reduce(0.0) { $0 + $1.latency }
        return sum / Double(history.count)
    }
}
