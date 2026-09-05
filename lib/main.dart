import 'package:flutter/material.dart';
import 'diagnose_screen.dart';
import 'weather_screen.dart';
import 'market_screen.dart';
import 'tutorial_screen.dart';
import 'translations.dart';

void main() {
  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatefulWidget {
  const SmartFarmApp({super.key});

  @override
  State<SmartFarmApp> createState() => _SmartFarmAppState();
}

class _SmartFarmAppState extends State<SmartFarmApp> {
  String _languageCode = 'en';

  void _setLanguage(String code) {
    setState(() {
      _languageCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farm Nigeria',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: HomeScreen(
        languageCode: _languageCode,
        onLanguageChange: _setLanguage,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String languageCode;
  final Function(String) onLanguageChange;

  const HomeScreen({
    super.key,
    required this.languageCode,
    required this.onLanguageChange,
  });

  String t(String key) => Translations.get(key, languageCode);

  @override
  Widget build(BuildContext context) {
    final tiles = [
      {
        'label': t('diagnose_crop'),
        'icon': Icons.camera_alt,
        'color': Colors.green,
        'screen': DiagnoseScreen(languageCode: languageCode),
      },
      {
        'label': t('weather_soil'),
        'icon': Icons.cloud,
        'color': Colors.blue,
        'screen': const WeatherScreen(),
      },
      {
        'label': t('market_prices'),
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'screen': const MarketScreen(),
      },
      {
        'label': t('how_to_use'),
        'icon': Icons.help_outline,
        'color': Colors.purple,
        'screen': const TutorialScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(t('app_title')),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: onLanguageChange,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'ha', child: Text('Hausa')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('welcome'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  final color = tile['color'] as MaterialColor;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => tile['screen'] as Widget),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: color[100],
                            child: Icon(tile['icon'] as IconData, size: 28, color: color[800]),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              tile['label'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}