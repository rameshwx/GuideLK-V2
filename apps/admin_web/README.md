# GuideLK Admin Web

Flutter web admin console served from `/guidelkv2/admin/` via hash routing. The application now
ships the full MVP surface: user management, attractions CRUD with a Sri Lanka constrained map,
partner stay onboarding, localization tooling, system configuration (tiles/upload settings &
feature flags), and a news stub ready for future API wiring. Sample data is backed by Riverpod
state notifiers so the UI behaves like the production workflow without touching the API yet.

## Development

1. Install Flutter 3.19 or newer.
2. Run `flutter pub get`.
3. Set `ADMIN_TILES_URL` at compile time if you need a different map provider:
   ```bash
   flutter run -d chrome --dart-define=ADMIN_TILES_URL=https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=KEY
   ```
4. Build for production with hash routing enabled:
   ```bash
   flutter build web --wasm --dart-define=ADMIN_TILES_URL=... --web-renderer canvaskit --base-href /guidelkv2/admin/
   ```

Upload the `build/web` directory to the hosting environment and ensure Apache serves it at
`https://www.nodecmb.com/guidelkv2/admin/`.
