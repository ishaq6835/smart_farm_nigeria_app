# Smart Farm Nigeria 🌾

An offline-first mobile app helping smallholder farmers in Northern Nigeria diagnose crop diseases and access real-time weather, soil, and market data built for maize, rice, groundnut, and beans farmers.

## About

Smart Farm Nigeria is a Flutter-based agritech app designed for farmers in Gombe State and across Northern Nigeria. The goal is simple, practical tools that work even with limited connectivity: point your phone camera at a sick crop, check today's weather and soil conditions, and see market price estimates for your region all in one place.

## Features

- 🌱 **Diagnose Crop** — Select your crop (Maize, Rice, Groundnut, Beans), take or upload a photo, and get a diagnosis
- ☁️ **Weather & Soil** — Live weather, soil temperature, and soil moisture based on your current GPS location
- 💰 **Market Prices** — GPS-detected regional price estimates covering all 36 Nigerian states + FCT, plus nearest real markets calculated by distance
- 📖 **How to Use** — An interactive, swipeable tutorial with "Try it now" buttons linking straight to each feature
- 🗣️ **Local language support** — *(planned)* diagnosis and treatment instructions in Hausa and other local languages

## Tech Stack

- **Flutter** — cross-platform mobile framework
- **Open-Meteo API** — free weather and soil data
- **Geolocator** — GPS-based location
- **OpenStreetMap Nominatim** — reverse geocoding (GPS to state name)
- **Image Picker** — camera and gallery photo capture

## Status

🚧 Active development  home screen, crop diagnosis flow (mock results for now), live weather/soil data, and GPS-based market price estimates are all working. Real AI-based diagnosis, offline data storage, and local language support are still in progress.

See [DOCUMENTATION.md](./DOCUMENTATION.md) for full technical details.

## Getting Started

```bash
flutter pub get
flutter run
```

## Author

Ishaq Abdullahi — Federal University of Kashere