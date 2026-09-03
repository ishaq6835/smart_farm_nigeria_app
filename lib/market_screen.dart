import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool _loading = true;
  String? _error;
  String _detectedState = '';
  Position? _userPosition;
  bool _isFromCache = false;
  String? _lastUpdated;

  final Map<String, Map<String, int>> _regionalPrices = {
    'Gombe': {'Maize': 45000, 'Rice': 85000, 'Groundnut': 120000, 'Beans': 95000},
    'Kano': {'Maize': 42000, 'Rice': 82000, 'Groundnut': 115000, 'Beans': 90000},
    'Kaduna': {'Maize': 40000, 'Rice': 80000, 'Groundnut': 110000, 'Beans': 88000},
    'Borno': {'Maize': 44000, 'Rice': 87000, 'Groundnut': 118000, 'Beans': 93000},
    'Bauchi': {'Maize': 43000, 'Rice': 84000, 'Groundnut': 117000, 'Beans': 92000},
    'Katsina': {'Maize': 41000, 'Rice': 81000, 'Groundnut': 112000, 'Beans': 89000},
    'Jigawa': {'Maize': 41500, 'Rice': 83000, 'Groundnut': 113000, 'Beans': 90000},
    'Adamawa': {'Maize': 44500, 'Rice': 86000, 'Groundnut': 119000, 'Beans': 94000},
    'Yobe': {'Maize': 43500, 'Rice': 85500, 'Groundnut': 118500, 'Beans': 93500},
    'Sokoto': {'Maize': 40500, 'Rice': 79500, 'Groundnut': 109500, 'Beans': 87500},
    'Zamfara': {'Maize': 40800, 'Rice': 80500, 'Groundnut': 111000, 'Beans': 88500},
    'Kebbi': {'Maize': 40200, 'Rice': 79000, 'Groundnut': 108500, 'Beans': 87000},
    'Niger': {'Maize': 41200, 'Rice': 81500, 'Groundnut': 112500, 'Beans': 89500},
    'Plateau': {'Maize': 42500, 'Rice': 83500, 'Groundnut': 116000, 'Beans': 91500},
    'Nasarawa': {'Maize': 42800, 'Rice': 84200, 'Groundnut': 116800, 'Beans': 92200},
    'Taraba': {'Maize': 43200, 'Rice': 84800, 'Groundnut': 117200, 'Beans': 92800},
    'Benue': {'Maize': 41800, 'Rice': 82500, 'Groundnut': 114500, 'Beans': 91000},
    'Kwara': {'Maize': 41000, 'Rice': 81200, 'Groundnut': 113200, 'Beans': 90200},
    'Kogi': {'Maize': 41500, 'Rice': 82000, 'Groundnut': 114000, 'Beans': 90500},
    'FCT': {'Maize': 43000, 'Rice': 84500, 'Groundnut': 117500, 'Beans': 93000},
    'Oyo': {'Maize': 42200, 'Rice': 83200, 'Groundnut': 115500, 'Beans': 91800},
    'Ogun': {'Maize': 43800, 'Rice': 86800, 'Groundnut': 121000, 'Beans': 96000},
    'Osun': {'Maize': 42600, 'Rice': 84600, 'Groundnut': 118000, 'Beans': 93200},
    'Ondo': {'Maize': 43400, 'Rice': 86000, 'Groundnut': 119800, 'Beans': 95200},
    'Ekiti': {'Maize': 42000, 'Rice': 83000, 'Groundnut': 115200, 'Beans': 91200},
    'Lagos': {'Maize': 47000, 'Rice': 92000, 'Groundnut': 128000, 'Beans': 101000},
    'Edo': {'Maize': 44200, 'Rice': 88200, 'Groundnut': 122500, 'Beans': 97000},
    'Delta': {'Maize': 45200, 'Rice': 90000, 'Groundnut': 125000, 'Beans': 99000},
    'Anambra': {'Maize': 44800, 'Rice': 89000, 'Groundnut': 123500, 'Beans': 98000},
    'Enugu': {'Maize': 43600, 'Rice': 86500, 'Groundnut': 120200, 'Beans': 95500},
    'Ebonyi': {'Maize': 42400, 'Rice': 84000, 'Groundnut': 116500, 'Beans': 92500},
    'Imo': {'Maize': 44600, 'Rice': 88600, 'Groundnut': 123000, 'Beans': 97600},
    'Abia': {'Maize': 44000, 'Rice': 87400, 'Groundnut': 121500, 'Beans': 96400},
    'Rivers': {'Maize': 46000, 'Rice': 91000, 'Groundnut': 126500, 'Beans': 100000},
    'Bayelsa': {'Maize': 46500, 'Rice': 91500, 'Groundnut': 127000, 'Beans': 100500},
    'Cross River': {'Maize': 43800, 'Rice': 87000, 'Groundnut': 121000, 'Beans': 96200},
    'Akwa Ibom': {'Maize': 45400, 'Rice': 90200, 'Groundnut': 125500, 'Beans': 99400},
  };

  final List<Map<String, dynamic>> _knownMarkets = [
    {'name': 'Kashere Market', 'lat': 10.05, 'lon': 11.20, 'state': 'Gombe'},
    {'name': 'Gombe Central Market', 'lat': 10.29, 'lon': 11.17, 'state': 'Gombe'},
    {'name': 'Kumo Market', 'lat': 10.05, 'lon': 11.21, 'state': 'Gombe'},
    {'name': 'Dukku Market', 'lat': 10.82, 'lon': 10.77, 'state': 'Gombe'},
    {'name': 'Kano Central Market', 'lat': 12.00, 'lon': 8.52, 'state': 'Kano'},
    {'name': 'Kaduna Central Market', 'lat': 10.52, 'lon': 7.44, 'state': 'Kaduna'},
    {'name': 'Bauchi Central Market', 'lat': 10.31, 'lon': 9.84, 'state': 'Bauchi'},
    {'name': 'Maiduguri Monday Market', 'lat': 11.85, 'lon': 13.16, 'state': 'Borno'},
    {'name': 'Yola Market', 'lat': 9.20, 'lon': 12.48, 'state': 'Adamawa'},
    {'name': 'Katsina Central Market', 'lat': 12.99, 'lon': 7.60, 'state': 'Katsina'},
    {'name': 'Dutse Market', 'lat': 11.76, 'lon': 9.34, 'state': 'Jigawa'},
    {'name': 'Sokoto Central Market', 'lat': 13.06, 'lon': 5.24, 'state': 'Sokoto'},
    {'name': 'Minna Market', 'lat': 9.61, 'lon': 6.55, 'state': 'Niger'},
    {'name': 'Jos Terminus Market', 'lat': 9.90, 'lon': 8.90, 'state': 'Plateau'},
    {'name': 'Makurdi Wurukum Market', 'lat': 7.73, 'lon': 8.53, 'state': 'Benue'},
    {'name': 'Ilorin Central Market', 'lat': 8.50, 'lon': 4.55, 'state': 'Kwara'},
    {'name': 'Wuse Market, Abuja', 'lat': 9.06, 'lon': 7.49, 'state': 'FCT'},
    {'name': 'Ibadan Bodija Market', 'lat': 7.44, 'lon': 3.90, 'state': 'Oyo'},
    {'name': 'Mile 12 Market, Lagos', 'lat': 6.60, 'lon': 3.39, 'state': 'Lagos'},
    {'name': 'Onitsha Main Market', 'lat': 6.15, 'lon': 6.79, 'state': 'Anambra'},
    {'name': 'Aba Ariaria Market', 'lat': 5.11, 'lon': 7.37, 'state': 'Abia'},
    {'name': 'Port Harcourt Mile 3 Market', 'lat': 4.82, 'lon': 7.02, 'state': 'Rivers'},
    {'name': 'Calabar Watt Market', 'lat': 4.95, 'lon': 8.32, 'state': 'Cross River'},
    {'name': 'Uyo Itam Market', 'lat': 5.03, 'lon': 7.92, 'state': 'Akwa Ibom'},
  ];

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
      final state = await _reverseGeocode(position.latitude, position.longitude);
      await _saveToCache(state, position.latitude, position.longitude);
      setState(() {
        _userPosition = position;
        _detectedState = state;
        _isFromCache = false;
        _loading = false;
      });
    } catch (e) {
      final loadedCache = await _loadFromCache();
      if (!loadedCache) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveToCache(String state, double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_market_state', state);
    await prefs.setDouble('cached_market_lat', lat);
    await prefs.setDouble('cached_market_lon', lon);
    await prefs.setString('cached_market_time', DateTime.now().toIso8601String());
  }

  Future<bool> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getString('cached_market_state');
    final lat = prefs.getDouble('cached_market_lat');
    final lon = prefs.getDouble('cached_market_lon');
    final time = prefs.getString('cached_market_time');

    if (state != null && lat != null && lon != null) {
      setState(() {
        _detectedState = state;
        _userPosition = Position(
          latitude: lat,
          longitude: lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
        _isFromCache = true;
        _lastUpdated = time;
        _loading = false;
      });
      return true;
    }
    return false;
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

  Future<String> _reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'SmartFarmNigeriaApp/1.0'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['address'];
      final state = address['state'] ?? '';
      return state.toString().replaceAll(' State', '').trim();
    } else {
      throw 'Could not detect your location.';
    }
  }

  Map<String, int>? get _matchedPrices {
    if (_regionalPrices.containsKey(_detectedState)) {
      return _regionalPrices[_detectedState];
    }
    return null;
  }

  List<Map<String, dynamic>> get _sortedNearbyMarkets {
    if (_userPosition == null) return [];

    final withDistance = _knownMarkets.map((market) {
      final distanceMeters = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        market['lat'],
        market['lon'],
      );
      return {
        ...market,
        'distanceKm': (distanceMeters / 1000),
      };
    }).toList();

    withDistance.sort((a, b) => a['distanceKm'].compareTo(b['distanceKm']));
    return withDistance.take(5).toList();
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _priceRange(int basePrice) {
    final low = (basePrice * 0.97).round();
    final high = (basePrice * 1.03).round();
    return '₦${_formatNumber(low)} - ₦${_formatNumber(high)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
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
                          const Icon(Icons.location_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _init,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final prices = _matchedPrices;
    final nearby = _sortedNearbyMarkets;

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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[700]!, Colors.green[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detectedState.isNotEmpty ? '$_detectedState State' : 'Location detected',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Prices are regional estimates, updated periodically',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (prices == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[500], size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'No price data available for your state yet.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else ...[
          const Text('Crop Prices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...prices.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      entry.key[0],
                      style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Text('per 100kg bag', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                    _priceRange(entry.value),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 24),
        const Text('Nearby Markets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (nearby.isEmpty)
          const Text('No market data nearby yet.')
        else
          ...nearby.map((market) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, color: Colors.brown),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(market['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '${(market['distanceKm'] as double).toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}