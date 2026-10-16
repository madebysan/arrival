<p><img src="ios/assets/app-icon.png" width="128" height="128" alt="Arrival app icon"></p>

<h1>Arrival</h1>

<p>Real-time NYC subway arrivals on your iPhone and in your Mac menu bar.<br>
A widget that shows which train you can still catch.</p>

<p><strong>iPhone 1.0</strong> · iOS 17+ · <strong>Mac 1.0.2</strong> · macOS 13+</p>

<p>
  <img src="https://img.shields.io/badge/Swift-f05138" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-0066cc" alt="SwiftUI">
  <img src="https://img.shields.io/badge/WidgetKit-0066cc" alt="WidgetKit">
  <img src="https://img.shields.io/badge/MenuBarExtra-0066cc" alt="MenuBarExtra">
</p>

<p>
  <a href="https://apps.apple.com/us/app/arrival-nyc-subway/id6759941751"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="50"></a>
</p>

<p><a href="https://github.com/madebysan/arrival/releases/latest">Download Arrival for Mac</a></p>

![Arrival for iOS showing live subway arrivals and home screen widgets](ios/assets/screenshot.png)

I commute the same route every day, and the only thing I need is when the next train comes to my stop, on my line, in my direction. Arrival answers that and nothing else.

- The widget counts in your walk, so it shows trains you can still make.
- The Mac menu bar shows the same countdown with a colored line bullet.
- Every line and about 496 stations, straight from the MTA's live feeds.

## Apps

**[Arrival for iOS](ios/)** saves up to four stops with walking times and puts the next catchable trains on your home screen. iOS 17 or later, on the [App Store](https://apps.apple.com/us/app/arrival-nyc-subway/id6759941751).

**[Arrival for macOS](macos/)** puts a subway bullet in the menu bar; click it for live countdowns and service alerts. macOS 13 or later, from the [latest release](https://github.com/madebysan/arrival/releases/latest).

## How it works

Both apps read the MTA's free [GTFS-Realtime feeds](https://api.mta.info/), the same data behind the countdown clocks in stations.

## Privacy

No account, analytics or server: the apps talk to the MTA feeds directly. The privacy policy is at [santiagoalonso.com/arrival/privacy](https://santiagoalonso.com/arrival/privacy).

## Install

Get the iPhone app from the App Store and the Mac app from Releases. To build them: open `ios/ArrivaliOS.xcodeproj` in Xcode 16 or later, or run `swift build -c release` inside `macos/`.

---

[MIT](LICENSE). Third-party components and their licenses are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Made by [santiagoalonso.com](https://santiagoalonso.com)
