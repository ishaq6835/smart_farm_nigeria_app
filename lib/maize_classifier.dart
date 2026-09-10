import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MaizeClassifier {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  static const int _inputSize = 224;

  static Future<void> loadModel() async {
    if (_interpreter != null) return;

    _interpreter = await Interpreter.fromAsset(
      'assets/models/model_unquant.tflite',
    );

    final labelsData = await rootBundle.loadString('assets/models/labels.txt');
    _labels = labelsData
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
          final parts = line.trim().split(' ');
          return parts.length > 1 ? parts.sublist(1).join(' ') : line.trim();
        })
        .toList();
  }

  static Future<Map<String, dynamic>> classify(Uint8List imageBytes) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw 'Could not decode image';
    }

    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );

    final output = List.generate(1, (_) => List.filled(_labels!.length, 0.0));

    _interpreter!.run(input, output);

    final scores = output[0];
    double maxScore = -1;
    int maxIndex = 0;
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    return {
      'label': _labels![maxIndex],
      'confidence': maxScore,
    };
  }
}

