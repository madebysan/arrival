# SubwayBar Build Report

## Summary

SubwayBar is a macOS menu bar app that shows real-time NYC subway arrival times. Built with Swift + SwiftUI + Swift Package Manager. Compiles cleanly, all 14 tests pass.

## What Was Built

### Proto Setup
- Downloaded `gtfs-realtime.proto` from Google's transit repo
- Created `nyct-subway.proto` manually (MTA download URL was unavailable)
- Generated Swift protobuf types using `protoc --swift_out`
- Dependency: `apple/swift-protobuf` 1.27.0+

### Menu Bar Icon
- Colored subway bullet rendered as NSImage (18px circle with route letter)
- Uses official MTA colors for each line (red for 1/2/3, orange for B/D/F/M, etc.)
- SwiftUI `BulletView` component for in-app use
- `isTemplate = false` so macOS preserves the color in the menu bar

### MTA Service (Arrivals)
- Async HTTP fetch from the correct GTFS-RT feed for the selected route
- Protobuf decoding with `TransitRealtime_FeedMessage`
- Filters `TripUpdate` entities by platform stop ID
- Extracts arrival timestamps, computes minutes until arrival
- Attempts destination lookup from last stop in trip update
- Returns arrivals sorted by time

### Station Data
- Bundled `stops.txt` from MTA GTFS static feed (1,489 lines)
- Parsed into ~496 parent stations with N/S platform stop IDs
- Searchable by name
- Route inference from stop ID prefix (e.g., F25 -> F, G trains)

### Arrival Display
- SwiftUI `.window`-style MenuBarExtra popover
- Header: station name, direction, route bullet, refresh button
- Up to 5 upcoming trains with route bullet, destination, countdown
- Countdown refreshes every 15 seconds; re-fetches every 60 seconds
- Loading spinner while fetching
- Error state with retry button
- "No upcoming trains" empty state

### Station Picker (Settings)
- 3-step flow: station search > route selection > direction + walking time
- Searchable station list with route bullets
- Back navigation between steps
- Saves to UserDefaults on confirm

### Walking Time
- Stepper (0-30 minutes) in settings
- "Leave now!" green badge when a train arrives within walking time
- Persisted in UserDefaults (default: 5 minutes)

### Service Alerts
- Fetches MTA `all-alerts` feed (standard GTFS-RT alert entities)
- Filters by selected route
- Shows orange warning banner with alert header text
- "Good service" green indicator when no alerts
- Non-blocking: alert fetch failures don't break the arrival display

### Settings Persistence
- `SettingsManager` singleton wrapping UserDefaults
- Default station: 15 St-Prospect Park, F train, Manhattan-bound (F25N)
- Persists: station ID, station name, route, direction, walking time

### Tests (14 passing)
- **StationStoreTests** (6): stations loaded, search by name, empty search, no results, station by ID, platform stops
- **MTAServiceTests** (8): feed URL for F train, all routes, invalid route, inferred routes, arrival countdown, arrival now, arrival 1-min

## File Structure

```
subway-bar/
  Package.swift
  .gitignore
  Sources/SubwayBar/
    SubwayBarApp.swift
    Info.plist
    Views/
      ArrivalView.swift
      SettingsView.swift
      StationPickerView.swift
    Models/
      Arrival.swift
      ServiceAlert.swift
      Station.swift
    Services/
      MTAService.swift
      SettingsManager.swift
      StationStore.swift
    Proto/
      gtfs-realtime.pb.swift
      nyct-subway.pb.swift
    Resources/
      stops.txt
    Utilities/
      SubwayColors.swift
      SubwayIcon.swift
  Tests/SubwayBarTests/
    MTAServiceTests.swift
    StationStoreTests.swift
```

## Build Verification

- `swift build` -- Clean, no warnings, no errors
- `swift test` -- 14/14 tests pass, 0 failures

## Deferred Items

1. **Mercury proto for service alerts** -- The MTA Mercury protobuf extension was not available for download. Service alerts use standard GTFS-RT alert entities instead, which still work for basic alert text. Detailed Mercury-specific fields (planned work schedules, etc.) are not parsed.

2. **LSUIElement** -- Info.plist is created with `LSUIElement = true` but SPM executable targets don't automatically embed Info.plist into the binary. For distribution, this would need to be applied via an Xcode project or a post-build script that creates a proper .app bundle.

3. **Route-to-station mapping** -- Station routes are inferred from stop ID prefix rather than parsed from the full GTFS `stop_times.txt` + `trips.txt` (35MB). This covers most cases but may be imprecise for complex stations served by many lines.

4. **Features listed as out of scope in plan** -- Multiple saved stations, notifications, background polling, map view, trip planning, widgets.

## How to Run

```bash
cd /Users/san/Projects/subway-bar
swift build
swift run
```

The app will appear as a colored subway bullet in the macOS menu bar. Click it to see arrivals. Click the gear icon to change station, route, direction, or walking time.
