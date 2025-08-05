import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryEntry {
  final String id;
  final String userId;
  final String emotion;
  final String note;
  final String iconSet;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ChatMessage>? chatHistory;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.emotion,
    required this.note,
    required this.iconSet,
    required this.createdAt,
    this.updatedAt,
    this.chatHistory,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory DiaryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      id: doc.id,
      userId: dsata['userId'] ?? '',
      emotion: data['emotion'] ?? '',
      note: data['note'] ?? '',
      iconSet: data['iconSet'] ?? 'meboogi',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      chatHistory: data['chatHistory'] != null
          ? (data['chatHistory'] as List)
              .map((chat) => ChatMessage.fromMap(chat))
              .toList()
          : null,
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'emotion': emotion,
      'note': note,
      'iconSet': iconSet,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'chatHistory': chatHistory?.map((chat) => chat.toMap()).toList(),
    };
  }

  // 데이터 복사 및 수정
  DiaryEntry copyWith({
    String? id,
    String? userId,
    String? emotion,
    String? note,
    String? iconSet,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? chatHistory,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emotion: emotion ?? this.emotion,
      note: note ?? this.note,
      iconSet: iconSet ?? this.iconSet,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Firestore에서 데이터를 가져올 때 사용
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // Firestore에 데이터를 저장할 때 사용
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
} 