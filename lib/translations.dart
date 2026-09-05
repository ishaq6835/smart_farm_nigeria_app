class Translations {
  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_title': 'Smart Farm Nigeria',
      'welcome': 'Welcome, Farmer!',
      'diagnose_crop': 'Diagnose Crop',
      'weather_soil': 'Weather & Soil',
      'market_prices': 'Market Prices',
      'how_to_use': 'How to Use',
      'select_crop': 'Select your crop:',
      'maize': 'Maize',
      'rice': 'Rice',
      'groundnut': 'Groundnut',
      'beans': 'Beans',
      'take_photo': 'Take or upload a photo of the affected leaf',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'analyze': 'Analyze',
      'diagnosis_result': 'Diagnosis Result',
      'looks_healthy': 'looks healthy',
      'placeholder_note': '(This is a placeholder result - real AI diagnosis coming soon.)',
    },
    'ha': {
      'app_title': 'Gonar Zamani ta Najeriya',
      'welcome': 'Barka da zuwa, Manomi!',
      'diagnose_crop': 'Duba Cutar Amfanin Gona',
      'weather_soil': 'Yanayi da Kasa',
      'market_prices': 'Farashin Kasuwa',
      'how_to_use': 'Yadda Ake Amfani',
      'select_crop': 'Zabi amfanin gonarka:',
      'maize': 'Masara',
      'rice': 'Shinkafa',
      'groundnut': 'Gyada',
      'beans': 'Wake',
      'take_photo': 'Dauki ko loda hoton ganyen da abin ya shafa',
      'camera': 'Kamara',
      'gallery': 'Hoto',
      'analyze': 'Duba',
      'diagnosis_result': 'Sakamakon Bincike',
      'looks_healthy': 'yana da lafiya',
      'placeholder_note': '(Wannan misali ne kawai - ainihin bincike na AI zai zo nan gaba.)',
    },
  };

  static String get(String key, String languageCode) {
    return _strings[languageCode]?[key] ?? _strings['en']![key] ?? key;
  }
}
