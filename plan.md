# SubwayBar — macOS Menu Bar App for NYC Subway Arrivals

A native macOS menu bar app that shows real-time NYC subway arrival times for any station. Click the menu bar icon to see the next 3 trains, service alerts, and a "leave now" indicator based on your walking time.

## Tech Stack

- **Language:** Swift 6.0+
- **Framework:** SwiftUI with MenuBarExtra (macOS 13+)
- **Data format:** GTFS-Realtime (protobuf)
- **Protobuf library:** apple/swift-protobuf (1.27.0+)
- **Data source:** MTA GTFS-RT feeds (free, no API key required)
- **Build system:** Swift Package Manager
- **Target:** macOS 13+ (Ventura and later)

### Why This Stack

MenuBarExtra is the native SwiftUI API for menu bar apps — no third-party dependencies needed. The MTA feeds are free protobuf endpoints, and apple/swift-protobuf is the standard way to parse them in Swift. No server, no database, no accounts needed.

## Features

### 1. Menu bar icon (subway bullet)
**Approach:** Render a colored circle with the route letter/number (e.g., orange circle with white "F") as an NSImage for the menu bar. Use the official MTA color for each line. When no station is configured, show a generic train SF Symbol.
**Complexity:** Low

### 2. Fetch arrivals on click
**Approach:** When the user clicks the menu bar icon, fire an HTTP GET to the appropriate MTA GTFS-RT feed endpoint for the selected line group (e.g., `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-bdfm` for the F train). Parse the protobuf response using swift-protobuf generated types. Filter `TripUpdate` entities by the user's stop ID and direction. Extract arrival times (Unix timestamps), compute minutes until arrival, and return the next 3.
**Complexity:** Medium

### 3. Arrival display dropdown
**Approach:** SwiftUI popover/menu showing:
- Station name and direction at the top
- Next 3 trains as rows: route bullet + "X min" countdown + destination
- If walking time is set and a train arrives within walk time: highlight with "Leave now!" indicator
- "Last updated: X seconds ago" at the bottom
- Loading state while fetching
- Error state if fetch fails ("No data — tap to retry")
**Complexity:** Low

### 4. Station picker (all stations)
**Approach:** Bundle the MTA's `stops.txt` file (from GTFS static feed) in the app. Parse it at launch to build a station list. The settings view has:
- A searchable list of all stations (text field + filtered list)
- After picking a station, show available lines at that station
- After picking a line, show direction options (based on stop ID suffixes N/S)
- Save selection to UserDefaults
The `stops.txt` file is ~470 parent stations. We parse `stop_id`, `stop_name`, `parent_station`, and `location_type` columns. Group platform stops under their parent station.
**Complexity:** Medium

### 5. Walking time
**Approach:** Settings panel with a stepper or text field: "Minutes to walk to station: [5]". Saved to UserDefaults. In the arrival display, if a train arrives in <= walk time minutes, show a "Leave now!" badge. If arrival is < walk time, show in muted/gray text (you can't make it).
**Complexity:** Low

### 6. Service alerts
**Approach:** Fetch the MTA service alerts feed (`https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/camsys%2Fall-alerts`). This uses the Mercury protobuf extension — need to download and compile `mercury-gtfs-realtime.proto` alongside the base proto. Filter alerts by agency ID `MTASBWY` and the user's selected route. Display alert text in the dropdown below the arrivals: a yellow/orange banner with the alert header text. If no alerts, show "Good service" in green.
**Complexity:** Medium

## File Structure

```
subway-bar/
  Package.swift
  Sources/
    SubwayBar/
      SubwayBarApp.swift          # App entry point, MenuBarExtra setup
      Views/
        ArrivalView.swift          # Main dropdown content
        SettingsView.swift         # Station picker, walking time
        StationPickerView.swift    # Searchable station list
      Models/
        Station.swift              # Station/stop data model
        Arrival.swift              # Parsed arrival data
        ServiceAlert.swift         # Alert data model
      Services/
        MTAService.swift           # API client — fetch + parse feeds
        StationStore.swift         # Load/parse stops.txt, station lookup
        SettingsManager.swift      # UserDefaults wrapper
      Proto/
        gtfs_realtime.pb.swift     # Generated from gtfs-realtime.proto
        nyct_subway.pb.swift       # Generated from nyct-subway.proto
        mercury.pb.swift           # Generated from mercury-gtfs-realtime.proto
      Resources/
        stops.txt                  # Bundled MTA station data
      Utilities/
        SubwayColors.swift         # MTA line colors (official hex values)
        SubwayIcon.swift           # Generate colored bullet icons
  Tests/
    SubwayBarTests/
      MTAServiceTests.swift
      StationStoreTests.swift
```

## MTA Data Details

### Feed URLs (no API key required)

| Feed | Lines | URL |
|------|-------|-----|
| 1234567/S | 1,2,3,4,5,6,7,S | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs` |
| ACE | A,C,E | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-ace` |
| BDFM | B,D,F,M | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-bdfm` |
| G | G | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-g` |
| JZ | J,Z | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-jz` |
| NQRW | N,Q,R,W | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-nqrw` |
| L | L | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-l` |
| SIR | SIR | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/nyct%2Fgtfs-si` |
| Alerts | All | `https://api-endpoint.mta.info/Dataservice/mtagtfsfeeds/camsys%2Fall-alerts` |

### Stop ID Format
- Parent station: `F15` (base code)
- Platform stops: `F15N` (northbound/Manhattan-bound), `F15S` (southbound/Coney Island-bound)
- Real-time feeds use platform-level IDs

### Proto Files Needed
1. `gtfs-realtime.proto` — from Google's transit repo
2. `nyct-subway.proto` — from MTA (extends GTFS-RT with NYCT-specific fields)
3. `mercury-gtfs-realtime.proto` — from MTA (for service alerts feed)

### Default Station
- **Station:** 15th St-Prospect Park
- **Line:** F
- **Direction:** Manhattan-bound (northbound, stop suffix N)
- **Feed group:** BDFM

## Implementation Order

1. **Proto setup** — Download proto files, generate Swift types, verify parsing works
2. **Menu bar icon** — Basic MenuBarExtra with SF Symbol placeholder
3. **MTA service (arrivals)** — HTTP fetch + protobuf decode for trip updates
4. **Station data** — Bundle stops.txt, parse it, build station model
5. **Arrival display** — Show next 3 trains in dropdown
6. **Station picker** — Settings view with searchable station list
7. **Walking time** — Settings + "Leave now" indicator
8. **Service alerts** — Fetch + parse Mercury alerts, display in dropdown
9. **Menu bar icon (final)** — Colored subway bullet based on selected line

## Design

- **Theme:** System (follows macOS dark/light mode automatically)
- **Feel:** Native macOS, clean, utilitarian — like Activity Monitor or Battery menu
- **Typography:** System font (SF Pro)
- **Colors:** MTA official line colors for subway bullets, system colors for everything else
- **Layout:** Standard macOS menu bar popover width (~300px)

## Out of Scope (v1+)

- Multiple saved stations / favorites
- Notifications ("your train is in 3 minutes")
- Walking directions integration
- Widget / Live Activity
- Background polling / auto-refresh
- Map view
- Trip planning

---

run_contract:
  max_iterations: 30
  completion_promise: "V0_COMPLETE"
  on_stuck: defer_and_continue
  on_ambiguity: choose_simpler_option
  on_regression: revert_to_last_clean_commit
  human_intervention: never
  visual_qa_max_passes: 1
  visual_qa_agentation: skip
  phase_skip:
    qa_console: true
    visual_qa: false
    security: false
  complexity_overrides:
    menu_bar_icon: "Colored circle with route letter, NSImage rendered programmatically"
    station_picker: "All stations from bundled stops.txt, searchable list"
    service_alerts: "Full Mercury protobuf parsing, detailed alert text"
    walking_time: "Simple number in UserDefaults, leave-now indicator"
    fetch_approach: "On-click fetch, no background polling"
    protobuf: "apple/swift-protobuf, generate Swift from .proto files"
