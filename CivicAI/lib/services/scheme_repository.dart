import '../models/scheme_model.dart';
import '../models/user_profile_model.dart';

class SchemeRepository {
  static final List<SchemeModel> schemes = [
    const SchemeModel(
      id: 'pm-jay',
      title: 'Ayushman Bharat Pradhan Mantri Jan Arogya Yojana (PM-JAY)',
      titleNative: 'आयुष्मान भारत - प्रधानमंत्री जन आरोग्य योजना / ఆయుష్మాన్ భారత్',
      ministry: 'Ministry of Health and Family Welfare',
      category: 'Healthcare',
      description:
          'World\'s largest government-funded health assurance scheme providing comprehensive secondary and tertiary care hospitalisation coverage.',
      descriptionNative:
          'परिवारों को अस्पताल में भर्ती होने पर प्रति वर्ष 5 लाख रुपये तक का मुफ्त कैशलेस इलाज मिलता है। / కుటుంబానికి ఏడాదికి రూ. 5 లక్షల వరకు ఉచిత వైద్యం.',
      benefitSummary: '₹5,00,000 cashless health insurance coverage per eligible family per year.',
      financialBenefitPerYear: 500000,
      eligibilityCriteria: [
        'Households categorized under SECC 2011 or holding valid NFSA/BPL Ration Card.',
        'No ceiling on family size or age of members.',
        'Families with informal or low-income occupations, laborers, domestic workers.',
      ],
      requiredDocuments: [
        'Aadhaar Card',
        'Ration Card / BPL Card',
        'Active Mobile Number for OTP',
      ],
      officialPortalUrl: 'https://mera.pmjay.gov.in',
      helplineNumber: '14555',
      tags: 'health hospital cashless medical insurance bpl treatment',
      isFeatured: true,
      iconEmoji: '🏥',
    ),
    const SchemeModel(
      id: 'pm-kisan',
      title: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
      titleNative: 'पीएम किसान सम्मान निधि / పీఎం కిసాన్ సమ్మాన్ నిధి',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      category: 'Agriculture',
      description:
          'Direct income support scheme transferring funds directly into the bank accounts of landholding farmer families across India.',
      descriptionNative:
          'सभी पात्र किसान परिवारों को प्रति वर्ष 6,000 रुपये की प्रत्यक्ष वित्तीय सहायता तीन किस्तों में। / రైతులకు ఏటా రూ. 6,000 నేరుగా ఖాతాలో జమ.',
      benefitSummary: '₹6,000 per year directly transferred in three equal installments of ₹2,000.',
      financialBenefitPerYear: 6000,
      eligibilityCriteria: [
        'Small and marginal farmer families with cultivable landholding in their name.',
        'Institutional landholders and income tax paying families are excluded.',
        'Bank account must be Aadhaar-linked (e-KYC completed).',
      ],
      requiredDocuments: [
        'Aadhaar Card',
        'Land Ownership Record (Khatauni / RoR / Pattadar Passbook)',
        'Bank Account Passbook (Aadhaar Seeded)',
      ],
      officialPortalUrl: 'https://pmkisan.gov.in',
      helplineNumber: '155261',
      tags: 'farmer agriculture direct benefit income crop land kisan',
      isFeatured: true,
      iconEmoji: '🌾',
    ),
    const SchemeModel(
      id: 'pm-svanidhi',
      title: 'PM SVANidhi (Street Vendor\'s AtmaNirbhar Nidhi)',
      titleNative: 'पीएम स्वनिधि योजना / పీఎం స్వనిధి పథకం',
      ministry: 'Ministry of Housing and Urban Affairs',
      category: 'Employment',
      description:
          'Special micro-credit facility empowering urban street vendors to resume livelihoods with collateral-free working capital loans.',
      descriptionNative:
          'रेहड़ी-पटरी विक्रेताओं के लिए ₹10,000 से ₹50,000 तक का सस्ता बिना गारंटी का ऋण। / వీధి వ్యాపారులకు గ్యారంటీ లేకుండా వ్యాపార రుణం.',
      benefitSummary:
          'Collateral-free working capital loan up to ₹50,000 with 7% interest subsidy & cashback on digital transactions.',
      financialBenefitPerYear: 50000,
      eligibilityCriteria: [
        'Street vendors engaged in vending in urban areas on or before March 24, 2020.',
        'Possession of Certificate of Vending / ID card issued by Urban Local Bodies (ULBs).',
        'Recommendation letter from Town Vending Committee (TVC) or Municipal Corporation.',
      ],
      requiredDocuments: [
        'Vending Certificate / Letter of Recommendation',
        'Aadhaar Card',
        'Bank Account Details / UPI ID',
      ],
      officialPortalUrl: 'https://pmsvanidhi.mohua.gov.in',
      helplineNumber: '1800-11-1979',
      tags: 'vendor street loan small business working capital loan svanidhi',
      isFeatured: true,
      iconEmoji: '🛒',
    ),
    const SchemeModel(
      id: 'pm-awas-gramin',
      title: 'Pradhan Mantri Awas Yojana - Gramin (PMAY-G)',
      titleNative: 'प्रधानमंत्री आवास योजना (ग्रामीण) / పీఎం ఆవాస్ యోజన గ్రామీణ',
      ministry: 'Ministry of Rural Development',
      category: 'Housing',
      description:
          'Assistance to rural homeless families and those living in kutcha/dilapidated houses for construction of pucca homes.',
      descriptionNative:
          'ग्रामीण बेघर या कच्चे मकान वाले परिवारों को पक्का मकान बनाने के लिए ₹1.20 लाख से ₹1.30 लाख की सहायता। / గ్రామీణ ప్రాంతాల్లో ఇళ్ల నిర్మాణం కోసం ఆర్థిక సాయం.',
      benefitSummary:
          '₹1,20,000 in plain areas & ₹1,30,000 in hilly/difficult areas + 90 days MGNREGA wages + toilet subsidy.',
      financialBenefitPerYear: 130000,
      eligibilityCriteria: [
        'Houseless families or households living in zero, one, or two-room houses with kutcha wall and roof.',
        'Families without any adult earning member (16-59 years) or women-headed households.',
        'Selected via SECC 2011 priority list and Gram Sabha verification.',
      ],
      requiredDocuments: [
        'Aadhaar Card',
        'Job Card Number (MGNREGA)',
        'Bank Account Passbook',
        'Gram Panchayat Certificate of Land/Site',
      ],
      officialPortalUrl: 'https://pmayg.nic.in',
      helplineNumber: '1800-11-6446',
      tags: 'house housing rural construction home shelter awas',
      isFeatured: true,
      iconEmoji: '🏠',
    ),
    const SchemeModel(
      id: 'sukanya-samriddhi',
      title: 'Sukanya Samriddhi Yojana (SSY)',
      titleNative: 'सुकन्या समृद्धि योजना / సుకన్య సమృద్ధి యోజన',
      ministry: 'Ministry of Finance (Beti Bachao Beti Padhao)',
      category: 'Women & Child',
      description:
          'High-interest government-backed small savings scheme designed for the future education and marriage expenses of girl children.',
      descriptionNative:
          'बेटियों के भविष्य, उच्च शिक्षा और विवाह के लिए 8.2% की उच्चतम ब्याज दर वाली सरकारी बचत योजना। / ఆడపిల్లల భవిష్యత్తు, చదువుల కోసం అత్యధిక వడ్డీ పొదుపు పథకం.',
      benefitSummary:
          '8.2% annual compounded interest, triple tax exemption (EEE) under Section 80C, deposit from ₹250 to ₹1.5 Lakh/year.',
      financialBenefitPerYear: 25000,
      eligibilityCriteria: [
        'Account can be opened by parents/legal guardians for a girl child aged 10 years or younger.',
        'Maximum 2 accounts per family (or 3 in case of twin girls in second birth).',
        'Account matures after 21 years from opening date or on marriage after age 18.',
      ],
      requiredDocuments: [
        'Birth Certificate of Girl Child',
        'Identity & Address Proof of Parent/Guardian (Aadhaar / Voter ID)',
        'Passport-sized Photographs',
      ],
      officialPortalUrl: 'https://www.indiapost.gov.in',
      helplineNumber: '1800-266-6868',
      tags: 'girl child daughter saving women beti padhao education marriage interest',
      isFeatured: false,
      iconEmoji: '👧',
    ),
    const SchemeModel(
      id: 'atal-pension',
      title: 'Atal Pension Yojana (APY)',
      titleNative: 'अटल पेंशन योजना / అటల్ పెన్షన్ యోజన',
      ministry: 'Ministry of Finance / PFRDA',
      category: 'Pension',
      description:
          'Guaranteed monthly pension scheme primarily focused on workers in the unorganized sector to secure old age dignity.',
      descriptionNative:
          'असंगठित क्षेत्र के कामगारों के लिए 60 वर्ष की आयु के बाद ₹1,000 से ₹5,000 तक की आजीवन मासिक पेंशन गारंटी। / 60 ఏళ్ల తర్వాత నెలకు ₹1,000 నుంచి ₹5,000 పింఛను.',
      benefitSummary:
          'Guaranteed monthly pension of ₹1,000 to ₹5,000 after reaching 60 years of age, with continuation to spouse.',
      financialBenefitPerYear: 60000,
      eligibilityCriteria: [
        'Citizen of India aged between 18 and 40 years.',
        'Must possess a savings bank account linked with Aadhaar and mobile.',
        'Should not be an income tax payer as per current norms.',
      ],
      requiredDocuments: [
        'Aadhaar Card',
        'Bank Account Passbook (Auto-debit mandate)',
        'Mobile Number',
      ],
      officialPortalUrl: 'https://enps.nsdl.com',
      helplineNumber: '1800-110-069',
      tags: 'pension senior retirement old age monthly income unorganized worker',
      isFeatured: false,
      iconEmoji: '👵',
    ),
    const SchemeModel(
      id: 'pm-mudra',
      title: 'Pradhan Mantri MUDRA Yojana (PMMY)',
      titleNative: 'प्रधानमंत्री मुद्रा योजना / పీఎం ముద్ర యోజన',
      ministry: 'Ministry of Finance',
      category: 'Employment',
      description:
          'Collateral-free micro loans up to ₹20 Lakhs to non-corporate, non-farm micro and small enterprises (Shishu, Kishore, Tarun, Tarun Plus).',
      descriptionNative:
          'छोटे कारोबारियों, दुकानों, वर्कशॉप और उद्यमों के लिए ₹50,000 से ₹20 लाख तक का बिना गारंटी व्यापार ऋण। / చిన్న వ్యాపారాల కోసం పూచీకత్తు లేని రుణాలు.',
      benefitSummary:
          'Loans categorized: Shishu (up to ₹50k), Kishore (₹50k-₹5L), Tarun (₹5L-₹10L), Tarun Plus (up to ₹20L) with low interest.',
      financialBenefitPerYear: 100000,
      eligibilityCriteria: [
        'Any Indian citizen having a business plan for a non-farm sector income-generating activity.',
        'Manufacturing, processing, trading, transport, services, or allied agriculture.',
        'Satisfactory credit track record without existing bank defaults.',
      ],
      requiredDocuments: [
        'Identity & Address Proof (Aadhaar / Voter ID)',
        'Business Plan / Quotation of Machinery or Items to be purchased',
        'Past 6 Months Bank Statement & Business Registration Proof',
      ],
      officialPortalUrl: 'https://www.mudra.org.in',
      helplineNumber: '1800-180-1111',
      tags: 'loan business entrepreneur startup shopkeeper trade mudra small scale',
      isFeatured: true,
      iconEmoji: '💼',
    ),
    const SchemeModel(
      id: 'post-matric-scholarship',
      title: 'National Post-Matric Scholarship Scheme',
      titleNative: 'राष्ट्रीय पोस्ट-मैट्रिक छात्रवृत्ति योजना / పోస్ట్ మెట్రిక్ స్కాలర్‌షిప్',
      ministry: 'Ministry of Social Justice and Empowerment / Tribal Affairs',
      category: 'Education',
      description:
          'Comprehensive financial assistance for SC, ST, and OBC students pursuing post-matriculation or post-secondary education.',
      descriptionNative:
          'कक्षा 11वीं, 12वीं, कॉलेज, इंजीनियरिंग, मेडिकल और उच्च शिक्षा की पूरी फीस और मासिक रखरखाव भत्ता। / కళాశాల, డిగ్రీ, పీజీ విద్యార్థులకు ఫీజు రీయింబర్స్‌మెంట్ మరియు భత్యం.',
      benefitSummary:
          '100% compulsory non-refundable fees reimbursed + monthly maintenance allowance up to ₹1,200/month.',
      financialBenefitPerYear: 45000,
      eligibilityCriteria: [
        'Students belonging to SC, ST, or OBC categories studying in recognized colleges/universities.',
        'Annual parental income should not exceed ₹2,50,000 per annum.',
        'Must have passed the previous qualifying examination.',
      ],
      requiredDocuments: [
        'Caste Certificate issued by competent revenue authority',
        'Income Certificate (Current financial year)',
        'Marksheet of qualifying exam & College Admission Fee Receipt',
        'Aadhaar-seeded Bank Account',
      ],
      officialPortalUrl: 'https://scholarships.gov.in',
      helplineNumber: '0120-6619540',
      tags: 'student scholarship college university fee education grant study tuition',
      isFeatured: false,
      iconEmoji: '🎓',
    ),
    const SchemeModel(
      id: 'pm-ujjwala',
      title: 'Pradhan Mantri Ujjwala Yojana 2.0',
      titleNative: 'प्रधानमंत्री उज्ज्वला योजना 2.0 / పీఎం ఉజ్వల యోజన',
      ministry: 'Ministry of Petroleum and Natural Gas',
      category: 'Women & Child',
      description:
          'Smoke-free rural India initiative providing free LPG gas connections, first refill, and stove to women from poor households.',
      descriptionNative:
          'गरीब परिवारों की महिलाओं को मुफ्त रसोई गैस (LPG) कनेक्शन, पहला भरा हुआ सिलेंडर और चूल्हा। / పేద మహిళలకు ఉచిత గ్యాస్ కనెక్షన్ మరియు స్టవ్.',
      benefitSummary:
          'Free LPG connection deposit fee waiver + 1st cylinder refill free + free hotplate (gas stove).',
      financialBenefitPerYear: 4500,
      eligibilityCriteria: [
        'Adult woman belonging to poor household (BPL/SC/ST/PMAY beneficiary).',
        'No other LPG connection exists in the same household.',
        'Applicant must be at least 18 years of age.',
      ],
      requiredDocuments: [
        'Aadhaar Card of Applicant & adult family members',
        'Ration Card / Proof of BPL status',
        'Bank Account Passbook with IFSC',
      ],
      officialPortalUrl: 'https://www.pmuy.gov.in',
      helplineNumber: '1800-266-6696',
      tags: 'gas cylinder lpg ujjwala women stove clean energy fuel kitchen',
      isFeatured: false,
      iconEmoji: '🔥',
    ),
  ];

  static List<String> get categories => [
        'All',
        'Healthcare',
        'Agriculture',
        'Employment',
        'Housing',
        'Women & Child',
        'Pension',
        'Education',
      ];

  static List<SchemeModel> searchSchemes(String query, {String category = 'All'}) {
    final cleanQuery = query.toLowerCase().trim();
    return schemes.where((scheme) {
      final matchesCategory = category == 'All' || scheme.category == category;
      final matchesQuery = cleanQuery.isEmpty ||
          scheme.title.toLowerCase().contains(cleanQuery) ||
          scheme.titleNative.toLowerCase().contains(cleanQuery) ||
          scheme.description.toLowerCase().contains(cleanQuery) ||
          scheme.tags.toLowerCase().contains(cleanQuery) ||
          scheme.category.toLowerCase().contains(cleanQuery);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  static SchemeModel? getById(String id) {
    try {
      return schemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Calculates instant eligibility evaluation based on user profile
  static List<SchemeEligibilityMatch> calculateEligibility(UserProfile profile) {
    final List<SchemeEligibilityMatch> matches = [];

    for (final scheme in schemes) {
      int score = 40; // Base score
      final List<String> fulfilled = [];
      final List<String> missing = [];

      // Check scheme specific rules
      switch (scheme.id) {
        case 'pm-jay':
          if (profile.hasBplCard || profile.annualIncome <= 250000) {
            score += 55;
            fulfilled.add('Household qualifies under BPL / Low Income criteria');
          } else {
            missing.add('Requires BPL card or income under ₹2.5 Lakh/year');
          }
          if (profile.occupation.contains('Laborer') ||
              profile.occupation.contains('Vendor') ||
              profile.occupation.contains('Farmer')) {
            score += 15;
            fulfilled.add('Informal sector worker priority');
          }
          break;

        case 'pm-kisan':
          if (profile.occupation.contains('Farmer')) {
            score += 50;
            fulfilled.add('Identified as active agricultural farmer');
            if (profile.landholdingAcres > 0 && profile.landholdingAcres <= 5.0) {
              score += 25;
              fulfilled.add('Small & Marginal landholding verified');
            } else if (profile.landholdingAcres == 0) {
              missing.add('Requires cultivable agricultural land registered in applicant\'s name');
            }
          } else {
            score = 15;
            missing.add('Applicant must be an agricultural cultivator/farmer');
          }
          break;

        case 'pm-svanidhi':
          if (profile.occupation.contains('Vendor') ||
              profile.occupation.contains('Business') ||
              profile.occupation.contains('Laborer')) {
            score += 65;
            fulfilled.add('Eligible urban street vendor / micro-entrepreneur');
          } else {
            score = 20;
            missing.add('Targeted for street vendors and small market stall owners');
          }
          break;

        case 'pm-awas-gramin':
          if (profile.hasBplCard && profile.annualIncome <= 180000) {
            score += 60;
            fulfilled.add('Qualifies under rural housing economic threshold');
          } else {
            missing.add('Requires BPL status or income below ₹1.8 Lakh/year');
          }
          break;

        case 'sukanya-samriddhi':
          if (profile.gender == 'Female' || profile.age <= 45) {
            score += 60;
            fulfilled.add('Family with girl child (under 10 years) can apply');
          }
          break;

        case 'atal-pension':
          if (profile.age >= 18 && profile.age <= 40) {
            score += 60;
            fulfilled.add('Age is within 18 - 40 years eligibility window');
          } else {
            missing.add('Age must be between 18 and 40 years');
          }
          if (profile.annualIncome <= 500000) {
            score += 20;
            fulfilled.add('Unorganized worker income threshold fulfilled');
          }
          break;

        case 'post-matric-scholarship':
          if (profile.occupation.contains('Student') || profile.age <= 28) {
            score += 45;
            fulfilled.add('Student age profile met');
            if (['SC', 'ST', 'OBC'].contains(profile.casteCategory)) {
              score += 35;
              fulfilled.add('${profile.casteCategory} category reservation benefits');
            }
            if (profile.annualIncome <= 250000) {
              score += 20;
              fulfilled.add('Parental income below ₹2.5 Lakh limit');
            }
          } else {
            score = 10;
            missing.add('Only applicable for active students enrolled in post-10th college');
          }
          break;

        case 'pm-ujjwala':
          if (profile.gender == 'Female') {
            score += 40;
            fulfilled.add('Adult woman head of household requirement met');
          }
          if (profile.hasBplCard) {
            score += 40;
            fulfilled.add('BPL / Priority ration card eligible');
          } else {
            missing.add('Requires proof of BPL or deprivation under SECC');
          }
          break;

        default:
          score = 70;
          fulfilled.add('General civic eligibility satisfied');
      }

      final clampedScore = score.clamp(10, 99);
      final isEligible = clampedScore >= 60;

      matches.add(
        SchemeEligibilityMatch(
          schemeId: scheme.id,
          matchPercentage: clampedScore,
          isEligible: isEligible,
          reason: isEligible
              ? 'High probability of approval based on your profile details.'
              : 'Some criteria need verification or you may need additional documentation.',
          fulfilledCriteria: fulfilled,
          missingCriteria: missing,
          estimatedAnnualBenefit: isEligible ? scheme.financialBenefitPerYear : 0,
        ),
      );
    }

    // Sort by highest match percentage first
    matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return matches;
  }
}
