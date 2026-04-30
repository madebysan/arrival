## 2026-04-30 (session 1)

### Features
- **App Store submission** — Arrival 1.0 (build 2) submitted to Apple Review queue at 23:01 UTC
- **Fastlane automation** — preflight, bump, build, upload, metadata, release, submit lanes
- **Public privacy + support docs** — `docs/privacy-policy.md` and `docs/support.md` (used for App Store URLs)
- **App Store metadata** — name, subtitle, description, keywords, screenshots in `fastlane/metadata/en-US/`

### Fixes
- Set `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` for export compliance
- Restricted `TARGETED_DEVICE_FAMILY` to `"1"` (iPhone-only) on app and widget

### Status: submitted to Apple Review — `automatic_release: true`, will go live on approval
