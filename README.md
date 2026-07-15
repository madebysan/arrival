<p><img src="assets/app-icon.png" width="128" height="128" alt="Arrival app icon"></p>

<h1>Arrival for macOS</h1>

<p>Real-time NYC subway arrivals in your menu bar.<br>
Never miss your train.</p>

<p><strong>Version 1.0.1</strong> · macOS 13+ · Apple Silicon & Intel</p>

<p>
  <img src="https://img.shields.io/badge/Swift-f05138" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-0066cc" alt="SwiftUI">
  <img src="https://img.shields.io/badge/macOS-000000" alt="macOS">
  <img src="https://img.shields.io/badge/MenuBarExtra-0066cc" alt="MenuBarExtra">
</p>

<p><a href="https://github.com/madebysan/arrival/releases/latest">Download Arrival</a></p>

<p>Also available for <a href="https://github.com/madebysan/arrival-ios">iOS</a></p>

![Arrival app showing line picker, direction picker, station picker, and live arrivals](assets/screenshot-v2.png)

I commute the same route every day. The only thing I actually need is when is the next train at my stop, on my line, going my direction. Colored subway bullet in the menu bar. Click it, see the next trains. Close it, back to work.

![Arrival for iOS showing live subway arrivals and home screen widgets](https://github.com/madebysan/arrival-ios/raw/main/assets/screenshot.png)

## How it works

Arrival sits in the menu bar as a colored subway bullet. Choose a line, direction, and station once. From then on, clicking the icon shows live countdowns, service alerts, and which trains you can still catch based on your walking time.

Every subway line and roughly 496 stations are included. Data comes directly from the MTA's free [GTFS-Realtime feeds](https://api.mta.info/), the same source used by the countdown clocks in stations. Arrival fetches only when you open it, so it does not poll in the background.

## Install

1. Download `Arrival.dmg` from the [latest release](https://github.com/madebysan/arrival/releases/latest)
2. Open the DMG and drag Arrival to Applications
3. Launch from Applications (right-click → Open on first launch if needed)

The menu bar icon opens settings on first launch. Pick your subway line, direction, station, and optional walking time.

### Build from source

```bash
git clone https://github.com/madebysan/arrival.git
cd arrival
swift build -c release
# Binary at .build/release/Arrival
```

## Known issues

- **v1.0.1 DMG launch crash on some machines.** Likely a bundle-ID resource path issue from the `SubwayBar → Arrival` rename (`Arrival_Arrival.bundle`). The build-from-source instructions above work reliably. A fixed DMG is a rebuild away but isn't currently scheduled.

## Tech stack

- Swift 6 + SwiftUI (`MenuBarExtra`)
- Apple `swift-protobuf` for GTFS-RT parsing
- MTA GTFS-Realtime feeds (free, no API key)
- Swift Package Manager

## License

[MIT](LICENSE)

Made by [santiagoalonso.com](https://santiagoalonso.com)
