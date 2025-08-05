import '../emotions/emotion_data.dart';
import '../icons/icon_set_data.dart';
import '../icons/icon_set_factory.dart';

// 감정 관련 유틸리티
class EmotionUtils {
  // 아이콘 세트 ID로 데이터 가져오기
  static IconSetData? getIconSetById(String id) {
    final iconSets = IconSetFactory.createAllIconSets();
    try {
      return iconSets.firstWhere((iconSet) => iconSet.id == id);
    } catch (e) {
      return null;
    }
  }

  // 감정 ID로 감정 데이터 가져오기
  static EmotionData? getEmotionById(String emotionId, String iconSetId) {
    final iconSet = getIconSetById(iconSetId);
    if (iconSet == null) return null;
    
    try {
      return iconSet.emotions.firstWhere((emotion) => emotion.id == emotionId);
    } catch (e) {
      return null;
    }
  }

  // 감정 ID로 인덱스 가져오기
  static int getEmotionIndex(String emotionId) {
    switch (emotionId) {
      case 'great': return 0;
      case 'good': return 1;
      case 'okay': return 2;
      case 'bad': return 3;
      case 'angry': return 4;
      case 'terrible': return 5;
      default: return 2; // 기본값은 'okay'
    }
  }

  // 인덱스로 감정 ID 가져오기
  static String getEmotionIdByIndex(int index) {
    switch (index) {
      case 0: return 'great';
      case 1: return 'good';
      case 2: return 'okay';
      case 3: return 'bad';
      case 4: return 'angry';
      case 5: return 'terrible';
      default: return 'okay';
    }
  }

  // 아이콘 세트의 모든 감정 데이터 가져오기
  static List<EmotionData> getEmotionsByIconSet(String iconSetId) {
    final iconSet = getIconSetById(iconSetId);
    return iconSet?.emotions ?? [];
  }

  // 아이콘 세트의 감정 에셋 경로들 가져오기
  static List<String> getEmotionAssetsByIconSet(String iconSetId) {
    final emotions = getEmotionsByIconSet(iconSetId);
    return emotions.map((emotion) => emotion.assetPath).toList();
  }
} 