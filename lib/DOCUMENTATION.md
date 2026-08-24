# Smart Farm Nigeria — Technical Documentation

## Overview

Smart Farm Nigeria is a Flutter mobile app for smallholder farmers in Northern Nigeria, focused on maize, rice, groundnut, and beans. It provides crop diagnosis, live weather/soil data, and regional market price estimates — all designed to work with limited internet access.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Weather & Soil data:** Open-Meteo API (free, no API key required)
- **Location services:** Geolocator package (GPS)
- **Reverse geocoding:** OpenStreetMap Nominatim (converts GPS coordinates to state/region names)
- **Photo capture:** image_picker package
- **HTTP requests:** http package
- **Version control:** Git + GitHub Desktop
- **Repository:** github.com/ishaq6835/smart_farm_nigeria_app

## App Structure
lib/
├── main.dart # App entry point, home screen with 4 feature tiles
├── diagnose_screen.dart # Crop selection screen
├── photo_screen.dart # Photo capture + mock diagnosis result
├── weather_screen.dart # Live GPS-based weather and soil data
├── market_screen.dart # GPS-based regional market prices
└── tutorial_screen.dart # Interactive "How to Use" walkthrough

## Features

### 1. Diagnose Crop
- User selects a crop: Maize, Rice, Groundnut, or Beans
- Takes or uploads a photo of the affected plant
- Tapping "Analyze" currently shows a placeholder result
- **Status:** UI complete; real AI-based diagnosis not yet implemented

### 2. Weather & Soil
- Detects the user's current GPS location
- Fetches live weather data: temperature, humidity, precipitation
- Fetches soil data: surface temperature, soil moisture
- Shows a 7-day forecast
- **Status:** Fully functional with real data

### 3. Market Prices
- Detects the user's state via GPS + reverse geocoding
- Shows estimated price ranges for 4 crops, covering all 36 states + FCT
- Calculates real distances (via GPS) to a list of known markets, showing the 5 nearest
- **Status:** Functional, but prices are regional estimates (updated periodically), not live per-market data — there is currently no free live API for Nigerian crop prices

### 4. How to Use (Tutorial)
- Swipeable walkthrough explaining each feature
- Includes "Try it now" buttons linking directly to each real screen

## Known Limitations / Not Yet Built

- **AI diagnosis:** Currently a placeholder; needs an actual image classification model (this is the largest remaining engineering task)
- **Offline data caching:** Weather and price data are not saved locally; no internet means no data on those screens
- **Local language support:** Planned (e.g. Hausa) for diagnosis and treatment instructions, not yet implemented
- **Market prices:** Estimates only, not live/per-market real data (no free source currently exists)

## Setup Instructions

```bash
flutter pub get
flutter run
```

Requires:
- Flutter SDK installed
- Android SDK + a connected Android device (or emulator)
- Internet connection (for Weather & Soil and Market Prices screens)

## Future Roadmap (from original project blueprint)

- Real AI-based crop disease diagnosis (computer vision model)
- Offline-first data storage and sync
- Local language support (Hausa and others)
- Voice input/output for accessibility
- Crowd-sourced or live market price data
- Grant applications (e.g. Orange Corners, Tony Elumelu Foundation)

## Author

Ishaq Abdullahi — Federal University of Kashere