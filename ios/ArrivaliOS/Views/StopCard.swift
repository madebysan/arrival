import SwiftUI

// One card showing arrivals for a tracked stop
struct StopCard: View {
    let stop: TrackedStop
    @State private var arrivals: [Arrival] = []
    @State private var alerts: [ServiceAlert] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastFetched: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: route bullet + station + direction
            headerRow

            Divider()
                .padding(.horizontal, 16)

            // Arrivals or loading/error state
            if isLoading && arrivals.isEmpty {
                loadingState
            } else if let error = errorMessage, arrivals.isEmpty {
                errorState(error)
            } else if arrivals.isEmpty {
                emptyState
            } else {
                arrivalsRows
            }

            // Alert banner (if any)
            if let alert = alerts.first {
                alertBanner(alert)
            }

            // Last synced
            if let lastFetched {
                Text("Updated \(lastFetched, format: .dateTime.hour().minute())")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .padding(.top, 2)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .task {
            await refreshData()
            // Auto-refresh every 60 seconds while visible
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard !Task.isCancelled else { break }
                await refreshData()
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(spacing: 10) {
            SubwayBullet(route: stop.route, size: 32)

            VStack(alignment: .leading, spacing: 1) {
                Text(stop.stationName)
                    .font(.headline)
                Text(stop.directionLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .padding(16)
    }

    // MARK: - Arrivals

    private var arrivalsRows: some View {
        VStack(spacing: 0) {
            let displayed = Array(arrivals.prefix(3))
            ForEach(displayed) { arrival in
                arrivalRow(arrival)
                if arrival.id != displayed.last?.id {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .padding(.bottom, 8)
    }

    private func arrivalRow(_ arrival: Arrival) -> some View {
        let mins = arrival.currentMinutesAway
        let isLeaveNow = stop.walkingTimeMinutes > 0 &&
            mins <= stop.walkingTimeMinutes && mins > 0

        return HStack(spacing: 10) {
            SubwayBullet(route: arrival.route, size: 24)

            Text(arrival.destination)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            HStack(spacing: 6) {
                if isLeaveNow {
                    Text("Leave now!")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                Text(arrival.countdownText)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(mins == 0 ? .red : .primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Alert

    private func alertBanner(_ alert: ServiceAlert) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
            Text(alert.headerText)
                .font(.caption)
                .lineLimit(2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
    }

    // MARK: - States

    private var loadingState: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(.vertical, 24)
            Spacer()
        }
    }

    private func errorState(_ message: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 6) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await refreshData() }
                }
                .font(.caption)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                Image(systemName: "tram")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("No upcoming trains")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16)
            Spacer()
        }
    }

    // MARK: - Data

    func refreshData() async {
        isLoading = true
        errorMessage = nil

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    let result = try await MTAService.shared.fetchArrivals(
                        route: stop.route,
                        stopID: stop.platformStopID
                    )
                    await MainActor.run { arrivals = result }
                } catch {
                    await MainActor.run { errorMessage = error.localizedDescription }
                }
            }
            group.addTask {
                do {
                    let result = try await MTAService.shared.fetchAlerts(for: stop.route)
                    await MainActor.run { alerts = result }
                } catch {
                    await MainActor.run { alerts = [] }
                }
            }
        }

        isLoading = false
        lastFetched = Date()
    }
}
