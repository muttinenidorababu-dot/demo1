import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme_model.dart';
import '../providers/language_provider.dart';
import '../providers/scheme_provider.dart';
import '../providers/tracker_provider.dart';
import '../services/speech_tts_service.dart';
import '../theme/app_theme.dart';
import 'seva_kendra_map_screen.dart';
import 'voice_assistant_screen.dart';

class SchemeDetailScreen extends StatefulWidget {
  final SchemeModel scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  final Set<String> _checkedDocs = {};
  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final schemeProv = context.watch<SchemeProvider>();
    final tracker = context.watch<TrackerProvider>();
    final tts = context.watch<SpeechTtsService>();

    final match = schemeProv.getMatchForScheme(widget.scheme.id);
    final isSaved = tracker.isSchemeSaved(widget.scheme.id);

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Scheme Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppTheme.civicOrange : AppTheme.primaryNavy,
            ),
            onPressed: () => tracker.toggleSaveScheme(widget.scheme.id),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.primaryNavy),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing ${widget.scheme.title} details')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.lightBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(widget.scheme.iconEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryIndigo.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.scheme.category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryIndigo,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.scheme.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.scheme.titleNative,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.scheme.ministry,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                  ),
                  const Divider(height: 24),

                  // Financial Benefit Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.civicGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.civicGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppTheme.civicGreen, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormatter.format(widget.scheme.financialBenefitPerYear),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.civicGreen,
                                ),
                              ),
                              Text(
                                widget.scheme.benefitSummary,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Match score if available
                  if (match != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: match.isEligible ? AppTheme.civicGreen : AppTheme.civicOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Your Match: ${match.matchPercentage}% — ${match.reason}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: match.isEligible ? AppTheme.civicGreen : AppTheme.civicOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Plain Language Summary & Voice Button
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'About This Scheme',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        tooltip: 'Listen Audio Description',
                        icon: Icon(
                          tts.isPlaying && tts.currentlySpeakingTextId == widget.scheme.id
                              ? Icons.stop_circle_rounded
                              : Icons.volume_up_rounded,
                          color: AppTheme.civicOrange,
                        ),
                        onPressed: () {
                          tts.speak(
                            text: '${widget.scheme.title}. ${widget.scheme.description}. ${widget.scheme.benefitSummary}',
                            languageCode: lang.currentLanguage,
                            textId: widget.scheme.id,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.scheme.description,
                    style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.scheme.descriptionNative,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Eligibility Criteria Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.rule_rounded, color: AppTheme.primaryIndigo, size: 20),
                      SizedBox(width: 8),
                      Text('Eligibility Criteria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.scheme.eligibilityCriteria.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.civicGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Document Checklist with interactive tick
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.checklist_rounded, color: AppTheme.civicOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Required Documents Checklist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        '${_checkedDocs.length}/${widget.scheme.requiredDocuments.length} Ready',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.civicOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...widget.scheme.requiredDocuments.map((doc) {
                    final isChecked = _checkedDocs.contains(doc);
                    return Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isChecked,
                        activeColor: AppTheme.civicOrange,
                        title: Text(
                          doc,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                            decoration: isChecked ? TextDecoration.lineThrough : null,
                            color: isChecked ? AppTheme.textMuted : AppTheme.textDark,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _checkedDocs.add(doc);
                            } else {
                              _checkedDocs.remove(doc);
                            }
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                    label: const Text('Track Application'),
                    onPressed: () {
                      tracker.startTrackingScheme(scheme: widget.scheme);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${widget.scheme.title} to your Application Tracker!'),
                          backgroundColor: AppTheme.civicGreen,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.civicOrange),
                      foregroundColor: AppTheme.civicOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.location_on_rounded, size: 18),
                    label: const Text('Find Kendra'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SevaKendraMapScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ask Gemini AI Voice Assistant with Context
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.civicOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.record_voice_over_rounded, size: 18),
                label: const Text('Ask JanSeva Voice AI about this Scheme'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoiceAssistantScreen(
                        initialSchemeContext:
                            'User is asking about ${widget.scheme.title} (${widget.scheme.category}). Benefit: ${widget.scheme.benefitSummary}',
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // External Links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                  label: const Text('Official Portal'),
                  onPressed: () async {
                    final uri = Uri.parse(widget.scheme.officialPortalUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: Text('Helpline (${widget.scheme.helplineNumber})'),
                  onPressed: () async {
                    final uri = Uri.parse('tel:${widget.scheme.helplineNumber}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
