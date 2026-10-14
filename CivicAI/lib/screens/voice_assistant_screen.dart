import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../providers/language_provider.dart';
import '../services/speech_tts_service.dart';
import '../theme/app_theme.dart';

class VoiceAssistantScreen extends StatefulWidget {
  final String? initialSchemeContext;

  const VoiceAssistantScreen({super.key, this.initialSchemeContext});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.civicOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.mic_rounded, color: AppTheme.civicOrange, size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'JanSeva Voice AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  chat.isRecording
                      ? 'Listening now...'
                      : chat.isThinking
                          ? 'Gemini is thinking...'
                          : 'Online • Multi-Language',
                  style: TextStyle(
                    fontSize: 11,
                    color: chat.isRecording
                        ? AppTheme.civicOrange
                        : chat.isThinking
                            ? AppTheme.primaryIndigo
                            : AppTheme.civicGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Assistant Language',
            icon: Chip(
              label: Text(
                lang.currentLanguage,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              avatar: const Icon(Icons.language, size: 16),
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
            onSelected: (val) => lang.setLanguage(val),
            itemBuilder: (ctx) => LanguageProvider.supportedLanguages.map((l) {
              return PopupMenuItem<String>(
                value: l['name'],
                child: Text('${l['native']} (${l['name']})'),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.civicOrange),
            tooltip: 'Change Voice & Speed',
            onPressed: () => _showVoiceSettingsSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Conversation',
            onPressed: () => chat.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // If recording, show animated speech banner
          if (chat.isRecording)
            AnimatedBuilder(
              animation: _animController,
              builder: (ctx, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: AppTheme.civicOrange.withOpacity(0.15 + (_animController.value * 0.1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        color: AppTheme.civicOrange,
                        size: 20 + (_animController.value * 6),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Listening in ${lang.currentLanguage}... Speak now',
                        style: const TextStyle(
                          color: AppTheme.civicOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length,
              itemBuilder: (ctx, idx) {
                final msg = chat.messages[idx];
                return _buildMessageItem(context, msg, lang.currentLanguage, chat);
              },
            ),
          ),

          // Thinking progress
          if (chat.isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.civicOrange),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Gemini AI is crafting your response...',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Voice & Text Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick Voice Topic Selector Chips
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '🏥 Free Healthcare',
                          query: 'How do I get free hospital treatment under Ayushman Bharat?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '🌾 Farmer ₹6,000',
                          query: 'Am I eligible for the PM-KISAN ₹6,000 annual farmer subsidy?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '🛒 Vendor Loan',
                          query: 'How can street vendors get a collateral-free loan under PM SVANidhi?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '🏠 House Grant',
                          query: 'What financial assistance is given for building a house under PMAY?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '👧 Daughter Savings',
                          query: 'Tell me about the Sukanya Samriddhi savings scheme for my daughter.',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '👵 Pension (APY)',
                          query: 'How do I apply for the Atal Pension Yojana after age 60?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '🎓 Scholarship',
                          query: 'What are the eligibility criteria for the National Post-Matric Scholarship?',
                        ),
                        _buildQuickTopicPill(
                          chat: chat,
                          lang: lang.currentLanguage,
                          contextScheme: widget.initialSchemeContext,
                          label: '📍 Nearest Kendra',
                          query: 'Where is my nearest Common Service Center (CSC) located?',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Voice Mic Button
                      GestureDetector(
                        onTap: () {
                          chat.toggleVoiceRecording(
                            language: lang.currentLanguage,
                            schemeContext: widget.initialSchemeContext,
                          );
                          _scrollToBottom();
                        },
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (ctx, child) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chat.isRecording ? AppTheme.civicOrange : AppTheme.primaryNavy,
                            boxShadow: chat.isRecording
                                ? [
                                    BoxShadow(
                                      color: AppTheme.civicOrange.withOpacity(0.5),
                                      blurRadius: 10 + (_animController.value * 8),
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            chat.isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type or speak your question...',
                        hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          chat.sendMessage(
                            text: val.trim(),
                            language: lang.currentLanguage,
                            schemeContext: widget.initialSchemeContext,
                          );
                          _textController.clear();
                          _scrollToBottom();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primaryIndigo),
                    onPressed: () {
                      final val = _textController.text.trim();
                      if (val.isNotEmpty) {
                        chat.sendMessage(
                          text: val,
                          language: lang.currentLanguage,
                          schemeContext: widget.initialSchemeContext,
                        );
                        _textController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
);
}

  Widget _buildMessageItem(
    BuildContext context,
    ChatMessage msg,
    String currentLanguage,
    ChatProvider chat,
  ) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.civicOrange, Color(0xFFFF8A00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primaryNavy : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                    ),
                    border: isUser ? null : Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isUser ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                      if (!isUser) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => chat.playMessageVoice(msg, currentLanguage),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.lightBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      chat.ttsService.isPlaying &&
                                              chat.ttsService.currentlySpeakingTextId == msg.id
                                          ? Icons.stop_circle_rounded
                                          : Icons.volume_up_rounded,
                                      size: 14,
                                      color: AppTheme.civicOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      chat.ttsService.isPlaying &&
                                              chat.ttsService.currentlySpeakingTextId == msg.id
                                          ? 'Stop'
                                          : 'Listen Voice',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.civicOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser && msg.isVoice) ...[
                const SizedBox(width: 6),
                const Icon(Icons.mic, size: 16, color: AppTheme.civicOrange),
              ],
            ],
          ),

          // Quick Action Suggestion Chips
          if (msg.quickActions != null && msg.quickActions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: msg.quickActions!.map((qa) {
                return ActionChip(
                  label: Text(qa),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.borderLight),
                  onPressed: () {
                    chat.sendMessage(
                      text: qa,
                      language: currentLanguage,
                      schemeContext: widget.initialSchemeContext,
                    );
                    _scrollToBottom();
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showVoiceSettingsSheet(BuildContext context) {
    final lang = context.read<LanguageProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<SpeechTtsService>(
          builder: (context, tts, child) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.record_voice_over_rounded, color: AppTheme.civicOrange, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Customize Assistant Voice',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select the voice persona, speech cadence, and pitch that feels most comfortable for you.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const Divider(height: 24),

                  const Text('Voice Persona', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),

                  // Persona choices
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPersonaChip(
                        tts: tts,
                        persona: VoicePersona.female,
                        label: '👩 Priya (Warm Female)',
                      ),
                      _buildPersonaChip(
                        tts: tts,
                        persona: VoicePersona.male,
                        label: '👨 Aarav (Clear Male)',
                      ),
                      _buildPersonaChip(
                        tts: tts,
                        persona: VoicePersona.elderFriendly,
                        label: '👵 Elder-Friendly (Slow & Patient)',
                      ),
                      _buildPersonaChip(
                        tts: tts,
                        persona: VoicePersona.standard,
                        label: '🎙️ Standard Natural',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Speed Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Speech Speed / Rate', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

                  // Pitch Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Voice Pitch', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

                  const SizedBox(height: 16),

                  // Test Preview Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.civicOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        tts.isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                        size: 20,
                      ),
                      label: Text(
                        tts.isPlaying ? 'Stop Voice Sample' : 'Test Voice Preview (${lang.currentLanguage})',
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
        );
      },
    );
  }

  Widget _buildPersonaChip({
    required SpeechTtsService tts,
    required VoicePersona persona,
    required String label,
  }) {
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

  Widget _buildQuickTopicPill({
    required ChatProvider chat,
    required String lang,
    required String? contextScheme,
    required String label,
    required String query,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
        backgroundColor: AppTheme.lightBg,
        side: const BorderSide(color: AppTheme.borderLight),
        onPressed: () {
          chat.sendMessage(
            text: query,
            language: lang,
            isVoiceInput: true,
            schemeContext: contextScheme,
          );
          _scrollToBottom();
        },
      ),
    );
  }
}
