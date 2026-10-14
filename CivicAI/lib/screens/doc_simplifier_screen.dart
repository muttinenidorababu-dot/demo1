import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/gemini_service.dart';
import '../services/speech_tts_service.dart';
import '../theme/app_theme.dart';

class DocSimplifierScreen extends StatefulWidget {
  const DocSimplifierScreen({super.key});

  @override
  State<DocSimplifierScreen> createState() => _DocSimplifierScreenState();
}

class _DocSimplifierScreenState extends State<DocSimplifierScreen> {
  final TextEditingController _docController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isProcessing = false;
  String? _resultSummary;
  bool _isAiGenerated = false;

  final Map<String, String> _sampleDocs = {
    'PM SVANidhi Gazette 2026':
        'MINISTRY OF HOUSING AND URBAN AFFAIRS NOTIFICATION F.No. K-14011/2026-UD. Under Section 4 of the PM Street Vendor AtmaNirbhar Nidhi, it is hereby notified that vending identity cards issued by ULBs shall now qualify for automatic first tranche renewal of working capital loans up to ₹20,000 without guarantor requirement, provided digital transactions exceed 50 UPI transactions per quarter. Beneficiaries must present Aadhaar-seeded NPCI verified accounts and certification of active vending within the municipal zone limits.',
    'Ayushman Bharat Circular':
        'NATIONAL HEALTH AUTHORITY ORDER No. S-12019/2026/NHA. In pursuance of Universal Health Coverage objectives, secondary and tertiary empanelled healthcare providers (EHCPs) are directed to admit beneficiaries bearing valid AB-PMJAY Golden Cards without pre-authorization delays for listed emergency surgical packages. Hospital mitigation desk shall ensure non-levy of ancillary bed charges, surgical consumables, and post-discharge medication for up to 15 days.',
    'PMAY Rural Housing Release':
        'DEPARTMENT OF RURAL DEVELOPMENT CIRCULAR No. 34/2026. Allocation of instalment funds under Pradhan Mantri Awas Yojana Gramin. Geotagging verification of plinth level construction must be registered by the Gram Rozgar Sahayak within 14 calendar days to trigger electronic DBT release of Stage II grant totaling ₹45,000 directly into the beneficiary PFMS mapped account.',
  };

  @override
  void initState() {
    super.initState();
    _docController.text = _sampleDocs.values.first;
  }

  @override
  void dispose() {
    _docController.dispose();
    super.dispose();
  }

  Future<void> _simplifyDoc() async {
    final text = _docController.text.trim();
    if (text.isEmpty) return;

    final lang = context.read<LanguageProvider>().currentLanguage;

    setState(() {
      _isProcessing = true;
      _resultSummary = null;
    });

    final res = await _geminiService.simplifyDocument(
      documentText: text,
      language: lang,
    );

    setState(() {
      _isProcessing = false;
      _resultSummary = res['summary'];
      _isAiGenerated = res['isAiGenerated'] ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final tts = context.watch<SpeechTtsService>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('AI Document Simplifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Explanation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryIndigo, Color(0xFF1E1B4B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.document_scanner_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bureaucratic Language → Plain Language',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Paste any government circular, legal notice, or application guideline to get a 3-bullet breakdown in your native language.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sample Selector Chips
            const Text('Choose a Sample Circular to Test:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sampleDocs.entries.map((e) {
                final isSelected = _docController.text == e.value;
                return ChoiceChip(
                  label: Text(e.key),
                  selected: isSelected,
                  selectedColor: AppTheme.civicOrange,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textDark,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _docController.text = e.value;
                      _resultSummary = null;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Document Text Area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Official Document Text / Notification',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            setState(() {
                              _docController.clear();
                              _resultSummary = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _docController,
                      maxLines: 7,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                      decoration: const InputDecoration(
                        hintText: 'Paste official government notice text or circular here...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.civicOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome, size: 20),
                label: Text(
                  _isProcessing
                      ? 'Gemini AI is Simplifying...'
                      : 'Simplify with Gemini AI (${lang.currentLanguage})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _isProcessing ? null : _simplifyDoc,
              ),
            ),

            const SizedBox(height: 20),

            // Result Display Card
            if (_resultSummary != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.civicGreen, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.civicGreen.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppTheme.civicGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isAiGenerated
                                  ? 'Gemini AI Breakdown (${lang.currentLanguage})'
                                  : 'Simplified Breakdown (${lang.currentLanguage})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.civicGreen,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Listen to Simplified Summary',
                          icon: Icon(
                            tts.isPlaying && tts.currentlySpeakingTextId == 'doc-summary'
                                ? Icons.stop_circle_rounded
                                : Icons.volume_up_rounded,
                            color: AppTheme.civicOrange,
                          ),
                          onPressed: () {
                            tts.speak(
                              text: _resultSummary!,
                              languageCode: lang.currentLanguage,
                              textId: 'doc-summary',
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    SelectableText(
                      _resultSummary!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
