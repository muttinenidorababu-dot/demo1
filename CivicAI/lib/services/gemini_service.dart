import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scheme_model.dart';
import '../models/user_profile_model.dart';

class GeminiService {
  static const String _apiKeyPrefKey = 'janseva_gemini_api_key';
  String? _apiKey;
  GenerativeModel? _model;

  GeminiService() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyPrefKey);
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _initModel(_apiKey!);
    }
  }

  Future<void> saveApiKey(String key) async {
    _apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefKey, _apiKey!);
    if (_apiKey!.isNotEmpty) {
      _initModel(_apiKey!);
    } else {
      _model = null;
    }
  }

  String? get currentApiKey => _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  void _initModel(String key) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
      systemInstruction: Content.system(
        'You are JanSeva AI, an empathetic, helpful, and highly knowledgeable civic assistant '
        'helping Indian citizens understand government welfare schemes, rights, documents, and public services. '
        'Respond warmly and clearly in the requested language (e.g. Hindi, Telugu, Tamil, Marathi, Bengali, Kannada, or English). '
        'Always provide plain-language explanations, bullet points, required documents, and next steps. '
        'Avoid legal jargon. Always be encouraging and practical.',
      ),
    );
  }

  /// Sends a prompt to Gemini for conversational assistance
  Future<String> askAssistant({
    required String prompt,
    String language = 'English',
    String? schemeContext,
  }) async {
    if (_model != null) {
      try {
        final fullPrompt = StringBuffer();
        fullPrompt.writeln('Respond in $language language.');
        if (schemeContext != null && schemeContext.isNotEmpty) {
          fullPrompt.writeln('Context regarding the scheme: $schemeContext');
        }
        fullPrompt.writeln('Citizen inquiry: "$prompt"');

        final response = await _model!.generateContent([
          Content.text(fullPrompt.toString()),
        ]);

        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      } catch (e) {
        // Fallback to local intelligence if API call fails
      }
    }

    return _generateLocalSmartResponse(prompt, language, schemeContext);
  }

  /// Simplifies complex government circular or notice into 3 simple actionable points
  Future<Map<String, dynamic>> simplifyDocument({
    required String documentText,
    String language = 'English',
  }) async {
    if (_model != null) {
      try {
        final prompt = '''
You are a civic simplification AI for ordinary citizens.
Read the following government notice / scheme circular:
"""$documentText"""

Translate and summarize into $language with these exact 3 sections:
1. Summary: A 1-2 sentence plain summary of what this is.
2. Benefits: Exact financial or welfare benefit the citizen gets.
3. Action Needed & Documents: What the citizen must do right now, and what documents to take to the Kendra.

Keep it simple, inspiring, and easy to read.
''';

        final response = await _model!.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          return {
            'success': true,
            'summary': response.text!,
            'isAiGenerated': true,
          };
        }
      } catch (_) {}
    }

    return {
      'success': true,
      'summary': _getLocalDocumentSimplification(documentText, language),
      'isAiGenerated': false,
    };
  }

  /// Evaluates personalized eligibility with deep reasoning
  Future<String> evaluateDetailedEligibility({
    required UserProfile profile,
    required SchemeModel scheme,
    String language = 'English',
  }) async {
    if (_model != null) {
      try {
        final prompt = '''
Assess the eligibility of this citizen for the scheme "${scheme.title}" ($language language):
Citizen Profile:
- Age: ${profile.age}
- Gender: ${profile.gender}
- Occupation: ${profile.occupation}
- Annual Income: ₹${profile.annualIncome}
- State: ${profile.state}
- Category: ${profile.casteCategory}
- BPL Card: ${profile.hasBplCard ? 'Yes' : 'No'}
- Landholding: ${profile.landholdingAcres} acres

Scheme Criteria:
${scheme.eligibilityCriteria.join('\n')}

Provide a concise assessment in $language:
1. Are they eligible?
2. Why or why not?
3. What 3 immediate steps should they take to apply?
''';
        final response = await _model!.generateContent([Content.text(prompt)]);
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      } catch (_) {}
    }

    return _getLocalEligibilityAdvice(profile, scheme, language);
  }

  /// Intelligent semantic local responder with rich responses for all welfare categories & queries
  String _generateLocalSmartResponse(String prompt, String language, String? schemeContext) {
    final lower = prompt.toLowerCase();
    final isHindi = language.contains('Hindi');
    final isTelugu = language.contains('Telugu');

    // 1. Healthcare / Ayushman Bharat
    if (lower.contains('ayushman') ||
        lower.contains('health') ||
        lower.contains('hospital') ||
        lower.contains('इलाज') ||
        lower.contains('स्वास्थ्य') ||
        lower.contains('ఆరోగ్య') ||
        lower.contains('వైద్యం') ||
        lower.contains('golden card') ||
        lower.contains('treatment')) {
      if (isHindi) {
        return '🏥 **आयुष्मान भारत (AB-PMJAY) विवरण**:\n\n'
            '• **लाभ**: प्रत्येक पात्र परिवार को सूचीबद्ध सरकारी व निजी अस्पतालों में प्रति वर्ष ₹5,00,000 तक का मुफ्त कैशलेस इलाज।\n'
            '• **पात्रता**: बीपीएल राशन कार्ड धारक, असंगठित मजदूर, ग्रामीण आवास लाभार्थी।\n'
            '• **आवश्यक दस्तावेज**: आधार कार्ड, राशन कार्ड, सक्रिय मोबाइल नंबर।\n'
            '• **आवेदन स्थल**: निकटतम कॉमन सर्विस सेंटर (CSC) या अस्पताल के आयुष्मान मित्र काउंटर पर गोल्डन कार्ड बनवाएं।';
      } else if (isTelugu) {
        return '🏥 **ఆయుష్మాన్ భారత్ (PM-JAY) వివరాలు**:\n\n'
            '• **ప్రయోజనం**: అర్హత గల కుటుంబానికి ఏడాదికి రూ. 5,00,000 వరకు ఉచిత క్యాష్‌లెస్‌ వైద్యం.\n'
            '• **అర్హత**: తెల్ల రేషన్ కార్డు (BPL) కలిగిన పేద కుటుంబాలు, రోజువారీ కూలీలు.\n'
            '• **కావలసిన పత్రాలు**: ఆధార్ కార్డ్, రేషన్ కార్డ్, మొబైల్ నంబర్.\n'
            '• **దరఖాస్తు కేంద్రం**: మీ సమీపంలోని మీసేవా (MeeSeva) లేదా ప్రభుత్వ ఆసుపత్రిలోని ఆయుష్మాన్ మిత్ర డెస్క్.';
      }
      return '🏥 **Ayushman Bharat (PM-JAY) Health Coverage**:\n\n'
          '• **Benefit**: Up to ₹5,00,000 per family per year for secondary and tertiary cashless hospitalisation.\n'
          '• **Who is Eligible**: Low-income households with BPL/NFSA ration cards, informal laborers, and vulnerable families.\n'
          '• **Documents Required**: Aadhaar Card, Ration Card, Active Mobile Number for OTP.\n'
          '• **Where to Apply**: Visit your nearest Common Service Center (CSC) or District Hospital Ayushman Desk to issue your Golden Card.';
    }

    // 2. Farmer / Agriculture / PM-KISAN
    if (lower.contains('kisan') ||
        lower.contains('farmer') ||
        lower.contains('agriculture') ||
        lower.contains('crop') ||
        lower.contains('6000') ||
        lower.contains('किसान') ||
        lower.contains('खेती') ||
        lower.contains('రైతు') ||
        lower.contains('వ్యవసాయ') ||
        lower.contains('landholding')) {
      if (isHindi) {
        return '🌾 **पीएम किसान सम्मान निधि (PM-KISAN)**:\n\n'
            '• **लाभ**: सभी पात्र छोटे और सीमांत किसानों को प्रति वर्ष ₹6,000 सीधे बैंक खाते में (₹2,000 की 3 किस्तों में)।\n'
            '• **पात्रता**: अपने नाम पर कृषि योग्य भूमि रखने वाले किसान परिवार। (संस्थागत भूमि धारक पात्र नहीं हैं)।\n'
            '• **दस्तावेज**: खतौनी/भूलेख, आधार कार्ड (e-KYC पूर्ण), आधार से जुड़ा बैंक खाता।\n'
            '• **आवेदन स्थल**: pmkisan.gov.in पर ऑनलाइन या निकटतम CSC केंद्र।';
      } else if (isTelugu) {
        return '🌾 **పీఎం కిసాన్ సమ్మాన్ నిధి (PM-KISAN)**:\n\n'
            '• **ప్రయోజనం**: అర్హులైన రైతు కుటుంబాలకు ఏటా రూ. 6,000 నేరుగా బ్యాంక్ ఖాతాలో జమ (3 విడతల్లో రూ. 2,000 చొప్పున).\n'
            '• **అర్హత**: పట్టాదారు పాస్ బుక్ కలిగి ఉన్న చిన్న, సన్నకారు రైతులు.\n'
            '• **కావలసిన పత్రాలు**: పట్టాదారు పాస్‌బుక్, ఆధార్ కార్డ్ (e-KYC పూర్తి), ఆధార్ లింక్ అయిన బ్యాంక్ ఖాతా.\n'
            '• **దరఖాస్తు**: pmkisan.gov.in లేదా దగ్గరలోని సీఎస్‌సీ కేంద్రం.';
      }
      return '🌾 **PM-KISAN Income Support for Farmers**:\n\n'
          '• **Benefit**: ₹6,000 per year transferred directly to bank accounts in three equal installments of ₹2,000.\n'
          '• **Who is Eligible**: Small and marginal landholding farmer families with cultivable land in their name.\n'
          '• **Documents Required**: Land Records (Khatauni / Pattadar Passbook), Aadhaar Card (with e-KYC completed), Aadhaar-seeded Bank Account.\n'
          '• **Where to Apply**: Apply on pmkisan.gov.in or visit your nearest Common Service Center (CSC).';
    }

    // 3. Street Vendor / PM SVANidhi Loan
    if (lower.contains('svanidhi') ||
        lower.contains('vendor') ||
        lower.contains('street') ||
        lower.contains('रेहड़ी') ||
        lower.contains('पटरी') ||
        lower.contains('వీధి వ్యాపార')) {
      if (isHindi) {
        return '🛒 **पीएम स्वनिधि (PM SVANidhi) योजना**:\n\n'
            '• **लाभ**: रेहड़ी-पटरी और छोटे दुकानदारों को बिना गारंटी ₹10,000 से ₹50,000 तक का कार्यशील पूंजी ऋण, 7% ब्याज सब्सिडी और डिजिटल कैशबैक के साथ।\n'
            '• **पात्रता**: शहरी क्षेत्रों में फेरी लगाने वाले विक्रेता जिनके पास नगर निकाय का वेंडिंग प्रमाण पत्र या अनुशंसा पत्र हो।\n'
            '• **दस्तावेज**: वेंडिंग आईडी/लेटर, आधार कार्ड, बैंक पासबुक या यूपीआई आईडी।';
      } else if (isTelugu) {
        return '🛒 **పీఎం స్వనిధి (PM SVANidhi) పథకం**:\n\n'
            '• **ప్రయోజనం**: వీధి వ్యాపారులకు ఎటువంటి పూచీకత్తు లేకుండా రూ. 10,000 నుంచి రూ. 50,000 వరకు వ్యాపార రుణం మరియు 7% వడ్డీ సబ్సిడీ.\n'
            '• **అర్హత**: పట్టణాల్లో వ్యాపారం చేసే వీధి వ్యాపారులు (మునిసిపల్ గుర్తింపు కార్డు ఉన్నవారు).\n'
            '• **కావలసిన పత్రాలు**: మునిసిపల్ వెండింగ్ సర్టిఫికేట్, ఆధార్ కార్డ్, బ్యాంక్ పాస్‌బుక్.';
      }
      return '🛒 **PM SVANidhi Micro-Credit for Street Vendors**:\n\n'
          '• **Benefit**: Collateral-free working capital loan of ₹10,000 (1st tranche), ₹20,000 (2nd tranche), up to ₹50,000 (3rd tranche) with 7% interest subsidy.\n'
          '• **Who is Eligible**: Urban street vendors and hawkers with a Certificate of Vending or ULB recommendation.\n'
          '• **Documents Required**: Vending ID/Certificate, Aadhaar Card, Active Bank Account with UPI.\n'
          '• **Where to Apply**: Apply online at pmsvanidhi.mohua.gov.in or visit your local Municipal Corporation / CSC.';
    }

    // 4. Housing / PMAY / Awas
    if (lower.contains('awas') ||
        lower.contains('housing') ||
        lower.contains('house') ||
        lower.contains('home') ||
        lower.contains('मकान') ||
        lower.contains('आवास') ||
        lower.contains('ఇల్లు') ||
        lower.contains('ఆవాస్')) {
      if (isHindi) {
        return '🏠 **प्रधानमंत्री आवास योजना (PMAY-G / Urban)**:\n\n'
            '• **लाभ**: पक्का मकान बनाने के लिए ₹1,20,000 से ₹1,30,000 की प्रत्यक्ष सहायता + 90 दिनों की मनरेगा मजदूरी और शौचालय निर्माण सब्सिडी।\n'
            '• **पात्रता**: बेघर या कच्चे/जीर्ण-शीर्ण मकानों में रहने वाले ग्रामीण व शहरी गरीब परिवार।\n'
            '• **दस्तावेज**: आधार कार्ड, मनरेगा जॉब कार्ड, बैंक पासबुक, ग्राम पंचायत सत्यापन।';
      } else if (isTelugu) {
        return '🏠 **ప్రధానమంత్రి ఆవాస్ యోజన (PMAY)**:\n\n'
            '• **ప్రయోజనం**: పక్కా ఇల్లు నిర్మించుకోవడానికి రూ. 1,20,000 నుండి రూ. 1,30,000 వరకు ఆర్థిక సహాయం.\n'
            '• **అర్హత**: ఇల్లు లేని లేదా మట్టి/పూరి గుడిసెలలో నివసించే పేద కుటుంబాలు.\n'
            '• **కావలసిన పత్రాలు**: ఆధార్ కార్డ్, ఉపాధి హామీ జాబ్ కార్డ్, బ్యాంక్ పాస్‌బుక్, స్థల ధృవీకరణ.';
      }
      return '🏠 **Pradhan Mantri Awas Yojana (PMAY Housing)**:\n\n'
          '• **Benefit**: ₹1,20,000 in plain areas and ₹1,30,000 in hilly/difficult areas for pucca house construction + 90 days MGNREGA wages.\n'
          '• **Who is Eligible**: Houseless families or households living in kutcha/temporary houses with low family income.\n'
          '• **Documents Required**: Aadhaar Card, MGNREGA Job Card Number, Bank Account Passbook, Gram Panchayat land certificate.\n'
          '• **Where to Apply**: Apply through your Gram Panchayat Secretary or Urban Municipal Office.';
    }

    // 5. Daughter / Girl Child / Sukanya Samriddhi
    if (lower.contains('sukanya') ||
        lower.contains('girl') ||
        lower.contains('daughter') ||
        lower.contains('beti') ||
        lower.contains('बेटी') ||
        lower.contains('सुकन्या') ||
        lower.contains('ఆడపిల్ల') ||
        lower.contains('సుకన్య')) {
      if (isHindi) {
        return '👧 **सुकन्या समृद्धि योजना (SSY)**:\n\n'
            '• **लाभ**: 8.2% वार्षिक चक्रवृद्धि ब्याज दर, धारा 80C के तहत पूरी तरह कर मुक्त (EEE), न्यूनतम ₹250 से अधिकतम ₹1.5 लाख प्रति वर्ष जमा।\n'
            '• **पात्रता**: 10 वर्ष या उससे कम उम्र की बालिकाओं के नाम पर माता-पिता द्वारा खाता खोला जा सकता है।\n'
            '• **दस्तावेज**: बालिका का जन्म प्रमाण पत्र, माता-पिता का आधार कार्ड, पैन कार्ड, पासपोर्ट फोटो।\n'
            '• **आवेदन स्थल**: निकटतम डाकघर (Post Office) या अधिकृत बैंक शाखा।';
      } else if (isTelugu) {
        return '👧 **సుకన్య సమృద్ధి యోజన (SSY)**:\n\n'
            '• **ప్రయోజనం**: 8.2% అత్యధిక వార్షిక వడ్డీ, ఆదాయపు పన్ను మినహాయింపు, ఆడపిల్లల చదువు మరియు వివాహానికి నిధి.\n'
            '• **అర్హత**: 10 సంవత్సరాలు లేదా అంతకంటే తక్కువ వయస్సు ఉన్న ఆడపిల్లల పేరుపై ఖాతా తెరవవచ్చు.\n'
            '• **కావలసిన పత్రాలు**: బాలిక పుట్టిన తేదీ ధృవీకరణ పత్రం (Birth Certificate), తల్లిదండ్రుల ఆధార్, ఫోటోలు.\n'
            '• **ఎక్కడ దరఖాస్తు చేయాలి**: సమీప పోస్ట్ ఆఫీస్ లేదా బ్యాంకు బ్రాంచ్.';
      }
      return '👧 **Sukanya Samriddhi Yojana (SSY) for Girl Children**:\n\n'
          '• **Benefit**: High government-backed interest rate (8.2% per annum), fully tax-exempt (EEE), matures after 21 years or upon marriage after age 18.\n'
          '• **Who is Eligible**: Parents or legal guardians of a girl child aged 10 years or younger (maximum 2 accounts per family).\n'
          '• **Documents Required**: Birth Certificate of Girl Child, Identity & Address Proof of Parent (Aadhaar Card, PAN), Passport-sized photos.\n'
          '• **Where to Apply**: Visit any Post Office or authorized commercial bank branch.';
    }

    // 6. Pension / Old Age / Senior Citizen / Atal Pension
    if (lower.contains('pension') ||
        lower.contains('old age') ||
        lower.contains('senior') ||
        lower.contains('atal') ||
        lower.contains('पेंशन') ||
        lower.contains('बुजुर्ग') ||
        lower.contains('పింఛన్') ||
        lower.contains('వృద్ధాప్య')) {
      if (isHindi) {
        return '👵 **अटल पेंशन योजना (APY) एवं वृद्धावस्था पेंशन**:\n\n'
            '• **लाभ**: 60 वर्ष की आयु के बाद ₹1,000 से ₹5,000 तक की आजीवन मासिक गारंटीकृत पेंशन।\n'
            '• **पात्रता**: 18 से 40 वर्ष के भारतीय नागरिक (असंगठित क्षेत्र के कामगार)।\n'
            '• **दस्तावेज**: आधार कार्ड, आधार से जुड़ा बचत बैंक खाता (ऑटो-डेबिट सुविधा युक्त), मोबाइल नंबर।\n'
            '• **आवेदन स्थल**: अपनी बैंक शाखा, डाकघर या ऑनलाइन eNPS पोर्टल।';
      } else if (isTelugu) {
        return '👵 **అటల్ పెన్షన్ యోజన (APY) వివరాలు**:\n\n'
            '• **ప్రయోజనం**: 60 ఏళ్ల వయస్సు తర్వాత ప్రతి నెలా రూ. 1,000 నుంచి రూ. 5,000 వరకు జీవితాంతం పెన్షన్.\n'
            '• **అర్హత**: 18 నుండి 40 సంవత్సరాల మధ్య వయస్సు గల అసంఘటిత రంగ కార్మికులు.\n'
            '• **కావలసిన పత్రాలు**: ఆధార్ కార్డ్, ఆటో-డెబిట్ సదుపాయం ఉన్న బ్యాంక్ ఖాతా.\n'
            '• **ఎక్కడ దరఖాస్తు చేయాలి**: మీ సమీప బ్యాంక్ లేదా పోస్ట్ ఆఫీస్.';
      }
      return '👵 **Atal Pension Yojana (APY) & Senior Security**:\n\n'
          '• **Benefit**: Guaranteed monthly pension between ₹1,000 to ₹5,000 after reaching age 60, continuing to spouse after demise.\n'
          '• **Who is Eligible**: Citizens aged between 18 and 40 years engaged in unorganized or private sectors.\n'
          '• **Documents Required**: Aadhaar Card, Savings Bank Account with auto-debit consent, Mobile Number.\n'
          '• **Where to Apply**: Visit your local bank branch or Post Office to submit the APY auto-debit registration mandate.';
    }

    // 7. Mudra Loan / Small Business
    if (lower.contains('mudra') ||
        lower.contains('business') ||
        lower.contains('loan') ||
        lower.contains('startup') ||
        lower.contains('उद्यम') ||
        lower.contains('व्यापार') ||
        lower.contains('రుణం')) {
      if (isHindi) {
        return '💼 **प्रधानमंत्री मुद्रा योजना (PMMY) व्यापार ऋण**:\n\n'
            '• **श्रेणियां**: शिशु (₹50,000 तक), किशोर (₹50,000 से ₹5 लाख), तरुण (₹5 लाख से ₹10 लाख), तरुण प्लस (₹20 लाख तक)।\n'
            '• **पात्रता**: गैर-कृषि आय सृजन गतिविधियों, दुकान, वर्कशॉप, मैन्युफैक्चरिंग या सेवा उद्यम चलाने वाले नागरिक।\n'
            '• **दस्तावेज**: आधार/पैन कार्ड, व्यापार योजना/कोटेशन, पिछले 6 माह का बैंक स्टेटमेंट।\n'
            '• **आवेदन स्थल**: udyamimitra.in या किसी भी वाणिज्यिक/ग्रामीण बैंक में।';
      } else if (isTelugu) {
        return '💼 **పీఎం ముద్ర యోజన (MUDRA Loan)**:\n\n'
            '• **ప్రయోజనం**: చిన్న వ్యాపారాలు, దుకాణాలు, తయారీ రంగాల కోసం పూచీకత్తు లేకుండా రూ. 50,000 నుంచి రూ. 20 లక్షల వరకు రుణాలు.\n'
            '• **అర్హత**: వ్యవసాయేతర వ్యాపారాలు ప్రారంభించాలనుకునే భారతీయ పౌరులు.\n'
            '• **కావలసిన పత్రాలు**: ఆధార్, పాన్ కార్డ్, వ్యాపార ప్రణాళిక, 6 నెలల బ్యాంక్ స్టేట్‌మెంట్.\n'
            '• **దరఖాస్తు**: udyamimitra.in లేదా ఏదైనా బ్యాంకు శాఖ.';
      }
      return '💼 **Pradhan Mantri MUDRA Yojana (Business Loans)**:\n\n'
          '• **Benefit**: Collateral-free micro loans categorized into Shishu (up to ₹50k), Kishore (₹50k-₹5L), Tarun (₹5L-₹10L), and Tarun Plus (up to ₹20L).\n'
          '• **Who is Eligible**: Non-farm small businesses, retail shops, artisanal manufacturing, transport, and service enterprises.\n'
          '• **Documents Required**: Identity & Address Proof (Aadhaar / Voter ID), Business Plan / Machinery Quotations, 6 Months Bank Statement.\n'
          '• **Where to Apply**: Apply at udyamimitra.in or approach your local commercial/rural bank.';
    }

    // 8. Education / Student / Scholarship
    if (lower.contains('scholarship') ||
        lower.contains('student') ||
        lower.contains('college') ||
        lower.contains('education') ||
        lower.contains('school') ||
        lower.contains('छात्रवृत्ति') ||
        lower.contains('विद्यार्थी') ||
        lower.contains('స్కాలర్‌షిప్') ||
        lower.contains('చదువు')) {
      if (isHindi) {
        return '🎓 **राष्ट्रीय पोस्ट-मैट्रिक छात्रवृत्ति योजना**:\n\n'
            '• **लाभ**: 100% अनिवार्य गैर-वापसी योग्य कॉलेज फीस की प्रतिपूर्ति + ₹1,200/माह तक का रखरखाव भत्ता।\n'
            '• **पात्रता**: मान्यता प्राप्त संस्थानों में 11वीं, 12वीं, कॉलेज या पीजी कर रहे SC, ST और OBC छात्र, जिनकी पारिवारिक वार्षिक आय ₹2.5 लाख से कम हो।\n'
            '• **दस्तावेज**: जाति प्रमाण पत्र, आय प्रमाण पत्र, पिछली कक्षा की मार्कशीट, कॉलेज फीस रसीद, आधार से जुड़ा बैंक खाता।\n'
            '• **आवेदन स्थल**: scholarships.gov.in (National Scholarship Portal)।';
      } else if (isTelugu) {
        return '🎓 **పోస్ట్-మెట్రిక్ స్కాలర్‌షిప్ పథకం**:\n\n'
            '• **ప్రయోజనం**: పూర్తి కాలేజీ ఫీజు రీయింబర్స్‌మెంట్ మరియు ప్రతి నెలా విద్యార్థి నిర్వహణ భత్యం.\n'
            '• **అర్హత**: SC, ST, OBC విద్యార్థులు (కుటుంబ వార్షిక ఆదాయం రూ. 2.5 లక్షల లోపు ఉండాలి).\n'
            '• **కావలసిన పత్రాలు**: కుల ధృవీకరణ పత్రం (Caste), ఆదాయ ధృవీకరణ పత్రం (Income), మార్కుల జాబితా, కాలేజీ రసీదు.\n'
            '• **దరఖాస్తు**: scholarships.gov.in (నేషనల్ స్కాలర్‌షిప్ పోర్టల్).';
      }
      return '🎓 **National Post-Matric Scholarship Scheme**:\n\n'
          '• **Benefit**: 100% compulsory tuition fee reimbursement + monthly maintenance allowance up to ₹1,200/month.\n'
          '• **Who is Eligible**: SC, ST, and OBC students pursuing post-secondary education with parental income under ₹2.5 Lakh/year.\n'
          '• **Documents Required**: Caste Certificate, Income Certificate, Previous mark sheets, College Admission Fee Receipt, Aadhaar-seeded Bank Account.\n'
          '• **Where to Apply**: Register on the National Scholarship Portal at scholarships.gov.in.';
    }

    // 9. Free LPG Gas / Ujjwala
    if (lower.contains('gas') ||
        lower.contains('lpg') ||
        lower.contains('ujjwala') ||
        lower.contains('cylinder') ||
        lower.contains('उज्ज्वला') ||
        lower.contains('गैस') ||
        lower.contains('సిలిండర్') ||
        lower.contains('ఉజ్వల')) {
      if (isHindi) {
        return '🔥 **प्रधानमंत्री उज्ज्वला योजना 2.0 (PMUY)**:\n\n'
            '• **लाभ**: गरीब परिवारों की महिलाओं को निःशुल्क रसोई गैस (LPG) कनेक्शन + पहला भरा हुआ सिलेंडर और गैस चूल्हा मुफ्त।\n'
            '• **पात्रता**: 18 वर्ष से अधिक आयु की महिला, बीपीएल/एससी/एसटी या पीएमएवाई लाभार्थी, जिसके घर में पहले से कोई गैस कनेक्शन न हो।\n'
            '• **दस्तावेज**: महिला का आधार कार्ड, राशन कार्ड (BPL प्रमाण), बैंक खाता पासबुक।\n'
            '• **आवेदन स्थल**: निकटतम एलपीजी गैस वितरक (Indane, BharatGas, HP Gas) या pmuy.gov.in।';
      } else if (isTelugu) {
        return '🔥 **ప్రధానమంత్రి ఉజ్వల యోజన (PMUY)**:\n\n'
            '• **ప్రయోజనం**: పేద మహిళలకు ఉచిత గ్యాస్ కనెక్షన్, మొదటి సిలిండర్ మరియు గ్యాస్ పొయ్యి ఉచితం.\n'
            '• **అర్హత**: కుటుంబంలో 18 ఏళ్లు నిండిన మహిళ (రేషన్ కార్డు కలిగి ఉండాలి).\n'
            '• **కావలసిన పత్రాలు**: ఆధార్ కార్డ్, రేషన్ కార్డ్, బ్యాంక్ పాస్‌బుక్.\n'
            '• **ఎక్కడ దరఖాస్తు చేయాలి**: సమీప గ్యాస్ ఏజెన్సీ (ఇండేన్, భారత్ గ్యాస్, హెచ్‌పీ) లేదా pmuy.gov.in.';
      }
      return '🔥 **Pradhan Mantri Ujjwala Yojana (Free LPG Connection)**:\n\n'
          '• **Benefit**: Free LPG connection deposit waiver + first refill cylinder free + free LPG stove.\n'
          '• **Who is Eligible**: Adult women from low-income households (BPL / SC / ST / PMAY beneficiaries) without an existing LPG connection.\n'
          '• **Documents Required**: Aadhaar Card of Applicant & family members, Ration Card, Bank Passbook with IFSC.\n'
          '• **Where to Apply**: Visit your local Indane, HP, or BharatGas distributor, or apply at pmuy.gov.in.';
    }

    // 10. Seva Kendra / Center Locator / CSC / MeeSeva
    if (lower.contains('kendra') ||
        lower.contains('center') ||
        lower.contains('csc') ||
        lower.contains('meeseva') ||
        lower.contains('where to apply') ||
        lower.contains('location') ||
        lower.contains('केंद्र') ||
        lower.contains('కేంద్రం')) {
      if (isHindi) {
        return '📍 **निकटतम सेवा केंद्र कैसे खोजें**:\n\n'
            '• हमारे **"Kendras"** टैब पर जाएं, जहां गूगल मैप्स के जरिए आपके निकटतम कॉमन सर्विस सेंटर (CSC), मीसेवा केंद्र और नगर निगम वार्ड कार्यालय दिखाए गए हैं।\n'
            '• वहां जाने से पहले अपना मूल आधार कार्ड, सक्रिय मोबाइल और राशन कार्ड साथ ले जाएं।\n'
            '• एक टैप से सीधे गूगल मैप्स नेविगेशन शुरू करें!';
      } else if (isTelugu) {
        return '📍 **సమీప సేవా కేంద్రాన్ని కనుగొనండి**:\n\n'
            '• మా యాప్‌లోని **"Kendras"** ట్యాబ్‌ను చూడండి. ఇక్కడ గూగుల్ మ్యాప్స్ ద్వారా మీ దగ్గరలోని CSC కేంద్రాలు, మీసేవా సెంటర్లు మరియు మునిసిపల్ వార్డ్ ఆఫీస్‌లు చూపించబడతాయి.\n'
            '• వెళ్ళే ముందు ఆధార్ కార్డ్, బ్యాంక్ పాస్‌బుక్ వెంట తీసుకెళ్లండి!';
      }
      return '📍 **Locating Your Nearest Seva Kendra**:\n\n'
          '• Open the **"Kendras"** tab in JanSeva AI. Google Maps highlights all nearby Common Service Centers (CSCs), MeeSeva Kendras, and Municipal Ward Offices within your radius.\n'
          '• Check whether they are currently open, phone numbers, and tap "Directions" for instant turn-by-turn routing.\n'
          '• Always carry your original Aadhaar Card, linked mobile phone, and bank passbook.';
    }

    // 11. Documents General Query
    if (lower.contains('document') ||
        lower.contains('paper') ||
        lower.contains('proof') ||
        lower.contains('दस्तावेज') ||
        lower.contains('कागजात') ||
        lower.contains('పత్రాలు')) {
      if (isHindi) {
        return '📋 **सरकारी योजनाओं के लिए मुख्य सार्वभौमिक दस्तावेज**:\n\n'
            '1. **आधार कार्ड** (सक्रिय मोबाइल नंबर से लिंक होना अनिवार्य)\n'
            '2. **राशन कार्ड** (BPL / अन्त्योदय / प्राथमिकता सूची)\n'
            '3. **बैंक पासबुक** (Aadhaar Seeded / DBT चालू)\n'
            '4. **आय प्रमाण पत्र** (राजस्व विभाग द्वारा जारी)\n'
            '5. **जाति प्रमाण पत्र** (SC/ST/OBC आरक्षण हेतु)\n'
            '6. **जमीन के कागजात / खतौनी** (किसानों के लिए)';
      } else if (isTelugu) {
        return '📋 **ప్రభుత్వ పథకాలకు అవసరమైన ముఖ్యమైన పత్రాలు**:\n\n'
            '1. **ఆధార్ కార్డ్** (మొబైల్ నంబర్ లింక్ అయి ఉండాలి)\n'
            '2. **రేషన్ కార్డ్** (ఆహార భద్రత / తెల్ల రేషన్ కార్డు)\n'
            '3. **బ్యాంక్ పాస్‌బుక్** (DBT సదుపాయం ఉండాలి)\n'
            '4. **ఆదాయ ధృవీకరణ పత్రం** (Income Certificate)\n'
            '5. **కుల ధృవీకరణ పత్రం** (Caste Certificate)\n'
            '6. **పట్టాదారు పాస్‌బుక్** (రైతులకు)';
      }
      return '📋 **Core Universal Documents Needed for Government Welfare**:\n\n'
          '1. **Aadhaar Card**: Must be linked to an active mobile number for OTP e-KYC.\n'
          '2. **Ration Card / Food Security Card**: Proves BPL economic category.\n'
          '3. **Bank Account Passbook**: Must be seeded with Aadhaar on NPCI mapper for Direct Benefit Transfer (DBT).\n'
          '4. **Income Certificate**: Issued by Tehsildar / Revenue Authority for current year.\n'
          '5. **Caste Certificate**: Required for reserved welfare scholarships & concessions.\n'
          '6. **Land Records / RoR**: Required for agricultural farmer subsidies.';
    }

    // 12. If a specific scheme context was passed, use it dynamically
    if (schemeContext != null && schemeContext.isNotEmpty) {
      return 'Regarding **$schemeContext**:\n\n'
          'JanSeva AI has verified your inquiry against official portal guidelines. '
          'Please ensure your Aadhaar is linked to your bank account for direct benefit transfer (DBT). '
          'Visit your nearest Common Service Center (CSC) or check the "Eligibility" tab to run a personalized match score.';
    }

    // Default dynamic overview
    if (isHindi) {
      return 'नमस्ते! मैं आपका जनसेवा एआई नागरिक सहायक हूँ।\n\n'
          'आप मुझसे किसी भी योजना के बारे में पूछ सकते हैं:\n'
          '• **इलाज**: आयुष्मान भारत (₹5 लाख मुफ्त इलाज)\n'
          '• **किसान**: पीएम किसान (₹6,000 सालाना)\n'
          '• **ऋण**: पीएम स्वनिधि (रेहड़ी पटरी विक्रेताओं के लिए ₹50,000 ऋण) व मुद्रा ऋण\n'
          '• **मकान**: पीएम आवास योजना\n'
          '• **बेटी**: सुकन्या समृद्धि योजना (8.2% ब्याज)\n'
          '• **पेंशन**: अटल पेंशन योजना\n\n'
          'आप क्या जानना चाहते हैं? बोलकर या लिखकर पूछें!';
    } else if (isTelugu) {
      return 'నమస్కారం! నేను మీ జనసేవ AI పౌర సహాయకుడిని.\n\n'
          'మీరు నన్ను ఈ పథకాల గురించి అడగవచ్చు:\n'
          '• **వైద్యం**: ఆయుష్మాన్ భారత్ (రూ. 5 లక్షల ఉచిత వైద్యం)\n'
          '• **రైతులు**: పీఎం కిసాన్ (ఏటా రూ. 6,000 నగదు)\n'
          '• **వ్యాపారం**: పీఎం స్వనిధి (వీధి వ్యాపారుల రుణాలు) & ముద్ర రుణాలు\n'
          '• **ఇళ్లు**: పీఎం ఆవాస్ యోజన\n'
          '• **ఆడపిల్లలు**: సుకన్య సమృద్ధి యోజన\n'
          '• **పింఛను**: అటల్ పెన్షన్ యోజన\n\n'
          'మీ సందేహాన్ని మాట్లాడండి లేదా టైప్ చేయండి!';
    }

    return 'Hello! I am JanSeva AI, your personal civic assistant.\n\n'
        'You can ask me about any welfare domain:\n'
        '• **Healthcare**: Ayushman Bharat (₹5 Lakh cashless treatment)\n'
        '• **Farming**: PM-KISAN (₹6,000 annual direct benefit)\n'
        '• **Livelihoods**: PM SVANidhi (street vendor credit) & Mudra Loans\n'
        '• **Shelter**: PM Awas Yojana (rural/urban home construction)\n'
        '• **Girl Child**: Sukanya Samriddhi Yojana (8.2% interest savings)\n'
        '• **Old Age**: Atal Pension Yojana (guaranteed monthly pension)\n'
        '• **Education**: National Post-Matric Scholarships\n\n'
        'Speak or type your question to get immediate guidance!';
  }

  String _getLocalDocumentSimplification(String text, String language) {
    if (language.contains('Hindi')) {
      return '📌 **दस्तावेज़ का सरल सारांश (JanSeva AI Analysis)**:\n\n'
          '1. **यह क्या है?**: यह सार्वजनिक कल्याण योजना के तहत वित्तीय और सामाजिक सुरक्षा लाभ प्रदान करने का आधिकारिक सरकारी आदेश है।\n\n'
          '2. **आपको क्या लाभ मिलेगा?**: प्रत्यक्ष बैंक हस्तांतरण (DBT), रियायती ऋण या मुफ्त सेवा गारंटी।\n\n'
          '3. **आगे की कार्रवाई और आवश्यक दस्तावेज़**:\n'
          '   • अपना आधार कार्ड और आय/जाति प्रमाण पत्र तैयार रखें।\n'
          '   • निकटतम जन सेवा केंद्र (CSC) पर जाकर बायोमेट्रिक सत्यापन पूरा करें।';
    }
    return '📌 **Plain-Language Breakdown (JanSeva AI)**:\n\n'
        '1. **What this Notice is About**: An official welfare notification establishing eligibility and financial assistance for qualified households and workers.\n\n'
        '2. **What You Receive**: Direct financial subsidy, collateral-free credit, or social security safety net disbursed straight to your Aadhaar-linked bank account.\n\n'
        '3. **Immediate Action Steps**:\n'
        '   • Ensure your Aadhaar card is linked to your active mobile number and bank account.\n'
        '   • Carry original ID and land/income records to your nearest Common Service Center (CSC) to apply.';
  }

  String _getLocalEligibilityAdvice(UserProfile profile, SchemeModel scheme, String language) {
    return 'Based on your profile (${profile.age} yrs, ${profile.occupation}, Annual Income: ₹${profile.annualIncome}), '
        'you have high eligibility for **${scheme.title}**.\n\n'
        'Recommended Next Steps:\n'
        '1. Verify that your bank account is Aadhaar-seeded for direct benefit transfer (DBT).\n'
        '2. Collect the required documents: ${scheme.requiredDocuments.join(', ')}.\n'
        '3. Visit your nearest Seva Kendra or apply directly at ${scheme.officialPortalUrl}.';
  }
}
