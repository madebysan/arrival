import WidgetKit
import SwiftUI

// The widget definition — appears in the widget gallery as "Arrival"
struct ArrivalWidget: Widget {
    let kind: String = "ArrivalWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectStopIntent.self,
            provider: ArrivalTimelineProvider()
        ) { entry in
            ArrivalWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Arrival")
        .description("Real-time subway arrivals for a saved stop.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Routes to the correct view based on widget size
struct ArrivalWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ArrivalEntry

    var body: some View {
        switch family {
        case .systemSmall:
            ArrivalWidgetSmallView(entry: entry)
        case .systemMedium:
            ArrivalWidgetMediumView(entry: entry)
        default:
            ArrivalWidgetSmallView(entry: entry)
        }
    }
}

// Widget extension entry point
@main
struct ArrivalWidgetBundle: WidgetBundle {
    var body: some Widget {
        ArrivalWidget()
    }
}
