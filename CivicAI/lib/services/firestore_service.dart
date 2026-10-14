import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application_tracker.dart';
import '../models/user_profile_model.dart';

class FirestoreService {
  static const String _profileKey = 'janseva_user_profile';
  static const String _savedSchemesKey = 'janseva_saved_schemes';
  static const String _applicationsKey = 'janseva_applications';

  Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr);
        return UserProfile.fromMap(map);
      } catch (_) {}
    }
    return const UserProfile();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  Future<List<String>> loadSavedSchemeIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedSchemesKey) ?? ['pm-jay', 'pm-kisan'];
  }

  Future<void> toggleSaveScheme(String schemeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedSchemesKey) ?? ['pm-jay', 'pm-kisan'];
    if (list.contains(schemeId)) {
      list.remove(schemeId);
    } else {
      list.add(schemeId);
    }
    await prefs.setStringList(_savedSchemesKey, list);
  }

  Future<List<TrackedApplication>> loadTrackedApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_applicationsKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        return jsonList
            .map((str) => TrackedApplication.fromMap(jsonDecode(str)))
            .toList();
      } catch (_) {}
    }

    // Default seed applications for demonstration
    final defaultApps = [
      TrackedApplication(
        id: 'app-001',
        schemeId: 'pm-jay',
        schemeTitle: 'Ayushman Bharat (PM-JAY)',
        category: 'Healthcare',
        status: ApplicationStatus.approved,
        dateAdded: DateTime.now().subtract(const Duration(days: 14)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        applicationReferenceNumber: 'PMJAY-2026-98124',
        centerName: 'DigiSeva Hub CSC Gandhi Chowk',
        notes: 'Ayushman Golden Card generated and active for family.',
        completedChecklist: ['Aadhaar Card', 'Ration Card / BPL Card', 'OTP Verified'],
      ),
      TrackedApplication(
        id: 'app-002',
        schemeId: 'pm-svanidhi',
        schemeTitle: 'PM SVANidhi Micro-Credit',
        category: 'Employment',
        status: ApplicationStatus.underReview,
        dateAdded: DateTime.now().subtract(const Duration(days: 5)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 12)),
        applicationReferenceNumber: 'SVN-2026-44321',
        centerName: 'MeeSeva Station Road',
        notes: 'Submitted ULB Vending Certificate. Bank verification in progress.',
        completedChecklist: ['Vending Certificate', 'Aadhaar Card'],
      ),
    ];

    await saveTrackedApplications(defaultApps);
    return defaultApps;
  }

  Future<void> saveTrackedApplications(List<TrackedApplication> apps) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = apps.map((app) => jsonEncode(app.toMap())).toList();
    await prefs.setStringList(_applicationsKey, jsonList);
  }

  Future<void> addApplication(TrackedApplication app) async {
    final apps = await loadTrackedApplications();
    apps.insert(0, app);
    await saveTrackedApplications(apps);
  }

  Future<void> updateApplicationStatus(String appId, ApplicationStatus newStatus) async {
    final apps = await loadTrackedApplications();
    final idx = apps.indexWhere((a) => a.id == appId);
    if (idx != -1) {
      apps[idx] = apps[idx].copyWith(
        status: newStatus,
        lastUpdated: DateTime.now(),
      );
      await saveTrackedApplications(apps);
    }
  }
}
