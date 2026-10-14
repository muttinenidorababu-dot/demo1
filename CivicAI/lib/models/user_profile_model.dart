class UserProfile {
  final int age;
  final String gender; // Male, Female, Other
  final String occupation; // Farmer, Small Business / Street Vendor, Student, Homemaker, Senior Citizen, Unemployed / Laborer
  final double annualIncome; // in INR
  final String state;
  final String casteCategory; // General, OBC, SC, ST, EWS
  final bool hasBplCard;
  final bool hasDisability;
  final double landholdingAcres; // For farmers

  const UserProfile({
    this.age = 35,
    this.gender = 'Female',
    this.occupation = 'Small Business / Street Vendor',
    this.annualIncome = 120000,
    this.state = 'All India / Central',
    this.casteCategory = 'OBC',
    this.hasBplCard = true,
    this.hasDisability = false,
    this.landholdingAcres = 0.0,
  });

  UserProfile copyWith({
    int? age,
    String? gender,
    String? occupation,
    double? annualIncome,
    String? state,
    String? casteCategory,
    bool? hasBplCard,
    bool? hasDisability,
    double? landholdingAcres,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      state: state ?? this.state,
      casteCategory: casteCategory ?? this.casteCategory,
      hasBplCard: hasBplCard ?? this.hasBplCard,
      hasDisability: hasDisability ?? this.hasDisability,
      landholdingAcres: landholdingAcres ?? this.landholdingAcres,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'state': state,
      'casteCategory': casteCategory,
      'hasBplCard': hasBplCard,
      'hasDisability': hasDisability,
      'landholdingAcres': landholdingAcres,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      age: map['age'] ?? 35,
      gender: map['gender'] ?? 'Female',
      occupation: map['occupation'] ?? 'Small Business / Street Vendor',
      annualIncome: (map['annualIncome'] as num?)?.toDouble() ?? 120000,
      state: map['state'] ?? 'All India / Central',
      casteCategory: map['casteCategory'] ?? 'OBC',
      hasBplCard: map['hasBplCard'] ?? true,
      hasDisability: map['hasDisability'] ?? false,
      landholdingAcres: (map['landholdingAcres'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SchemeEligibilityMatch {
  final String schemeId;
  final int matchPercentage; // 0 to 100
  final bool isEligible;
  final String reason;
  final List<String> fulfilledCriteria;
  final List<String> missingCriteria;
  final double estimatedAnnualBenefit;

  const SchemeEligibilityMatch({
    required this.schemeId,
    required this.matchPercentage,
    required this.isEligible,
    required this.reason,
    required this.fulfilledCriteria,
    required this.missingCriteria,
    required this.estimatedAnnualBenefit,
  });
}
