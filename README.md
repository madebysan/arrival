<p align="center">
  <img src="assets/app-icon.png" width="128" height="128" alt="Arrival app icon">
</p>
<h1 align="center">Arrival for iOS</h1>
<p align="center">Real-time NYC subway arrivals on your iPhone.<br>
Never miss your train.</p>
<p align="center"><strong>Version 1.0.0</strong> · iOS 17+</p>
<p align="center">Also available for <a href="https://github.com/madebysan/arrival"><strong>macOS</strong></a></p>

---

<p align="center">
  <img src="assets/screenshot.png" width="720" alt="Arrival iOS app showing live subway arrivals and home screen widgets">
</p>

---

I commute the same route every day. The only thing I actually need is when is the next train at my stop, on my line, going my direction. The home screen widget does most of the work. Glance at your phone, see the next three trains, walk out of your apartment if one is still catchable. When you need more detail, open the app for service alerts and longer countdowns.

## How it works

Save up to four stops (line, direction, station) and set your walking time. The app highlights which trains you can still catch and refreshes every 60 seconds while open. Widgets pull fresh data on the iOS refresh cadence.

To add a widget: long-press the home screen, tap **+**, search "Arrival". The small widget shows three upcoming arrivals. The medium shows three arrivals plus a "Leave now" badge. Long-press any widget and hit Edit to pick which saved stop it displays.

Data comes from the [MTA's free GTFS-Realtime feeds](https://api.mta.info/), the same source powering the countdown clocks in stations.

## Features

- **Every NYC subway line.** 1/2/3, 4/5/6, 7, A/C/E, B/D/F/M, G, J/Z, L, N/Q/R/W, S.
- **All ~496 stations.** Searchable picker, filtered by line.
- **Up to 4 saved stops.** Track multiple stations and directions.
- **Home screen widgets.** Small (3 arrivals) and medium (3 arrivals + leave-now badge).
- **Widget stop picker.** Each widget can show a different saved stop.
- **Auto-refresh.** Arrival data refreshes every 60 seconds while the app is open.
- **Walking time.** Set minutes per station. Trains you can still catch are highlighted.
- **Service alerts.** Live delay and planned-work notifications for your lines.
- **Native SwiftUI.** Follows system dark / light mode.

## Setup

1. Open Arrival and tap **Add Stop**
2. Pick your subway line → direction → station
3. Set your walking time (optional)
4. Add a home-screen widget: long-press home screen → "+" → search "Arrival"
5. Long-press the widget → Edit to pick which stop it displays

## Build from source

```bash
git clone https://github.com/madebysan/arrival-ios.git
cd arrival-ios
open ArrivaliOS.xcodeproj
```

Build and run with Xcode 16+ targeting iOS 17+. No binary is attached to releases because iOS apps can't be side-loaded from GitHub. Build in Xcode, or install via TestFlight separately.

## Tech stack

- Swift + SwiftUI
- WidgetKit + AppIntents (configurable home screen widgets)
- Apple `swift-protobuf` for GTFS-RT parsing
- MTA GTFS-Realtime feeds (free, no API key)
- Swift Package Manager

## Data source

All train-arrival data comes from the [MTA's GTFS-Realtime feeds](https://api.mta.info/). Free, no API key required. The app fetches data on-demand and refreshes every 60 seconds while visible.

## Related

- [Arrival for macOS](https://github.com/madebysan/arrival) (menu bar version)

## License

[MIT](LICENSE)

---

Made by [santiagoalonso.com](https://santiagoalonso.com)
