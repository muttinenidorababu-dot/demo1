enum MessageSender { user, assistant, system }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final String? audioPath;
  final bool isVoice;
  final List<String>? quickActions;
  final String? referencedSchemeId;
  final bool isSpeaking;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.audioPath,
    this.isVoice = false,
    this.quickActions,
    this.referencedSchemeId,
    this.isSpeaking = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    String? audioPath,
    bool? isVoice,
    List<String>? quickActions,
    String? referencedSchemeId,
    bool? isSpeaking,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      audioPath: audioPath ?? this.audioPath,
      isVoice: isVoice ?? this.isVoice,
      quickActions: quickActions ?? this.quickActions,
      referencedSchemeId: referencedSchemeId ?? this.referencedSchemeId,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}
