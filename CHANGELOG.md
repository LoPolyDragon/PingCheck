# Changelog

All notable changes to PingCheck will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-25

### Added
- Initial release of PingCheck
- Real-time network latency monitoring in menu bar
- Color-coded latency indicators (green/yellow/red)
- Configurable ping targets with default Google DNS (8.8.8.8) and Cloudflare DNS (1.1.1.1)
- Custom target support for any IP address or domain name
- Real-time latency graphs with 1h, 6h, and 24h time ranges
- Packet loss percentage tracking
- Built-in traceroute functionality with visual hop display
- Comprehensive history logging with timestamps
- CSV export functionality for history data
- Smart alert system with configurable latency thresholds
- Notification cooldown to prevent alert spam (5 minutes)
- Full Dark Mode support
- Start at login option using SMAppService
- Native SwiftUI interface with AppKit menu bar integration
- MVVM architecture for clean code organization
- Network framework-based ICMP ping implementation
- No external dependencies
- App Sandbox security
- Professional dashboard with average latency display
- Multi-target simultaneous monitoring
- Target enable/disable toggles
- Configurable ping intervals
- Tab-based navigation (Dashboard, Graph, Traceroute, History, Settings)

### Features Detail
- **Menu Bar**: Real-time latency display with color coding
- **Dashboard**: Overview of all targets with current status
- **Graph View**: Charts library integration for visualizing latency trends
- **Traceroute**: Integration with system traceroute utility
- **History**: Persistent storage with UserDefaults, up to 10,000 records
- **Settings**: Complete configuration management
- **Alerts**: UserNotifications framework integration

### Technical
- Built with Swift 5.0
- SwiftUI for UI
- AppKit for menu bar
- Network framework for networking
- Minimum macOS 14.0 deployment target
- Bundle ID: com.lopodragon.pingcheck
- Version: 1.0.0
- Build: 1

---

## [Unreleased]

### Planned Features
- iCloud sync for settings and history
- Multiple alert profiles
- Network interface selection
- Bandwidth monitoring
- Connection quality score
- Widget support
- Historical trends analysis
- Network outage detection
- Custom notification sounds
- Accessibility improvements
