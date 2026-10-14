import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _langPrefKey = 'janseva_app_language';

  String _currentLanguage = 'English';

  String get currentLanguage => _currentLanguage;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_langPrefKey);
    if (saved != null) {
      _currentLanguage = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageName) async {
    _currentLanguage = languageName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langPrefKey, languageName);
  }

  String translate(String key) {
    final Map<String, Map<String, String>> localizedStrings = {
      'app_title': {
        'English': 'JanSeva AI',
        'Hindi': 'जनसेवा एआई',
        'Telugu': 'జనసేవ AI',
        'Tamil': 'ஜன்சேவா AI',
        'Marathi': 'जनसेवा AI',
        'Bengali': 'জনসেবা AI',
        'Kannada': 'ಜನಸೇವಾ AI',
      },
      'app_tagline': {
        'English': 'Multilingual Voice AI for Government Schemes & Civic Rights',
        'Hindi': 'सरकारी योजनाओं एवं नागरिक अधिकारों के लिए बहुभाषी वॉयस एआई',
        'Telugu': 'ప్రభుత్వ సంక్షేమ పథకాలు & పౌర హక్కుల కోసం వాయిస్ AI',
        'Tamil': 'அரசு நலத்திட்டங்களுக்கான குரல் AI',
        'Marathi': 'शासकीय योजना आणि नागरी हक्कांसाठी व्हॉईस AI',
        'Bengali': 'সরকারি প্রকল্প ও নাগরিক অধিকারের জন্য ভয়েস AI',
        'Kannada': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು ಮತ್ತು ನಾಗರಿಕ ಹಕ್ಕುಗಳಿಗಾಗಿ ಧ್ವನಿ AI',
      },
      'check_eligibility': {
        'English': 'Check My Eligibility',
        'Hindi': 'मेरी पात्रता जांचें',
        'Telugu': 'నా అర్హతను తనిఖీ చేయండి',
        'Tamil': 'எனது தகுதியைச் சரிபார்க்கவும்',
        'Marathi': 'माझी पात्रता तपासा',
        'Bengali': 'আমার যোগ্যতা পরীক্ষা করুন',
        'Kannada': 'ನನ್ನ ಅರ್ಹತೆಯನ್ನು ಪರಿಶೀಲಿಸಿ',
      },
      'voice_assistant': {
        'English': 'Voice Assistant',
        'Hindi': 'वॉयस सहायक',
        'Telugu': 'వాయిస్ అసిస్టెంట్',
        'Tamil': 'குரல் உதவியாளர்',
        'Marathi': 'व्हॉईस असिस्टंट',
        'Bengali': 'ভয়েস সহকারী',
        'Kannada': 'ಧ್ವನಿ ಸಹಾಯಕ',
      },
      'find_kendra': {
        'English': 'Find Seva Kendra',
        'Hindi': 'सेवा केंद्र खोजें',
        'Telugu': 'సేవా కేంద్రాన్ని కనుగొనండి',
        'Tamil': 'சேவா மையத்தைக் கண்டறியவும்',
        'Marathi': 'सेवा केंद्र शोधा',
        'Bengali': 'সেবা কেন্দ্র খুঁজুন',
        'Kannada': 'ಸೇವಾ ಕೇಂದ್ರವನ್ನು ಹುಡುಕಿ',
      },
      'doc_simplifier': {
        'English': 'Doc Simplifier',
        'Hindi': 'दस्तावेज़ विश्लेषक',
        'Telugu': 'పత్రాల వివరణ',
        'Tamil': 'ஆவண எளிமைப்படுத்தல்',
        'Marathi': 'कागदपत्र विश्लेषण',
        'Bengali': 'নথি সহজীকরণ',
        'Kannada': 'ದಾಖಲೆ ಸರಳೀಕರಣ',
      },
      'my_applications': {
        'English': 'My Schemes',
        'Hindi': 'मेरी योजनाएं',
        'Telugu': 'నా పథకాలు',
        'Tamil': 'எனது திட்டங்கள்',
        'Marathi': 'माझ्या योजना',
        'Bengali': 'আমার প্রকল্পসমূহ',
        'Kannada': 'ನನ್ನ ಯೋಜನೆಗಳು',
      },
      'search_placeholder': {
        'English': 'Search schemes (e.g. Farmer, Health, Loan, Housing)...',
        'Hindi': 'योजनाएं खोजें (जैसे किसान, इलाज, ऋण, आवास)...',
        'Telugu': 'పథకాలను శోధించండి (ఉదా. రైతు, ఆరోగ్యం, రుణం)...',
        'Tamil': 'திட்டங்களைத் தேடுங்கள்...',
        'Marathi': 'योजना शोधा...',
        'Bengali': 'প্রকল্প অনুসন্ধান করুন...',
        'Kannada': 'ಯೋಜನೆಗಳನ್ನು ಹುಡುಕಿ...',
      },
    };

    final map = localizedStrings[key];
    if (map != null) {
      return map[_currentLanguage] ?? map['English'] ?? key;
    }
    return key;
  }
}
