class ChatMessageModel {
  final String role;      // "user" | "assistant"
  final String content;
  final DateTime timestamp;

  ChatMessageModel({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role':    role,
    'content': content,
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      role:    json['role'] as String,
      content: json['content'] as String,
    );
  }
}