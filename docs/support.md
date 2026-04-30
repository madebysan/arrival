# Arrival Support

Real-time NYC subway arrivals. Saved stations, live countdowns, home screen widget.

## Contact

Email: [hi@santiagoalonso.com](mailto:hi@santiagoalonso.com)

I read every email. Bug reports, feature requests, and general feedback are all welcome.

## Frequently asked questions

### Where does the arrival data come from?

The MTA's official GTFS-Realtime feed at `api-endpoint.mta.info`. This is the same data source the official MTA app uses. Arrival just shows it in a faster, simpler interface.

### Why is a train showing as "due" but I don't see it?

Arrival times are estimates from the MTA, not from the app. When the MTA's data says a train is "due", that means the agency expects it within roughly the next minute. Real-world arrival can vary by ±2 minutes depending on signal conditions, station congestion, and crew changes.

### Times feel stale or aren't updating

Arrival fetches new data every 60 seconds while the app is open. If you're underground without signal, times will pause until you reconnect. Pull down to force a refresh.

### How do I add a station?

Tap the **+** button on the home screen, search for a station name (or browse by line), pick the platform direction, and tap Save. The station now lives on your home screen with live arrivals.

### How do I reorder my stations?

Long-press a station card and drag it to a new position.

### How do I delete a station?

Swipe left on the station card and tap Delete. You can also tap and hold to enter edit mode.

### Is there a home screen widget?

Yes. Long-press your iPhone home screen → tap **+** → search "Arrival" → pick a small or medium widget. The widget shows the next two arrivals for one of your saved stations.

### Does Arrival work outside NYC?

No. Arrival is built specifically for the NYC subway system using the MTA's realtime feed. Other transit systems aren't supported.

### Does Arrival work for buses?

Not yet. Subway only.

### Does Arrival need an account?

No. There's no signup, no login, nothing to forget. Saved stations live on your device.

### Does Arrival collect any data?

No. See the [privacy policy](privacy-policy.md) for full detail. The short version: nothing leaves your device except the request to fetch realtime arrival data from the MTA.

### Why was a station's arrival data missing?

Occasionally the MTA's feed has gaps for individual lines (most often the L during scheduled maintenance windows). When the feed is empty, Arrival shows "No arrivals reported" instead of guessing.

### Can I get notifications when my train is arriving?

Not in v1. This is on the roadmap.

### Do you offer Apple Watch support?

Not in v1. This is on the roadmap.

## Reporting bugs

The fastest way is email. Include:

1. What you were trying to do
2. What happened instead
3. The station name and time of day (helps reproduce)
4. Your iPhone model and iOS version

Screenshots help a lot too.

## Privacy and data

See the [full privacy policy](privacy-policy.md).
