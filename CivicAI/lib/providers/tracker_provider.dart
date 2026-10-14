import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/application_tracker.dart';
import '../models/scheme_model.dart';
import '../services/firestore_service.dart';

class TrackerProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<String> _savedSchemeIds = [];
  List<TrackedApplication> _applications = [];
  bool _isLoading = true;

  List<String> get savedSchemeIds => _savedSchemeIds;
  List<TrackedApplication> get applications => _applications;
  bool get isLoading => _isLoading;

  TrackerProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _savedSchemeIds = await _firestoreService.loadSavedSchemeIds();
    _applications = await _firestoreService.loadTrackedApplications();
    _isLoading = false;
    notifyListeners();
  }

  bool isSchemeSaved(String schemeId) {
    return _savedSchemeIds.contains(schemeId);
  }

  Future<void> toggleSaveScheme(String schemeId) async {
    await _firestoreService.toggleSaveScheme(schemeId);
    _savedSchemeIds = await _firestoreService.loadSavedSchemeIds();
    notifyListeners();
  }

  Future<void> startTrackingScheme({
    required SchemeModel scheme,
    String? centerName,
    String? referenceNumber,
  }) async {
    final newApp = TrackedApplication(
      id: const Uuid().v4(),
      schemeId: scheme.id,
      schemeTitle: scheme.title,
      category: scheme.category,
      status: ApplicationStatus.documentsGathering,
      dateAdded: DateTime.now(),
      applicationReferenceNumber: referenceNumber ?? 'APP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      centerName: centerName ?? 'Common Service Center (CSC)',
      notes: 'Initial checklist created for ${scheme.title}',
      completedChecklist: [],
    );

    await _firestoreService.addApplication(newApp);
    _applications = await _firestoreService.loadTrackedApplications();
    notifyListeners();
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    await _firestoreService.updateApplicationStatus(applicationId, status);
    _applications = await _firestoreService.loadTrackedApplications();
    notifyListeners();
  }

  Future<void> toggleDocumentCheck(String applicationId, String docName) async {
    final idx = _applications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      final app = _applications[idx];
      final currentList = List<String>.from(app.completedChecklist);
      if (currentList.contains(docName)) {
        currentList.remove(docName);
      } else {
        currentList.add(docName);
      }

      _applications[idx] = app.copyWith(
        completedChecklist: currentList,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
      await _firestoreService.saveTrackedApplications(_applications);
    }
  }
}
