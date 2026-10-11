import SwiftUI
import WidgetKit

// MARK: - Small Widget

struct ArrivalWidgetSmallView: View {
    let entry: ArrivalEntry

    var body: some View {
        if let stop = entry.stop {
            VStack(alignment: .leading, spacing: 4) {
                // Route bullet + station name + direction
                HStack(spacing: 5) {
                    SubwayBullet(route: stop.route, size: 20)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(stop.stationName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(stop.directionLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Next 3 arrivals
                if entry.arrivals.isEmpty {
                    Spacer()
                    Text("No trains")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ForEach(Array(entry.arrivals.prefix(3).enumerated()), id: \.offset) { _, arrival in
                        HStack {
                            if arrival.route != stop.route {
                                SubwayBullet(route: arrival.route, size: 14)
                            }
                            Text(arrival.destination)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Spacer()
                            let minutes = minutesUntil(arrival.arrivalTime, from: entry.date)
                            Text(countdownText(minutes))
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                        }
                    }
                    Spacer(minLength: 0)
                }

                // Sync timestamp
                SyncLabel(fetchedAt: entry.fetchedAt, now: entry.date)
            }
            .padding(2)
        } else {
            VStack(spacing: 8) {
                Image(systemName: "tram.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text("Add a stop\nin Arrival")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Medium Widget

struct ArrivalWidgetMediumView: View {
    let entry: ArrivalEntry

    var body: some View {
        if let stop = entry.stop {
            HStack(spacing: 12) {
                // Left: route + station info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        SubwayBullet(route: stop.route, size: 28)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(stop.stationName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(stop.directionLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // "Leave now" badge
                    if let first = entry.arrivals.first {
                        let minutes = minutesUntil(first.arrivalTime, from: entry.date)
                        if minutes <= stop.walkingTimeMinutes && minutes > 0 {
                            Text("Leave now!")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.green, in: Capsule())
                        }
                    }
                }

                Spacer()

                // Right: arrival list
                VStack(alignment: .trailing, spacing: 6) {
                    if entry.arrivals.isEmpty {
                        Spacer()
                        Text("No upcoming trains")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    } else {
                        ForEach(Array(entry.arrivals.prefix(3).enumerated()), id: \.offset) { index, arrival in
                            HStack(spacing: 8) {
                                // Show route bullet if different from stop route
                                if arrival.route != stop.route {
                                    SubwayBullet(route: arrival.route, size: 16)
                                }
                                Text(arrival.destination)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Spacer()
                                let minutes = minutesUntil(arrival.arrivalTime, from: entry.date)
                                Text(countdownText(minutes))
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(minutes <= 1 ? .red : .primary)
                            }
                        }
                        Spacer(minLength: 0)
                    }

                    // Sync timestamp
                    SyncLabel(fetchedAt: entry.fetchedAt, now: entry.date)
                }
            }
            .padding(2)
        } else {
            // No stop configured
            HStack(spacing: 12) {
                Image(systemName: "tram.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Arrival")
                        .font(.headline)
                    Text("Tap to select a stop")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Sync Label

struct SyncLabel: View {
    let fetchedAt: Date
    let now: Date

    var body: some View {
        let ago = Int(now.timeIntervalSince(fetchedAt)) / 60
        let text = ago < 1 ? "just now" : "\(ago)m ago"
        Text("Updated \(text)")
            .font(.system(size: 9))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Helpers

// Calculate minutes between the entry's date and an arrival time
private func minutesUntil(_ arrivalTime: Date, from date: Date) -> Int {
    max(0, Int(arrivalTime.timeIntervalSince(date)) / 60)
}

// Format minutes as a countdown string
private func countdownText(_ minutes: Int) -> String {
    if minutes == 0 {
        return "Now"
    } else if minutes == 1 {
        return "1 min"
    } else {
        return "\(minutes) min"
    }
}
