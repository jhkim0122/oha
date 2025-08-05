import '../emotions/emotion_data.dart';
import 'icon_set_type.dart';

// 아이콘 세트 데이터 모델
class IconSetData {
  final IconSetType type;
  final String name;
  final List<EmotionData> emotions;

  const IconSetData({
    required this.type,
    required this.name,
    required this.emotions,
  });

  String get id => type.id;
} 