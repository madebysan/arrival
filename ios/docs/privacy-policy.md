# Arrival Privacy Policy

Last updated: April 30, 2026

## The short version

Arrival doesn't collect, store, or transmit any personal data. There is no account system, no analytics, no advertising, no third-party tracking, and no server you can connect to. Saved stations live on your device.

## What data Arrival uses

**On your device only:**

- Stations you save
- Display preferences (direction filters, station order)

This is stored in iOS's standard local storage and is never transmitted anywhere.

**Network requests Arrival makes:**

- The MTA's public GTFS-Realtime feed at `api-endpoint.mta.info`. This request fetches subway arrival data. No identifying information is sent in the request beyond the standard headers Apple's URLSession includes (iOS version, app bundle identifier).

That's it. There are no other network requests.

## What Arrival does NOT collect

- Your name, email, phone number, or any contact information
- Your location (the app does not use GPS or location services)
- Your usage patterns (what stations you save, how often you check arrivals, what time of day you use the app)
- Crash reports
- Any device identifier
- Any kind of advertising identifier

## Third parties

Arrival does not use any third-party SDKs, analytics services, advertising networks, or backend services. The only third party involved is the MTA itself, which receives a public, anonymous HTTP request for realtime data — same as any web browser hitting their public feed.

## Children's privacy

Arrival does not knowingly collect any data from anyone. There is no signup. The app is appropriate for all ages.

## Changes to this policy

If this policy ever changes, the updated version will be committed to the public repository at github.com/madebysan/arrival-ios with a clear changelog entry. The "Last updated" date at the top of this file will reflect the change.

## Contact

Questions about privacy: [hi@santiagoalonso.com](mailto:hi@santiagoalonso.com)
