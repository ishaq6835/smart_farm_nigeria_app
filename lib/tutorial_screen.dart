import 'package:flutter/material.dart';
import 'diagnose_screen.dart';
import 'weather_screen.dart';
import 'market_screen.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  late final List<Map<String, dynamic>> steps = [
    {
      'icon': Icons.camera_alt,
      'color': Colors.green,
      'title': 'Diagnose Your Crop',
      'description': 'Pick your crop, snap a photo of the leaf, and get a quick health check.',
      'action': 'Try Diagnosis',
            'screen': const DiagnoseScreen(languageCode: 'en'),
    },
    {
      'icon': Icons.cloud,
      'color': Colors.blue,
      'title': 'Check Weather & Soil',
      'description': 'See live weather and soil conditions for wherever you are right now.',
      'action': 'Try Weather & Soil',
      'screen': const WeatherScreen(),
    },
    {
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'title': 'View Market Prices',
      'description': 'See estimated crop prices for your state and the markets nearest to you.',
      'action': 'Try Market Prices',
      'screen': const MarketScreen(),
    },
    {
      'icon': Icons.wifi_off,
      'color': Colors.purple,
      'title': 'Works Offline Too',
      'description': 'Diagnosis works without internet. Weather and prices need internet only when you open them.',
      'action': null,
      'screen': null,
    },
  ];

  void _tryFeature(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('How to Use'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final color = step['color'] as MaterialColor;

                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: color[100],
                        child: Icon(step['icon'] as IconData, size: 56, color: color[800]),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        step['title'] as String,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step['description'] as String,
                        style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      if (step['screen'] != null)
                        ElevatedButton.icon(
                          onPressed: () => _tryFeature(step['screen'] as Widget),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(step['action'] as String),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Page indicator dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.green[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Swipe to see more',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}