import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController!
    private var viewModel: PingViewModel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel = PingViewModel()
        menuBarController = MenuBarController()
        menuBarController.setupMenuBar(viewModel: viewModel)

        NSApp.setActivationPolicy(.accessory)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.menuBarController.updateMenuBarDisplay()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        viewModel.stopPinging()
    }
}
