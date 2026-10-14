import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../services/speech_tts_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    final gemini = context.read<ChatProvider>().geminiService;
    _apiKeyController.text = gemini.currentApiKey ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final chat = context.watch<ChatProvider>();
    final gemini = chat.geminiService;

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Settings & Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Gemini API Configuration Card
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
                          Icon(Icons.auto_awesome, color: AppTheme.civicOrange, size: 22),
                          SizedBox(width: 8),
                          Text('Google Gemini API', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: gemini.hasApiKey ? AppTheme.civicGreen.withOpacity(0.12) : AppTheme.primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gemini.hasApiKey ? 'Connected' : 'Offline / Smart Demo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: gemini.hasApiKey ? AppTheme.civicGreen : AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your Gemini API Key to enable live cloud reasoning for eligibility matching, voice answers, and document summarization.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      hintText: 'Enter Google Gemini API Key...',
                      hintStyle: const TextStyle(fontSize: 13),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('Get Free Key (Google AI Studio)', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final uri = Uri.parse('https://aistudio.google.com/app/apikey');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.civicOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final key = _apiKeyController.text.trim();
                          await gemini.saveApiKey(key);
                          if (!mounted) return;
                          setState(() {});
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Gemini API configuration saved!'),
                              backgroundColor: AppTheme.civicGreen,
                            ),
                          );
                        },
                        child: const Text('Save Key', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Language Selection Card
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
                      Icon(Icons.translate_rounded, color: AppTheme.primaryIndigo, size: 22),
                      SizedBox(width: 8),
                      Text('App & Voice Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...LanguageProvider.supportedLanguages.map((l) {
                    return Material(
                      color: Colors.transparent,
                      child: RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: l['name']!,
                        groupValue: lang.currentLanguage,
                        activeColor: AppTheme.civicOrange,
                        title: Text('${l['native']} (${l['name']})', style: const TextStyle(fontWeight: FontWeight.w600)),
                        onChanged: (val) {
                          if (val != null) lang.setLanguage(val);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Assistant Voice Persona & Cadence Card
            Consumer<SpeechTtsService>(
              builder: (context, tts, child) {
                return Container(
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
                          Icon(Icons.record_voice_over_rounded, color: AppTheme.civicOrange, size: 22),
                          SizedBox(width: 8),
                          Text('Voice Assistant Voice & Persona', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Change the voice tone, speed, and pitch of your AI companion.',
                        style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSettingsPersonaChip(tts, VoicePersona.female, '👩 Priya (Warm Female)'),
                          _buildSettingsPersonaChip(tts, VoicePersona.male, '👨 Aarav (Clear Male)'),
                          _buildSettingsPersonaChip(tts, VoicePersona.elderFriendly, '👵 Elder-Friendly (Slow & Patient)'),
                          _buildSettingsPersonaChip(tts, VoicePersona.standard, '🎙️ Standard Natural'),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Speech Rate
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Speed / Rate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${(tts.speechRate * 2).toStringAsFixed(2)}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryIndigo)),
                        ],
                      ),
                      Slider(
                        value: tts.speechRate,
                        min: 0.25,
                        max: 0.85,
                        divisions: 12,
                        activeColor: AppTheme.primaryIndigo,
                        onChanged: (val) => tts.setCustomSpeechRate(val),
                      ),

                      // Pitch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pitch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('${tts.pitch.toStringAsFixed(2)}x', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.civicOrange)),
                        ],
                      ),
                      Slider(
                        value: tts.pitch,
                        min: 0.6,
                        max: 1.6,
                        divisions: 10,
                        activeColor: AppTheme.civicOrange,
                        onChanged: (val) => tts.setCustomPitch(val),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.civicOrange),
                            foregroundColor: AppTheme.civicOrange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: Icon(tts.isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded, size: 18),
                          label: Text(
                            tts.isPlaying ? 'Stop Sample' : 'Listen to Voice Preview (${lang.currentLanguage})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            if (tts.isPlaying) {
                              tts.stop();
                            } else {
                              tts.previewCurrentVoice(lang.currentLanguage);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // National Civic Helplines Directory
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
                      Icon(Icons.contact_phone_rounded, color: AppTheme.civicGreen, size: 22),
                      SizedBox(width: 8),
                      Text('Direct Citizen Helplines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHelplineRow('National Emergency (All)', '112'),
                  _buildHelplineRow('Women in Distress Helpline', '1091'),
                  _buildHelplineRow('Kisan Call Center (Agriculture)', '1551'),
                  _buildHelplineRow('Elderly Citizen National Helpline', '14567'),
                  _buildHelplineRow('Ayushman Health Authority', '14555'),
                  _buildHelplineRow('PM SVANidhi Vendor Support', '1800-11-1979'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About App Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'JanSeva AI (CivicAssist)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Built with Flutter, Google Gemini & Firebase for Public Impact',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0 • Open Civic Architecture',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted.withOpacity(0.8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineRow(String title, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
          ),
          InkWell(
            onTap: () async {
              final uri = Uri.parse('tel:$number');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.civicGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.call, size: 12, color: AppTheme.civicGreen),
                  const SizedBox(width: 4),
                  Text(
                    number,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.civicGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPersonaChip(SpeechTtsService tts, VoicePersona persona, String label) {
    final isSelected = tts.selectedPersona == persona;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryNavy,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppTheme.textDark,
      ),
      onSelected: (_) => tts.setPersona(persona),
    );
  }
}
