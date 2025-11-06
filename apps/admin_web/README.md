# GuideLK Admin Web

Flutter web admin console served from `/guidelkv2/admin/` via hash routing. The starter dashboard
already includes a Sri Lanka bounded map using an external XYZ tiles provider and placeholder
modules for the MVP scope.

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
