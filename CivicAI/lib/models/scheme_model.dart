class SchemeModel {
  final String id;
  final String title;
  final String titleNative;
  final String ministry;
  final String category; // Agriculture, Healthcare, Women & Child, Education, Housing, Pension, Employment
  final String description;
  final String descriptionNative;
  final String benefitSummary;
  final double financialBenefitPerYear; // in INR
  final List<String> eligibilityCriteria;
  final List<String> requiredDocuments;
  final String officialPortalUrl;
  final String helplineNumber;
  final String tags;
  final bool isFeatured;
  final String iconEmoji;

  const SchemeModel({
    required this.id,
    required this.title,
    required this.titleNative,
    required this.ministry,
    required this.category,
    required this.description,
    required this.descriptionNative,
    required this.benefitSummary,
    required this.financialBenefitPerYear,
    required this.eligibilityCriteria,
    required this.requiredDocuments,
    required this.officialPortalUrl,
    required this.helplineNumber,
    required this.tags,
    this.isFeatured = false,
    this.iconEmoji = '🏛️',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'titleNative': titleNative,
      'ministry': ministry,
      'category': category,
      'description': description,
      'descriptionNative': descriptionNative,
      'benefitSummary': benefitSummary,
      'financialBenefitPerYear': financialBenefitPerYear,
      'eligibilityCriteria': eligibilityCriteria,
      'requiredDocuments': requiredDocuments,
      'officialPortalUrl': officialPortalUrl,
      'helplineNumber': helplineNumber,
      'tags': tags,
      'isFeatured': isFeatured,
      'iconEmoji': iconEmoji,
    };
  }

  factory SchemeModel.fromMap(Map<String, dynamic> map) {
    return SchemeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      titleNative: map['titleNative'] ?? map['title'] ?? '',
      ministry: map['ministry'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      descriptionNative: map['descriptionNative'] ?? map['description'] ?? '',
      benefitSummary: map['benefitSummary'] ?? '',
      financialBenefitPerYear: (map['financialBenefitPerYear'] as num?)?.toDouble() ?? 0.0,
      eligibilityCriteria: List<String>.from(map['eligibilityCriteria'] ?? []),
      requiredDocuments: List<String>.from(map['requiredDocuments'] ?? []),
      officialPortalUrl: map['officialPortalUrl'] ?? '',
      helplineNumber: map['helplineNumber'] ?? '',
      tags: map['tags'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      iconEmoji: map['iconEmoji'] ?? '🏛️',
    );
  }
}
