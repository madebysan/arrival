<p><img src="ios/assets/app-icon.png" width="128" height="128" alt="Arrival app icon"></p>

<h1>Arrival</h1>

<p>Real-time NYC subway arrivals on your iPhone and in your Mac menu bar.<br>
Never miss your train.</p>

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

I commute the same route every day. The only thing I actually need is when is the next train at my stop, on my line, going my direction.

## Apps

| App | What it does | Get it |
| --- | --- | --- |
| [Arrival for iOS](ios/) | Up to four saved stops, walking times, and home screen widgets that show the next trains you can still catch. iOS 17+. | [App Store](https://apps.apple.com/us/app/arrival-nyc-subway/id6759941751) |
| [Arrival for macOS](macos/) | A colored subway bullet in the menu bar. Click it for live countdowns and service alerts. macOS 13+. | [Latest release](https://github.com/madebysan/arrival/releases/latest) |

Both apps cover every subway line and roughly 496 stations. Data comes from the MTA's free [GTFS-Realtime feeds](https://api.mta.info/), the same source used by the countdown clocks in stations. No account, no analytics, no server.

## Repository layout

- [`ios/`](ios/): SwiftUI app with WidgetKit and AppIntents widgets. Open `ArrivaliOS.xcodeproj` in Xcode 16+.
- [`macos/`](macos/): Swift package for the `MenuBarExtra` app. Run `swift build -c release` inside `macos/`.

Privacy policy: [santiagoalonso.com/arrival/privacy](https://santiagoalonso.com/arrival/privacy)

## License

[MIT](LICENSE). Open-source components and their licenses are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Made by [santiagoalonso.com](https://santiagoalonso.com)
