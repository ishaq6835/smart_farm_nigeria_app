import 'photo_screen.dart';
import 'package:flutter/material.dart';

class DiagnoseScreen extends StatelessWidget {
  const DiagnoseScreen({super.key});

  final List<Map<String, dynamic>> crops = const [
    {'name': 'Maize', 'icon': Icons.grass},
    {'name': 'Rice', 'icon': Icons.grain},
    {'name': 'Groundnut', 'icon': Icons.eco},
    {'name': 'Beans', 'icon': Icons.spa},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnose Crop'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your crop:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return Card(
                    elevation: 3,
                    child: InkWell(
                     onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PhotoScreen(cropName: crop['name']),
    ),
  );
},
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(crop['icon'], size: 48, color: Colors.green[800]),
                          const SizedBox(height: 8),
                          Text(crop['name'], style: const TextStyle(fontSize: 16)),
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