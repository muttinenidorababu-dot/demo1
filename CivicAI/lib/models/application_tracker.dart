enum ApplicationStatus {
  saved,
  documentsGathering,
  submittedAtKendra,
  underReview,
  approved,
  disbursed,
}

class TrackedApplication {
  final String id;
  final String schemeId;
  final String schemeTitle;
  final String category;
  final ApplicationStatus status;
  final DateTime dateAdded;
  final DateTime? lastUpdated;
  final String applicationReferenceNumber;
  final String? centerName;
  final String notes;
  final List<String> completedChecklist;

  const TrackedApplication({
    required this.id,
    required this.schemeId,
    required this.schemeTitle,
    required this.category,
    required this.status,
    required this.dateAdded,
    this.lastUpdated,
    required this.applicationReferenceNumber,
    this.centerName,
    this.notes = '',
    this.completedChecklist = const [],
  });

  TrackedApplication copyWith({
    String? id,
    String? schemeId,
    String? schemeTitle,
    String? category,
    ApplicationStatus? status,
    DateTime? dateAdded,
    DateTime? lastUpdated,
    String? applicationReferenceNumber,
    String? centerName,
    String? notes,
    List<String>? completedChecklist,
  }) {
    return TrackedApplication(
      id: id ?? this.id,
      schemeId: schemeId ?? this.schemeId,
      schemeTitle: schemeTitle ?? this.schemeTitle,
      category: category ?? this.category,
      status: status ?? this.status,
      dateAdded: dateAdded ?? this.dateAdded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      applicationReferenceNumber: applicationReferenceNumber ?? this.applicationReferenceNumber,
      centerName: centerName ?? this.centerName,
      notes: notes ?? this.notes,
      completedChecklist: completedChecklist ?? this.completedChecklist,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'schemeId': schemeId,
      'schemeTitle': schemeTitle,
      'category': category,
      'status': status.index,
      'dateAdded': dateAdded.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'applicationReferenceNumber': applicationReferenceNumber,
      'centerName': centerName,
      'notes': notes,
      'completedChecklist': completedChecklist,
    };
  }

  factory TrackedApplication.fromMap(Map<String, dynamic> map) {
    return TrackedApplication(
      id: map['id'] ?? '',
      schemeId: map['schemeId'] ?? '',
      schemeTitle: map['schemeTitle'] ?? '',
      category: map['category'] ?? '',
      status: ApplicationStatus.values[map['status'] ?? 0],
      dateAdded: DateTime.tryParse(map['dateAdded'] ?? '') ?? DateTime.now(),
      lastUpdated: map['lastUpdated'] != null ? DateTime.tryParse(map['lastUpdated']) : null,
      applicationReferenceNumber: map['applicationReferenceNumber'] ?? '',
      centerName: map['centerName'],
      notes: map['notes'] ?? '',
      completedChecklist: List<String>.from(map['completedChecklist'] ?? []),
    );
  }
}
