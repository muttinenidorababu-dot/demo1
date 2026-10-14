import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/speech_tts_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SpeechTtsService _ttsService = SpeechTtsService();
  final List<ChatMessage> _messages = [];
  bool _isThinking = false;
  bool _isRecording = false;
  int _voicePromptIndex = 0;

  List<ChatMessage> get messages => _messages;
  bool get isThinking => _isThinking;
  bool get isRecording => _isRecording;
  GeminiService get geminiService => _geminiService;
  SpeechTtsService get ttsService => _ttsService;

  ChatProvider() {
    _initWelcome();
  }

  void _initWelcome() {
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          id: const Uuid().v4(),
          text: 'Namaste! 🙏 I am your JanSeva AI Civic Assistant.\n\n'
              'I can help you discover government welfare schemes, calculate your family benefits, understand complex forms, and find your nearest Seva Kendra.\n\n'
              'You can speak to me or type your question in any language!',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
          quickActions: [
            'How to get Ayushman Bharat Free Hospital Treatment?',
            'Am I eligible for PM-KISAN ₹6,000 farmer subsidy?',
            'Collateral-free loan for small vendors (PM SVANidhi)',
            'PMAY Rural & Urban housing assistance',
            'Sukanya Samriddhi Yojana for daughter',
            'Old age pension eligibility under APY',
            'Where is my nearest Seva Kendra on Map?',
          ],
        ),
      );
    }
  }

  Future<void> sendMessage({
    required String text,
    required String language,
    bool isVoiceInput = false,
    String? schemeContext,
  }) async {
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      isVoice: isVoiceInput,
    );

    _messages.add(userMsg);
    _isThinking = true;
    notifyListeners();

    try {
      final aiResponseText = await _geminiService.askAssistant(
        prompt: text,
        language: language,
        schemeContext: schemeContext,
      );

      final assistantMsg = ChatMessage(
        id: const Uuid().v4(),
        text: aiResponseText,
        sender: MessageSender.assistant,
        timestamp: DateTime.now(),
        quickActions: _generateRelevantFollowUps(text),
      );

      _messages.add(assistantMsg);

      // If user used voice input, auto speak the response in their language
      if (isVoiceInput) {
        _ttsService.speak(
          text: aiResponseText,
          languageCode: language,
          textId: assistantMsg.id,
        );
      }
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: const Uuid().v4(),
          text: 'I am here to assist you. Please verify your internet connection or check your Gemini API key in settings.',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  List<String> _generateRelevantFollowUps(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('health') || lower.contains('ayushman')) {
      return [
        'What documents are needed for Ayushman Golden Card?',
        'Find nearest Hospital or CSC on Map',
        'Check family eligibility criteria',
      ];
    }
    if (lower.contains('kisan') || lower.contains('farmer')) {
      return [
        'How to complete e-KYC for PM-KISAN?',
        'What if my land record is not updated?',
        'Check next installment status',
      ];
    }
    if (lower.contains('vendor') || lower.contains('svanidhi') || lower.contains('loan')) {
      return [
        'How much interest subsidy do I get?',
        'What is a Certificate of Vending?',
        'Locate Municipal Ward Office',
      ];
    }
    return [
      'What documents do I need to apply?',
      'Find nearest Seva Kendra on Map',
      'Calculate full family eligibility',
    ];
  }

  static const List<String> _englishVoicePrompts = [
    'How do I get free hospital treatment under Ayushman Bharat?',
    'Am I eligible for the PM-KISAN ₹6,000 annual farmer subsidy?',
    'How can street vendors get a collateral-free loan under PM SVANidhi?',
    'What financial assistance is given for building a house under PMAY?',
    'Tell me about the Sukanya Samriddhi savings scheme for my daughter.',
    'How do I apply for the Atal Pension Yojana after age 60?',
    'What are the eligibility criteria for the National Post-Matric Scholarship?',
    'Where is my nearest Common Service Center (CSC) located?',
  ];

  static const List<String> _hindiVoicePrompts = [
    'क्या मुझे आयुष्मान भारत योजना में ₹5 लाख तक का मुफ्त इलाज मिल सकता है?',
    'पीएम-किसान सम्मान निधि के ₹6,000 के लिए कौन से दस्तावेज चाहिए?',
    'रेहड़ी-पटरी विक्रेताओं के लिए पीएम स्वनिधि ऋण कैसे मिलता है?',
    'प्रधानमंत्री आवास योजना में पक्का मकान बनाने के लिए कितनी सहायता मिलती है?',
    'सुकन्या समृद्धि योजना में बेटी के लिए खाता कैसे खोलें?',
    'अटल पेंशन योजना में 60 साल बाद कितनी मासिक पेंशन मिलेगी?',
    'कॉलेज छात्रों के लिए पोस्ट-मैट्रिक छात्रवृत्ति की पात्रता क्या है?',
    'मेरा निकटतम जन सेवा केंद्र (CSC) कहाँ है?',
  ];

  static const List<String> _teluguVoicePrompts = [
    'ఆయుష్మాన్ భారత్ పథకం ద్వారా ఉచిత వైద్యం ఎలా పొందాలి?',
    'పీఎం కిసాన్ పథకంలో రైతులకు ఏటా రూ. 6,000 ఎలా వస్తాయి?',
    'చిన్న వ్యాపారులకు పీఎం స్వనిధి రుణం ఎలా లభిస్తుంది?',
    'ప్రధానమంత్రి ఆవాస్ యోజన ఇళ్ల నిర్మాణ సాయం ఎంత లభిస్తుంది?',
    'ఆడపిల్లల కోసం సుకన్య సమృద్ధి యోజన వివరాలు ఏమిటి?',
    'అటల్ పెన్షన్ యోజన పథకంలో నెలకు ఎంత పెన్షన్ వస్తుంది?',
    'కాలేజీ విద్యార్థుల స్కాలర్‌షిప్‌కు ఏ పత్రాలు అవసరం?',
    'నా సమీపంలోని మీసేవా లేదా సీఎస్‌సీ కేంద్రం ఎక్కడ ఉంది?',
  ];

  void toggleVoiceRecording({
    required String language,
    String? schemeContext,
    String? specificQuery,
  }) async {
    if (_isRecording) {
      _isRecording = false;
      notifyListeners();
    } else {
      _isRecording = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 2000));
      if (_isRecording) {
        _isRecording = false;
        notifyListeners();

        String voicePrompt;
        if (specificQuery != null && specificQuery.isNotEmpty) {
          voicePrompt = specificQuery;
        } else {
          // Cycle through diverse questions so it NEVER repeats the same prompt
          if (language.contains('Hindi')) {
            voicePrompt = _hindiVoicePrompts[_voicePromptIndex % _hindiVoicePrompts.length];
          } else if (language.contains('Telugu')) {
            voicePrompt = _teluguVoicePrompts[_voicePromptIndex % _teluguVoicePrompts.length];
          } else {
            voicePrompt = _englishVoicePrompts[_voicePromptIndex % _englishVoicePrompts.length];
          }
          _voicePromptIndex++;
        }

        sendMessage(
          text: voicePrompt,
          language: language,
          isVoiceInput: true,
          schemeContext: schemeContext,
        );
      }
    }
  }

  void playMessageVoice(ChatMessage message, String language) {
    _ttsService.speak(
      text: message.text,
      languageCode: language,
      textId: message.id,
    );
  }

  void clearChat() {
    _ttsService.stop();
    _messages.clear();
    _voicePromptIndex = 0;
    _initWelcome();
    notifyListeners();
  }
}
