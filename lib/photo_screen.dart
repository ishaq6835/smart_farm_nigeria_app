import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:math';
import 'translations.dart';
import 'maize_classifier.dart';
import 'groundnut_classifier.dart';

class PhotoScreen extends StatefulWidget {
  final String cropName;
  final String languageCode;
  const PhotoScreen({super.key, required this.cropName, required this.languageCode});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _analyzing = false;

  String t(String key) => Translations.get(key, widget.languageCode);

  final Map<String, Map<String, String>> _treatmentInfo = {
    'Healthy': {
      'symptoms': 'No visible signs of disease or pest damage.',
      'treatment': 'Continue regular monitoring and proper field practices.',
    },
    'Blight': {
      'symptoms': 'Long, grey-green, cigar-shaped lesions on the leaves.',
      'treatment': 'Apply fungicide at first sign of lesions. Use resistant varieties and rotate with non-host crops.',
    },
    'Common_Rust': {
      'symptoms': 'Small reddish-brown pustules scattered across both leaf surfaces.',
      'treatment': 'Apply fungicide if severe. Plant rust-resistant maize varieties where available.',
    },
    'Gray_Leaf_Spot': {
      'symptoms': 'Rectangular grey to tan lesions running parallel to leaf veins.',
      'treatment': 'Rotate crops, avoid dense planting, and apply fungicide if infection is heavy.',
    },
    'Maize Streak Virus': {
      'symptoms': 'Pale yellow streaks running parallel along the leaf veins.',
      'treatment': 'Remove and destroy infected plants. Control leafhopper vectors with appropriate insecticide.',
    },
    'Fall Armyworm Damage': {
      'symptoms': 'Ragged holes in leaves, especially in the whorl, with visible larvae.',
      'treatment': 'Apply approved insecticide early morning or evening. Handpick larvae where practical.',
    },
    'Rice Blast': {
      'symptoms': 'Diamond-shaped grey-white lesions with brown borders on leaves.',
      'treatment': 'Apply fungicide promptly. Avoid excess nitrogen fertilizer.',
    },
    'Bacterial Leaf Blight': {
      'symptoms': 'Water-soaked streaks that turn yellow to white along leaf edges.',
      'treatment': 'Use disease-free seeds. Avoid excess nitrogen. Improve field drainage.',
    },
    'Brown Spot': {
      'symptoms': 'Small circular brown spots scattered across the leaf surface.',
      'treatment': 'Improve soil fertility, especially potassium levels. Apply fungicide if severe.',
    },
    'Groundnut Rosette Disease': {
      'symptoms': 'Stunted growth with mottled yellow-green leaves.',
      'treatment': 'Remove infected plants early. Control aphid vectors.',
    },
    'Early Leaf Spot': {
      'symptoms': 'Small dark brown circular spots with a yellow halo on leaves.',
      'treatment': 'Apply fungicide at first sign of spots. Rotate crops.',
    },
    'Late Leaf Spot': {
      'symptoms': 'Darker, more angular spots than early leaf spot.',
      'treatment': 'Apply fungicide regularly during wet season.',
    },
    'Bean Anthracnose': {
      'symptoms': 'Dark sunken lesions on pods and stems, often with pink spore masses.',
      'treatment': 'Use certified disease-free seeds. Apply fungicide if detected early.',
    },
    'Angular Leaf Spot': {
      'symptoms': 'Angular brown spots bound by leaf veins.',
      'treatment': 'Rotate crops, use resistant varieties, apply fungicide during humid periods.',
    },
    'Bean Common Mosaic Virus': {
      'symptoms': 'Mottled light and dark green pattern on leaves, with leaf curling.',
      'treatment': 'Remove infected plants immediately. Control aphid vectors.',
    },
    'ALTERNARIA LEAF SPOT': {
  'symptoms':
      'Dark brown to black circular spots on leaves, often surrounded by yellow halos.',
  'treatment':
      'Apply recommended fungicides, remove infected plant debris, and practice crop rotation.',
},

'LEAF SPOT (EARLY AND LATE)': {
  'symptoms':
      'Brown to dark lesions on leaves that may enlarge and cause premature leaf drop.',
  'treatment':
      'Apply fungicide early, improve field sanitation, and avoid overcrowding plants.',
},

'ROSETTE': {
  'symptoms':
      'Stunted growth, yellowing, and rosette-like clustering of leaves.',
  'treatment':
      'Remove infected plants and control aphids, which spread the disease.',
},

'RUST': {
  'symptoms':
      'Small orange-brown pustules on leaf surfaces that release powdery spores.',
  'treatment':
      'Apply fungicide when necessary and use resistant groundnut varieties.',
},
  };

  final Map<String, List<String>> _placeholderConditions = {
    'Rice': ['Healthy', 'Rice Blast', 'Bacterial Leaf Blight', 'Brown Spot'],
    'Groundnut': ['Healthy', 'Groundnut Rosette Disease', 'Early Leaf Spot', 'Late Leaf Spot'],
    'Beans': ['Healthy', 'Bean Anthracnose', 'Angular Leaf Spot', 'Bean Common Mosaic Virus'],
  };

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _analyze() async {
    setState(() => _analyzing = true);

    try {
      if (widget.cropName == 'Maize') {
  final result =
      await MaizeClassifier.classify(
        _selectedImageBytes!,
      );

  if (result['label'] == 'NOT GROUDNUT LEAF') {
    _showLowConfidenceDialog();
  } else {
    _showDiagnosisDialog(
      condition: result['label'],
      confidence: result['confidence'],
      isReal: true,
    );
  }
}
else if (widget.cropName == 'Groundnut') {
  final result =
      await GroundnutClassifier.classify(
        _selectedImageBytes!,
      );
if (result['label'] == 'NOT GROUDNUT LEAF') {
    _showLowConfidenceDialog();
  } else {
    _showDiagnosisDialog(
      condition: result['label'],
      confidence: result['confidence'],
      isReal: true,
    );
  }
}
else {
        final options = _placeholderConditions[widget.cropName] ?? ['Healthy'];
        final random = Random();
        final condition = options[random.nextInt(options.length)];
        _showDiagnosisDialog(condition: condition, confidence: null, isReal: false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _showLowConfidenceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unable to Diagnose'),
              content: Text(
        'This image doesn\'t clearly show a ${widget.cropName.toLowerCase()} leaf, or the photo is unclear. '
        'Please retake the photo with a single leaf filling most of the frame, in good lighting.',
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDiagnosisDialog({
    required String condition,
    double? confidence,
    required bool isReal,
  }) {
    final isHealthy =
    condition.toUpperCase() == 'HEALTHY';
    final info = _treatmentInfo[condition];
    final displayCondition = condition.replaceAll('_', ' ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isHealthy ? Icons.check_circle : Icons.warning_amber_rounded,
              color: isHealthy ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(t('diagnosis_result'))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.cropName}: $displayCondition',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isHealthy ? Colors.green[800] : Colors.orange[800],
                ),
              ),
              if (isReal && confidence != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              if (!isHealthy && info != null) ...[
                const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(info['symptoms']!),
                const SizedBox(height: 12),
                const Text('Recommended Treatment:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(info['treatment']!),
                const SizedBox(height: 12),
              ],
              if (!isReal)
                Text(
                  t('placeholder_note'),
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cropName} ${t('diagnose_crop')}'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              t('take_photo'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImageBytes == null
                    ? const Center(child: Text('No image selected'))
                    : Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(t('camera')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: Text(t('gallery')),
                  ),
                ),
              ],
            ),
            if (_selectedImageBytes != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _analyzing ? null : _analyze,
                  icon: _analyzing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search),
                  label: Text(_analyzing ? 'Analyzing...' : t('analyze')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}