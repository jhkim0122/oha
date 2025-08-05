import 'emotion_type.dart';

// 감정 데이터 모델
class EmotionData {
  final EmotionType type;
  final String label;
  final String assetPath;

  const EmotionData({
    required this.type,
    required this.label,
    required this.assetPath,
  });

  String get id => type.id;
} 