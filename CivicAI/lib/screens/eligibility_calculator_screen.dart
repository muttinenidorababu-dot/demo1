import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../providers/language_provider.dart';
import '../providers/scheme_provider.dart';
import '../services/scheme_repository.dart';
import '../theme/app_theme.dart';
import 'scheme_detail_screen.dart';

class EligibilityCalculatorScreen extends StatefulWidget {
  const EligibilityCalculatorScreen({super.key});

  @override
  State<EligibilityCalculatorScreen> createState() => _EligibilityCalculatorScreenState();
}

class _EligibilityCalculatorScreenState extends State<EligibilityCalculatorScreen> {
  late int _age;
  late String _gender;
  late String _occupation;
  late double _annualIncome;
  late String _state;
  late String _casteCategory;
  late bool _hasBplCard;
  late bool _hasDisability;
  late double _landholdingAcres;

  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  final List<String> _occupations = [
    'Farmer',
    'Small Business / Street Vendor',
    'Daily Wage / Informal Laborer',
    'Student',
    'Homemaker',
    'Senior Citizen / Retired',
    'Unemployed',
  ];

  final List<String> _states = [
    'All India / Central',
    'Telangana',
    'Andhra Pradesh',
    'Maharashtra',
    'Uttar Pradesh',
    'Bihar',
    'Tamil Nadu',
    'Karnataka',
    'West Bengal',
    'Rajasthan',
    'Madhya Pradesh',
  ];

  final List<String> _categories = ['General', 'OBC', 'SC', 'ST', 'EWS'];

  @override
  void initState() {
    super.initState();
    final profile = context.read<SchemeProvider>().profile;
    _age = profile.age;
    _gender = profile.gender;
    _occupation = profile.occupation;
    _annualIncome = profile.annualIncome;
    _state = profile.state;
    _casteCategory = profile.casteCategory;
    _hasBplCard = profile.hasBplCard;
    _hasDisability = profile.hasDisability;
    _landholdingAcres = profile.landholdingAcres;
  }

  void _saveAndRecalculate() {
    final newProfile = UserProfile(
      age: _age,
      gender: _gender,
      occupation: _occupation,
      annualIncome: _annualIncome,
      state: _state,
      casteCategory: _casteCategory,
      hasBplCard: _hasBplCard,
      hasDisability: _hasDisability,
      landholdingAcres: _landholdingAcres,
    );

    context.read<SchemeProvider>().updateProfile(newProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated & eligibility recalculated with AI!'),
        backgroundColor: AppTheme.civicGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final schemeProv = context.watch<SchemeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          lang.translate('check_eligibility'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.civicOrange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppTheme.civicOrange, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant Citizen Eligibility Matcher',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Tell us about your household to discover benefits',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderStat(
                        'Eligible Schemes',
                        '${schemeProv.eligibleSchemesCount}',
                        Icons.check_circle_rounded,
                        AppTheme.civicGreen,
                      ),
                      _buildHeaderStat(
                        'Est. Annual Benefit',
                        currencyFormatter.format(schemeProv.totalPotentialBenefit),
                        Icons.monetization_on_rounded,
                        AppTheme.civicOrange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile Inputs Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Household & Personal Parameters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Age Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Age of Applicant', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('$_age Years', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo)),
                    ],
                  ),
                  Slider(
                    value: _age.toDouble(),
                    min: 15,
                    max: 85,
                    divisions: 70,
                    activeColor: AppTheme.primaryIndigo,
                    onChanged: (val) => setState(() => _age = val.toInt()),
                    onChangeEnd: (_) => _saveAndRecalculate(),
                  ),

                  const SizedBox(height: 12),

                  // Gender Choice Chips
                  const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Female', 'Male', 'Other'].map((g) {
                      final isSelected = _gender == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(g),
                          selected: isSelected,
                          selectedColor: AppTheme.civicOrange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) {
                            setState(() => _gender = g);
                            _saveAndRecalculate();
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Occupation Dropdown
                  const Text('Primary Occupation / Livelihood', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _occupations.contains(_occupation) ? _occupation : _occupations.first,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    items: _occupations.map((occ) {
                      return DropdownMenuItem(value: occ, child: Text(occ));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _occupation = val);
                        _saveAndRecalculate();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Annual Household Income
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Annual Household Income', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        currencyFormatter.format(_annualIncome),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.civicGreen),
                      ),
                    ],
                  ),
                  Slider(
                    value: _annualIncome,
                    min: 20000,
                    max: 800000,
                    divisions: 39,
                    activeColor: AppTheme.civicGreen,
                    onChanged: (val) => setState(() => _annualIncome = val),
                    onChangeEnd: (_) => _saveAndRecalculate(),
                  ),

                  const SizedBox(height: 12),

                  // State Selector
                  const Text('State / Domicile', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _states.contains(_state) ? _state : _states.first,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    items: _states.map((st) {
                      return DropdownMenuItem(value: st, child: Text(st));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _state = val);
                        _saveAndRecalculate();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Category Chips
                  const Text('Social Category / Caste', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((c) {
                      final isSelected = _casteCategory == c;
                      return ChoiceChip(
                        label: Text(c),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryNavy,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) {
                          setState(() => _casteCategory = c);
                          _saveAndRecalculate();
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // BPL Card Toggle
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Holds BPL / Antyodaya Ration Card', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Priority access for health, housing & rations', style: TextStyle(fontSize: 12)),
                      value: _hasBplCard,
                      activeColor: AppTheme.civicGreen,
                      onChanged: (val) {
                        setState(() => _hasBplCard = val);
                        _saveAndRecalculate();
                      },
                    ),
                  ),

                  // Farmer Landholding if farmer
                  if (_occupation.contains('Farmer')) ...[
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Cultivable Landholding', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text('${_landholdingAcres.toStringAsFixed(1)} Acres', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.civicOrange)),
                      ],
                    ),
                    Slider(
                      value: _landholdingAcres,
                      min: 0,
                      max: 10,
                      divisions: 20,
                      activeColor: AppTheme.civicOrange,
                      onChanged: (val) => setState(() => _landholdingAcres = val),
                      onChangeEnd: (_) => _saveAndRecalculate(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Results Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Matched Schemes For You',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Sorted by highest match',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // List of match cards
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schemeProv.eligibilityMatches.length,
              itemBuilder: (ctx, idx) {
                final match = schemeProv.eligibilityMatches[idx];
                final scheme = SchemeRepository.getById(match.schemeId);
                if (scheme == null) return const SizedBox();

                return _buildMatchCard(context, scheme, match);
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, dynamic scheme, dynamic match) {
    final isHigh = match.matchPercentage >= 70;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHigh ? AppTheme.civicGreen.withOpacity(0.3) : AppTheme.borderLight,
          width: isHigh ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(scheme.iconEmoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scheme.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scheme.category,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isHigh ? AppTheme.civicGreen : AppTheme.civicOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${match.matchPercentage}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            match.reason,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          if (match.fulfilledCriteria.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...match.fulfilledCriteria.map<Widget>((fc) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.civicGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fc,
                          style: const TextStyle(fontSize: 12, color: AppTheme.civicGreen, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (match.missingCriteria.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...match.missingCriteria.map<Widget>((mc) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.civicOrange),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mc,
                          style: const TextStyle(fontSize: 12, color: AppTheme.civicOrange),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View Scheme & Apply Steps'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SchemeDetailScreen(scheme: scheme)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
