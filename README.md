# Street Team App v3

The Street Team App is mobile application designed to enable field agents to collect, manage, and update structured data related to locations and organizations

## Features

- Interactive map
- Organization markers
- Marker clustering
- Custom SVG icons
- Minimal map labels
- GeoJSON data support
- Location Management
- Organization Management


---

# Setup
# Prequisites
Before running the project, ensure you have:

- Flutter SDK `3.11.4+`
- Dart SDK `3.11.4+`
- Mapbox Access Token

## 1. Clone Project

```bash
git clone https://github.com/RWBuild/Street_Team_App_Flutter
or 
git clone git@github.com:Rwbuild/Street_Team_App_Flutter
cd street_team
```

---

## 2. Setup envronment

In env/ create environment file eg: .env.dev.json
```bash
{
"ENV":"development",
"ENABLE_LOGS": true,
"SENTRY_DSN": "",
"APP_NAME": "Street Team",
"MAP_BOX_ACCESS_TOKEN": ""
}

```

## 3. Install Dependencies

# Packages Used

| Package | Purpose |
|---|---|
| flutter_riverpod | State management |
| flutter_screenutil | Responsive UI scaling |
| flutter_svg | SVG rendering |
| geolocator | User location services |
| go_router | App routing/navigation |
| google_fonts | Custom fonts |
| latlong2 | Latitude & longitude models |
| lottie | Animations |
| mapbox_maps_flutter | Mapbox integration |
| sentry_flutter | Error tracking |
| talker_flutter | Logging/debugging |
| url_launcher | Open external links |
| vector_graphics | Optimized vector rendering |

---
## 3.1 Install Dependencies
```bash
flutter pub get
```

---
## 4. Run App

```bash
flutter run --dart-define-from-file=env/env.dev.jso
```

---
