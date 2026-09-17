import 'package:flutter/material.dart';
import 'photo_screen.dart';
import 'translations.dart';

class DiagnoseScreen extends StatelessWidget {
  final String languageCode;
  const DiagnoseScreen({super.key, required this.languageCode});

  String t(String key) => Translations.get(key, languageCode);

  List<Map<String, dynamic>> get crops => [
    {'key': 'maize', 'icon': Icons.grass},
    {'key': 'rice', 'icon': Icons.grain},
    {'key': 'groundnut', 'icon': Icons.eco},
    {'key': 'beans', 'icon': Icons.spa},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('diagnose_crop')),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t('select_crop'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  final cropName = t(crop['key']);
                  return Card(
                    elevation: 3,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoScreen(
                              cropName: cropName,
                              languageCode: languageCode,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(crop['icon'], size: 48, color: Colors.green[800]),
                          const SizedBox(height: 8),
                          Text(cropName, style: const TextStyle(fontSize: 16)),
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