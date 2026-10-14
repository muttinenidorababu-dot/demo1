import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/application_tracker.dart';
import '../providers/language_provider.dart';
import '../providers/tracker_provider.dart';
import '../services/scheme_repository.dart';
import '../theme/app_theme.dart';
import 'scheme_detail_screen.dart';

class MySchemesScreen extends StatelessWidget {
  const MySchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final tracker = context.watch<TrackerProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.lightBg,
        appBar: AppBar(
          title: Text(
            lang.translate('my_applications'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.primaryNavy,
            indicatorColor: AppTheme.civicOrange,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Tracked Applications'),
              Tab(text: 'Saved Bookmarks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Tracked Applications
            tracker.applications.isEmpty
                ? _buildEmptyState('No active applications tracked yet.', 'Start tracking a scheme from the details screen!')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tracker.applications.length,
                    itemBuilder: (ctx, idx) {
                      final app = tracker.applications[idx];
                      return _buildApplicationCard(context, app, tracker);
                    },
                  ),

            // Tab 2: Saved Schemes
            tracker.savedSchemeIds.isEmpty
                ? _buildEmptyState('No saved schemes yet.', 'Tap the bookmark icon on any scheme to save it here!')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tracker.savedSchemeIds.length,
                    itemBuilder: (ctx, idx) {
                      final id = tracker.savedSchemeIds[idx];
                      final scheme = SchemeRepository.getById(id);
                      if (scheme == null) return const SizedBox();

                      return _buildSavedSchemeCard(context, scheme, tracker);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded, size: 54, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, TrackedApplication app, TrackerProvider tracker) {
    final dateFormat = DateFormat('dd MMM yyyy');

    Color statusColor;
    String statusText;
    int currentStep = 0;

    switch (app.status) {
      case ApplicationStatus.saved:
        statusColor = AppTheme.textMuted;
        statusText = 'Saved Draft';
        currentStep = 0;
        break;
      case ApplicationStatus.documentsGathering:
        statusColor = AppTheme.civicOrange;
        statusText = 'Gathering Documents';
        currentStep = 1;
        break;
      case ApplicationStatus.submittedAtKendra:
        statusColor = AppTheme.primaryIndigo;
        statusText = 'Submitted at Kendra';
        currentStep = 2;
        break;
      case ApplicationStatus.underReview:
        statusColor = Colors.purple;
        statusText = 'Under Verification';
        currentStep = 3;
        break;
      case ApplicationStatus.approved:
        statusColor = AppTheme.civicGreen;
        statusText = 'Sanctioned / Approved';
        currentStep = 4;
        break;
      case ApplicationStatus.disbursed:
        statusColor = AppTheme.civicGreen;
        statusText = 'Funds Disbursed';
        currentStep = 4;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  app.category,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            app.schemeTitle,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Ref: ${app.applicationReferenceNumber} • Added ${dateFormat.format(app.dateAdded)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          if (app.centerName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(app.centerName!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Stepper bar
          Row(
            children: List.generate(4, (i) {
              final isPassed = i <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isPassed ? statusColor : AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          if (app.notes.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                app.notes,
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Update Status Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PopupMenuButton<ApplicationStatus>(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.primaryNavy),
                      SizedBox(width: 4),
                      Text('Update Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                onSelected: (newStatus) => tracker.updateStatus(app.id, newStatus),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: ApplicationStatus.documentsGathering,
                    child: Text('Gathering Documents'),
                  ),
                  const PopupMenuItem(
                    value: ApplicationStatus.submittedAtKendra,
                    child: Text('Submitted at Seva Kendra'),
                  ),
                  const PopupMenuItem(
                    value: ApplicationStatus.underReview,
                    child: Text('Under Verification'),
                  ),
                  const PopupMenuItem(
                    value: ApplicationStatus.approved,
                    child: Text('Sanctioned / Approved'),
                  ),
                ],
              ),
              TextButton(
                child: const Text('View Scheme Details'),
                onPressed: () {
                  final scheme = SchemeRepository.getById(app.schemeId);
                  if (scheme != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SchemeDetailScreen(scheme: scheme)),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSchemeCard(BuildContext context, dynamic scheme, TrackerProvider tracker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  scheme.benefitSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppTheme.civicGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_remove_rounded, color: AppTheme.civicOrange),
            tooltip: 'Remove bookmark',
            onPressed: () => tracker.toggleSaveScheme(scheme.id),
          ),
        ],
      ),
    );
  }
}
