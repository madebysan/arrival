import SwiftUI

// Main screen — list of saved stop cards with pull-to-refresh
struct HomeView: View {
    @Bindable var stopManager: StopManager
    @State private var showAddStop = false
    @State private var showSettings = false
    @State private var refreshID = UUID() // force card refresh

    // Timer to refresh countdown displays every 15 seconds
    let refreshTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Group {
                if stopManager.hasStops {
                    stopsList
                } else {
                    emptyState
                }
            }
            .navigationTitle("Arrival")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if stopManager.canAddStop {
                        Button {
                            showAddStop = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddStop) {
                AddStopFlow { newStop in
                    stopManager.addStop(newStop)
                    showAddStop = false
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onReceive(refreshTimer) { _ in
                // Trigger a view refresh for countdown updates
                refreshID = UUID()
            }
        }
    }

    // MARK: - Stops List

    private var stopsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(stopManager.stops) { stop in
                    StopCard(stop: stop)
                        .id("\(stop.id)-\(refreshID)")
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    stopManager.removeStop(id: stop.id)
                                }
                            } label: {
                                Label("Remove Stop", systemImage: "trash")
                            }
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .refreshable {
            // Force all cards to re-fetch
            refreshID = UUID()
            // Small delay so the refresh indicator shows
            try? await Task.sleep(for: .seconds(0.5))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "tram.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("No stops yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your commute stops to see\nreal-time subway arrivals.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddStop = true
            } label: {
                Label("Add a Stop", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}
