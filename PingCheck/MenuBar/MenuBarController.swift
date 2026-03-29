import AppKit
import SwiftUI

@MainActor
class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var viewModel: PingViewModel!

    func setupMenuBar(viewModel: PingViewModel) {
        self.viewModel = viewModel

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateStatusButton(latency: nil, status: .red)
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(viewModel: viewModel))

        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenuBar),
            name: NSNotification.Name("UpdateMenuBar"),
            object: nil
        )
    }

    @objc private func updateMenuBar() {
        updateStatusButton(latency: viewModel.averageLatency, status: viewModel.latencyColor)
    }

    private func updateStatusButton(latency: Double?, status: ColorStatus) {
        guard let button = statusItem.button else { return }

        let text: String
        if let latency = latency {
            text = String(format: "%.0f ms", latency)
        } else {
            text = "—"
        }

        let color: NSColor
        switch status {
        case .green:
            color = .systemGreen
        case .yellow:
            color = .systemYellow
        case .red:
            color = .systemRed
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        ]

        button.attributedTitle = NSAttributedString(string: text, attributes: attributes)
    }

    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    func updateMenuBarDisplay() {
        updateStatusButton(latency: viewModel.averageLatency, status: viewModel.latencyColor)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
