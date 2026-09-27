import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:typed_data';
import 'translations.dart';
import 'maize_classifier.dart';
import 'beans_classifier.dart';
import 'groundnut_classifier.dart';
import 'rice_classifier.dart';
import 'gemini_service.dart';

class PhotoScreen extends StatefulWidget {
  final String cropName; // 'maize', 'rice', 'groundnut', 'beans'
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

  String get _cropDisplayName => t(widget.cropName);

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
    'Leaf Blast': {
      'symptoms': 'Diamond-shaped grey-white lesions with brown borders on leaves.',
      'treatment': 'Apply fungicide promptly. Avoid excess nitrogen fertilizer.',
    },
    'Leaf scald': {
      'symptoms': 'Alternating light tan and reddish-brown bands running from leaf tip inward, giving a scalded look.',
      'treatment': 'Use resistant varieties, avoid drought stress, and apply fungicide if severe.',
    },
    'Sheath Blight': {
      'symptoms': 'Greyish-green, oval lesions on the leaf sheath near the waterline, spreading upward.',
      'treatment': 'Reduce planting density, avoid excess nitrogen, and apply fungicide at early tillering if detected.',
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
      'symptoms': 'Dark brown to black circular spots on leaves, often surrounded by yellow halos.',
      'treatment': 'Apply recommended fungicides, remove infected plant debris, and practice crop rotation.',
    },
    'LEAF SPOT (EARLY AND LATE)': {
      'symptoms': 'Brown to dark lesions on leaves that may enlarge and cause premature leaf drop.',
      'treatment': 'Apply fungicide early, improve field sanitation, and avoid overcrowding plants.',
    },
    'ROSETTE': {
      'symptoms': 'Stunted growth, yellowing, and rosette-like clustering of leaves.',
      'treatment': 'Remove infected plants and control aphids, which spread the disease.',
    },
    'RUST': {
      'symptoms': 'Small orange-brown pustules on leaf surfaces that release powdery spores.',
      'treatment': 'Apply fungicide when necessary and use resistant groundnut varieties.',
    },
    'Unclear Image': {
      'symptoms': 'The image is too unclear or does not show a leaf of the specified crop.',
      'treatment': 'Retake the photo ensuring a single leaf fills most of the frame, in good lighting.',
    },'angular_leaf_spot': {
    'symptoms': 'Angular brown spots bound by leaf veins.',
    'treatment': 'Rotate crops, use resistant varieties, apply fungicide during humid periods.',
    },
  'bean_rust': {
    'symptoms': 'Small reddish-brown pustules on leaf surfaces, often with a yellow halo.',
    'treatment': 'Apply fungicide at first sign of pustules. Remove and destroy heavily infected leaves.',
},
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
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      bool onlineSucceeded = false;

      if (isOnline) {
        // Try Gemini first. If it fails for any reason (overload, timeout,
        // bad response), fall through to the offline trained model instead
        // of showing a raw error to the user.
        try {
          final result = await GeminiService.diagnose(
            imageBytes: _selectedImageBytes!,
            cropName: widget.cropName,
          );

          final condition = result['condition'] as String? ?? 'Unclear Image';
          onlineSucceeded = true;

          if (condition == 'Unclear Image') {
            _showLowConfidenceDialog();
          } else {
            _showDiagnosisDialog(
              condition: condition,
              confidence: (result['confidence'] as num?)?.toDouble(),
              isReal: true,
              source: 'online',
              onlineSymptoms: result['symptoms'] as String?,
              onlineTreatment: result['treatment'] as String?,
            );
          }
        } catch (e) {
          onlineSucceeded = false; // fall through to offline below
        }
      }

      if (!onlineSucceeded) {
        // OFFLINE (or online failed): use trained model where available
        if (widget.cropName == 'maize') {
          final result = await MaizeClassifier.classify(_selectedImageBytes!);
          if (result['label'] == 'NOT GROUDNUT LEAF') {
            _showLowConfidenceDialog();
          } else {
            _showDiagnosisDialog(
              condition: result['label'],
              confidence: result['confidence'],
              isReal: true,
              source: 'offline',
            );
          }
        } else if (widget.cropName == 'groundnut') {
          final result = await GroundnutClassifier.classify(_selectedImageBytes!);
          if (result['label'] == 'NOT GROUDNUT LEAF') {
            _showLowConfidenceDialog();
          } else {
            _showDiagnosisDialog(
              condition: result['label'],
              confidence: result['confidence'],
              isReal: true,
              source: 'offline',
            );
          }
        } else if (widget.cropName == 'rice') {
          final result = await RiceClassifier.classify(_selectedImageBytes!);
          if (result['label'] == 'Non Rice Leaf') {
            _showLowConfidenceDialog();
          } else {
            _showDiagnosisDialog(
              condition: result['label'],
              confidence: result['confidence'],
              isReal: true,
              source: 'offline',
            );
          }
               } else if (widget.cropName == 'beans') {
          final result = await BeansClassifier.classify(_selectedImageBytes!);
          if (result['label'] == 'Non Beans Leaf') {
            _showLowConfidenceDialog();
          } else {
            _showDiagnosisDialog(
              condition: result['label'],
              confidence: result['confidence'],
              isReal: true,
              source: 'offline',
            );
          }
        }
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
          'This image doesn\'t clearly show a ${_cropDisplayName.toLowerCase()} leaf, or the photo is unclear. '
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
    required String source, // 'online' or 'offline'
    String? onlineSymptoms,
    String? onlineTreatment,
  }) {
    final isHealthy = condition.toUpperCase().contains('HEALTHY');
    final info = _treatmentInfo[condition];
    final displayCondition = condition.replaceAll('_', ' ');

    // Prefer Gemini's own symptoms/treatment text when diagnosed online,
    // since its disease names won't always match the local _treatmentInfo map.
    final symptomsText = source == 'online' ? onlineSymptoms : info?['symptoms'];
    final treatmentText = source == 'online' ? onlineTreatment : info?['treatment'];

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
                '$_cropDisplayName: $displayCondition',
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
              const SizedBox(height: 4),
              Text(
                source == 'online' ? 'Diagnosed online' : 'Diagnosed offline',
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              if (!isHealthy && symptomsText != null) ...[
                const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(symptomsText),
                const SizedBox(height: 12),
              ],
              if (!isHealthy && treatmentText != null) ...[
                const Text('Recommended Treatment:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(treatmentText),
                const SizedBox(height: 12),
              ],
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
        title: Text('$_cropDisplayName ${t('diagnose_crop')}'),
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