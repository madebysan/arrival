import SwiftUI

// Main dropdown content showing arrivals, alerts, and controls
struct ArrivalView: View {
    @ObservedObject var settings = SettingsManager.shared
    @State private var arrivals: [Arrival] = []
    @State private var alerts: [ServiceAlert] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastUpdated: Date?

    var onOpenSettings: () -> Void

    // Timer to refresh the countdown display every 15 seconds
    let refreshTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: station name and direction
            headerSection

            Divider()

            if isLoading && arrivals.isEmpty {
                loadingSection
            } else if let error = errorMessage, arrivals.isEmpty {
                errorSection(error)
            } else {
                arrivalsList
            }

            // Service alerts section
            if !alerts.isEmpty {
                Divider()
                alertsSection
            } else if !isLoading {
                Divider()
                goodServiceBanner
            }

            Divider()

            // Footer: last updated + settings
            footerSection
        }
        .frame(width: 300)
        .onAppear {
            Task { await refreshData() }
        }
        .onReceive(refreshTimer) { _ in
            // Just trigger a view refresh for countdown updates
            // Also re-fetch every minute
            if let last = lastUpdated, Date().timeIntervalSince(last) > 60 {
                Task { await refreshData() }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            SubwayIcon.BulletView(route: settings.selectedRoute, size: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(settings.selectedStationName)
                    .font(.headline)
                Text(settings.directionLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Refresh button
            Button(action: {
                Task { await refreshData() }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding(12)
    }

    // MARK: - Arrivals List

    private var arrivalsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            let displayArrivals = Array(arrivals.prefix(5))
            if displayArrivals.isEmpty && !isLoading {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "tram")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("No upcoming trains")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(displayArrivals) { arrival in
                    arrivalRow(arrival)
                    if arrival.id != displayArrivals.last?.id {
                        Divider().padding(.leading, 40)
                    }
                }
            }
        }
    }

    private func arrivalRow(_ arrival: Arrival) -> some View {
        let isLeaveNow = settings.walkingTimeMinutes > 0 &&
            arrival.currentMinutesAway <= settings.walkingTimeMinutes &&
            arrival.currentMinutesAway > 0
        let isMissed = settings.walkingTimeMinutes > 0 &&
            arrival.currentMinutesAway < settings.walkingTimeMinutes &&
            arrival.currentMinutesAway > 0

        return HStack(spacing: 8) {
            SubwayIcon.BulletView(route: arrival.route, size: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(arrival.destination)
                    .font(.subheadline)
                    .foregroundColor(isMissed && !isLeaveNow ? .secondary : .primary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                if isLeaveNow {
                    Text("Leave now!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green)
                        .cornerRadius(4)
                }
                Text(arrival.countdownText)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(arrival.currentMinutesAway == 0 ? .red : .primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Alerts

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(alerts) { alert in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(alert.headerText)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 4)
    }

    private var goodServiceBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text("Good service")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Loading / Error

    private var loadingSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("Fetching arrivals...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 24)
            Spacer()
        }
    }

    private func errorSection(_ message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.title2)
                    .foregroundColor(.orange)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Button("Tap to retry") {
                    Task { await refreshData() }
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack {
            if let lastUpdated = lastUpdated {
                let seconds = Int(Date().timeIntervalSince(lastUpdated))
                Text("Updated \(seconds < 5 ? "just now" : "\(seconds)s ago")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onOpenSettings) {
                Image(systemName: "gear")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .font(.caption2)
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Data Fetching

    private func refreshData() async {
        isLoading = true
        errorMessage = nil

        // Fetch arrivals and alerts concurrently
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchArrivals()
            }
            group.addTask {
                await self.fetchAlerts()
            }
        }

        isLoading = false
        lastUpdated = Date()
    }

    private func fetchArrivals() async {
        do {
            let result = try await MTAService.shared.fetchArrivals(
                route: settings.selectedRoute,
                stopID: settings.platformStopID
            )
            await MainActor.run {
                self.arrivals = result
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchAlerts() async {
        do {
            let result = try await MTAService.shared.fetchAlerts(for: settings.selectedRoute)
            await MainActor.run {
                self.alerts = result
            }
        } catch {
            // Alerts are non-critical, just clear them on error
            await MainActor.run {
                self.alerts = []
            }
        }
    }
}
