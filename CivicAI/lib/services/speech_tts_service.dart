import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VoicePersona {
  female,
  male,
  elderFriendly,
  standard,
}

class SpeechTtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String? _currentlySpeakingTextId;

  VoicePersona _selectedPersona = VoicePersona.female;
  double _pitch = 1.2;
  double _speechRate = 0.48;

  bool get isPlaying => _isPlaying;
  String? get currentlySpeakingTextId => _currentlySpeakingTextId;
  VoicePersona get selectedPersona => _selectedPersona;
  double get pitch => _pitch;
  double get speechRate => _speechRate;

  static const String _personaPrefKey = 'janseva_voice_persona';
  static const String _pitchPrefKey = 'janseva_voice_pitch';
  static const String _ratePrefKey = 'janseva_voice_rate';

  SpeechTtsService() {
    _initTts();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final personaStr = prefs.getString(_personaPrefKey);
    if (personaStr != null) {
      _selectedPersona = VoicePersona.values.firstWhere(
        (e) => e.name == personaStr,
        orElse: () => VoicePersona.female,
      );
    }
    _pitch = prefs.getDouble(_pitchPrefKey) ?? _getDefaultPitchForPersona(_selectedPersona);
    _speechRate = prefs.getDouble(_ratePrefKey) ?? _getDefaultRateForPersona(_selectedPersona);
    await _applyTtsSettings();
    notifyListeners();
  }

  void _initTts() {
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _currentlySpeakingTextId = null;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
      _currentlySpeakingTextId = null;
      notifyListeners();
    });

    _applyTtsSettings();
  }

  Future<void> _applyTtsSettings() async {
    try {
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_speechRate);
    } catch (_) {}
  }

  double _getDefaultPitchForPersona(VoicePersona persona) {
    switch (persona) {
      case VoicePersona.female:
        return 1.25;
      case VoicePersona.male:
        return 0.80;
      case VoicePersona.elderFriendly:
        return 1.05;
      case VoicePersona.standard:
        return 1.0;
    }
  }

  double _getDefaultRateForPersona(VoicePersona persona) {
    switch (persona) {
      case VoicePersona.female:
        return 0.48;
      case VoicePersona.male:
        return 0.50;
      case VoicePersona.elderFriendly:
        return 0.36; // Slower, clearer cadence for elderly citizens
      case VoicePersona.standard:
        return 0.50;
    }
  }

  Future<void> setPersona(VoicePersona persona) async {
    _selectedPersona = persona;
    _pitch = _getDefaultPitchForPersona(persona);
    _speechRate = _getDefaultRateForPersona(persona);

    await _applyTtsSettings();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_personaPrefKey, persona.name);
    await prefs.setDouble(_pitchPrefKey, _pitch);
    await prefs.setDouble(_ratePrefKey, _speechRate);
  }

  Future<void> setCustomPitch(double val) async {
    _pitch = val;
    await _flutterTts.setPitch(_pitch);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_pitchPrefKey, _pitch);
  }

  Future<void> setCustomSpeechRate(double val) async {
    _speechRate = val;
    await _flutterTts.setSpeechRate(_speechRate);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ratePrefKey, _speechRate);
  }

  Future<void> speak({
    required String text,
    String languageCode = 'en-US',
    String? textId,
  }) async {
    try {
      if (_isPlaying) {
        await stop();
        if (_currentlySpeakingTextId == textId) {
          return; // Toggle off
        }
      }

      _currentlySpeakingTextId = textId;
      final ttsLang = _mapLanguageToLocale(languageCode);
      await _flutterTts.setLanguage(ttsLang);
      await _applyTtsSettings();

      // Clean markdown symbols for cleaner TTS
      final cleanText = text
          .replaceAll(RegExp(r'\*\*|\*|#|`|---|\|'), ' ')
          .replaceAll(RegExp(r'\n+'), '. ');

      _isPlaying = true;
      notifyListeners();
      await _flutterTts.speak(cleanText);
    } catch (e) {
      _isPlaying = false;
      _currentlySpeakingTextId = null;
      notifyListeners();
    }
  }

  Future<void> previewCurrentVoice(String language) async {
    String sample = 'Namaste! I am your JanSeva AI Assistant. How may I assist you today?';
    if (language.contains('Hindi')) {
      sample = 'नमस्ते! मैं आपका जनसेवा एआई सहायक हूँ। मैं आपकी क्या मदद कर सकता हूँ?';
    } else if (language.contains('Telugu')) {
      sample = 'నమస్కారం! నేను మీ జనసేవ AI సహాయకుడిని. మీకు ఎలా సహాయపడగలను?';
    }
    await speak(text: sample, languageCode: language, textId: 'voice-preview');
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _currentlySpeakingTextId = null;
      notifyListeners();
    } catch (_) {}
  }

  String _mapLanguageToLocale(String lang) {
    switch (lang.toLowerCase()) {
      case 'hindi':
      case 'hi':
        return 'hi-IN';
      case 'telugu':
      case 'te':
        return 'te-IN';
      case 'tamil':
      case 'ta':
        return 'ta-IN';
      case 'marathi':
      case 'mr':
        return 'mr-IN';
      case 'bengali':
      case 'bn':
        return 'bn-IN';
      case 'kannada':
      case 'kn':
        return 'kn-IN';
      default:
        return 'en-US';
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
