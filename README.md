# PingCheck

A professional network latency monitoring app for macOS 14+.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

PingCheck is a powerful yet elegant network latency monitor that lives in your menu bar. Monitor your network connection in real-time with color-coded latency indicators, detailed graphs, and comprehensive history logging.

## Features

- **Menu Bar Integration**: Real-time latency display with color-coded status (green/yellow/red)
- **Configurable Targets**: Monitor multiple hosts simultaneously
  - Default targets: Google DNS (8.8.8.8), Cloudflare DNS (1.1.1.1)
  - Add custom targets (IP addresses or domain names)
- **Real-Time Graphs**: Visualize latency trends over time
  - Time ranges: 1 hour, 6 hours, 24 hours
  - Multi-target comparison
- **Packet Loss Monitoring**: Track connection reliability
- **Traceroute**: Visual hop-by-hop route analysis
- **History Logging**: Comprehensive logging with CSV export
- **Smart Alerts**: Customizable latency threshold notifications
- **Native macOS Experience**:
  - Full Dark Mode support
  - Start at login option
  - Native SwiftUI interface

## System Requirements

- macOS 14.0 or later
- Network connectivity

## Installation

1. Download the latest release from the App Store
2. Launch PingCheck
3. Grant network permissions if prompted
4. The app will appear in your menu bar

## Usage

### Dashboard

The main dashboard displays:
- Current average latency with color-coded indicator
- Packet loss percentage
- Individual target status
- Start/Stop controls

### Graphs

View latency trends over configurable time periods:
- Select time range (1h, 6h, 24h)
- Multi-target comparison
- Average latency and data point statistics

### Traceroute

Analyze network paths:
1. Select a target from the dropdown
2. Click "Run" to perform traceroute
3. View hop-by-hop latency details

### History

Access comprehensive ping history:
- View all recorded pings with timestamps
- Export data to CSV for analysis
- Clear history when needed

### Settings

Customize PingCheck to your needs:
- **Ping Settings**: Adjust ping interval (default: 1 second)
- **Alerts**: Enable/disable alerts and set latency threshold
- **System**: Configure start at login
- **Targets**: Add, enable/disable, or remove ping targets

## Color Coding

- **Green**: Latency < 50ms (Excellent)
- **Yellow**: Latency 50-150ms (Good)
- **Red**: Latency > 150ms or connection failed (Poor)

## Architecture

PingCheck is built with modern macOS development best practices:

- **SwiftUI**: Native declarative UI framework
- **AppKit**: Menu bar integration
- **MVVM Architecture**: Clean separation of concerns
- **Network Framework**: Native ICMP ping implementation
- **No External Dependencies**: Pure Swift implementation

### Project Structure

```
PingCheck/
├── Models/
│   ├── PingTarget.swift
│   ├── PingResult.swift
│   └── LatencyHistory.swift
├── ViewModels/
│   └── PingViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── LatencyGraphView.swift
│   ├── TracerouteView.swift
│   ├── HistoryView.swift
│   └── SettingsView.swift
├── Services/
│   ├── PingService.swift
│   ├── TracerouteService.swift
│   └── HistoryService.swift
├── Managers/
│   ├── AlertManager.swift
│   └── SettingsManager.swift
└── MenuBar/
    └── MenuBarController.swift
```

## Building from Source

1. Clone the repository:
```bash
git clone https://github.com/lopodragon/pingcheck.git
cd pingcheck
```

2. Open in Xcode:
```bash
open PingCheck.xcodeproj
```

3. Build and run (⌘R)

## Privacy & Security

PingCheck respects your privacy:
- No data collection or analytics
- No third-party services
- All data stored locally
- Network access only for ping/traceroute operations
- App Sandbox enabled for security

## Support

For issues, feature requests, or questions:
- GitHub Issues: [github.com/lopodragon/pingcheck/issues](https://github.com/lopodragon/pingcheck/issues)
- Email: support@lopodragon.com

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Developed by LopoDragon

Copyright © 2026 LopoDragon. All rights reserved.

## Acknowledgments

- Built with SwiftUI and AppKit
- Network monitoring powered by Apple's Network framework
- Icon design inspired by network topology

---

**Available on the Mac App Store for $4.99**
