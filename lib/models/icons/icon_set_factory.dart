import '../emotions/emotion_factory.dart';
import 'icon_set_data.dart';
import 'icon_set_type.dart';

// 아이콘 세트 데이터 팩토리 클래스
class IconSetFactory {
  // 모든 아이콘 세트 데이터 생성
  static List<IconSetData> createAllIconSets() {
    return [
      IconSetData(
        type: IconSetType.meboogi,
        name: '메론빵',
        emotions: EmotionFactory.createEmotionsForIconSet('meboogi'),
      ),
      IconSetData(
        type: IconSetType.tomato,
        name: '토마토',
        emotions: EmotionFactory.createEmotionsForIconSet('tomato'),
      ),
      IconSetData(
        type: IconSetType.shark,
        name: '상어',
        emotions: EmotionFactory.createEmotionsForIconSet('shark'),
      ),
    ];
  }
} 