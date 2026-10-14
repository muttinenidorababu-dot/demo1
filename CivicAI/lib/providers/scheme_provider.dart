import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../models/user_profile_model.dart';
import '../services/firestore_service.dart';
import '../services/scheme_repository.dart';

class SchemeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  UserProfile _profile = const UserProfile();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<SchemeEligibilityMatch> _eligibilityMatches = [];
  bool _isLoading = true;

  UserProfile get profile => _profile;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<SchemeEligibilityMatch> get eligibilityMatches => _eligibilityMatches;
  bool get isLoading => _isLoading;

  SchemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _profile = await _firestoreService.loadUserProfile();
    _recalculate();
    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<SchemeModel> get displayedSchemes {
    return SchemeRepository.searchSchemes(
      _searchQuery,
      category: _selectedCategory,
    );
  }

  List<SchemeModel> get featuredSchemes {
    return SchemeRepository.schemes.where((s) => s.isFeatured).toList();
  }

  SchemeEligibilityMatch? getMatchForScheme(String schemeId) {
    try {
      return _eligibilityMatches.firstWhere((m) => m.schemeId == schemeId);
    } catch (_) {
      return null;
    }
  }

  double get totalPotentialBenefit {
    double total = 0;
    for (final match in _eligibilityMatches) {
      if (match.isEligible) {
        total += match.estimatedAnnualBenefit;
      }
    }
    return total;
  }

  int get eligibleSchemesCount {
    return _eligibilityMatches.where((m) => m.isEligible).length;
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    _recalculate();
    notifyListeners();
    await _firestoreService.saveUserProfile(newProfile);
  }

  void _recalculate() {
    _eligibilityMatches = SchemeRepository.calculateEligibility(_profile);
  }
}
