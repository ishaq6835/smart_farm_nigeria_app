import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _weatherData;
  bool _isFromCache = false;
  String? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final position = await _getCurrentLocation();
      await _fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      // If live fetch fails, try loading cached data instead
      final loadedCache = await _loadFromCache();
      if (!loadedCache) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled. Please enable them.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied. Enable it in settings.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,precipitation,soil_moisture_0_to_1cm,soil_temperature_0cm'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum'
      '&timezone=auto',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _saveToCache(response.body);
      setState(() {
        _weatherData = data;
        _isFromCache = false;
        _loading = false;
      });
    } else {
      throw 'Failed to load weather data';
    }
  }

  Future<void> _saveToCache(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_weather', jsonString);
    await prefs.setString('cached_weather_time', DateTime.now().toIso8601String());
  }

  Future<bool> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_weather');
    final cachedTime = prefs.getString('cached_weather_time');

    if (cached != null) {
      setState(() {
        _weatherData = json.decode(cached);
        _isFromCache = true;
        _lastUpdated = cachedTime;
        _loading = false;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & Soil'),
        backgroundColor: Colors.green[800],
      ),
      body: RefreshIndicator(
        onRefresh: _init,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _init,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final current = _weatherData!['current'];
    final daily = _weatherData!['daily'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isFromCache)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Offline — showing saved data from ${_lastUpdated != null ? DateTime.parse(_lastUpdated!).toLocal().toString().substring(0, 16) : "earlier"}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text('Current Weather', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(
                  '${current['temperature_2m']}°C',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text('Humidity: ${current['relative_humidity_2m']}%'),
                Text('Precipitation: ${current['precipitation']} mm'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: Colors.brown[50],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Soil Conditions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _soilRow('Soil Temp (surface)', '${current['soil_temperature_0cm']}°C'),
                _soilRow('Soil Moisture (0-1cm)', '${(current['soil_moisture_0_to_1cm'] * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('7-Day Forecast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...List.generate(daily['time'].length, (index) {
          return Card(
            child: ListTile(
              title: Text(daily['time'][index]),
              subtitle: Text('Rain: ${daily['precipitation_sum'][index]} mm'),
              trailing: Text(
                '${daily['temperature_2m_min'][index]}° / ${daily['temperature_2m_max'][index]}°',
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _soilRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}