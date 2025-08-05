import 'emotion_data.dart';
import 'emotion_type.dart';

// 감정 데이터 팩토리 클래스
class EmotionFactory {
  // 아이콘 세트별 감정 데이터 생성
  static List<EmotionData> createEmotionsForIconSet(String iconSetId) {
    final basePath = 'assets/images/moods/$iconSetId';
    
    return [
      EmotionData(
        type: EmotionType.great,
        label: '아주 좋음',
        assetPath: '$basePath/mood_happy.png',
      ),
      EmotionData(
        type: EmotionType.good,
        label: '좋음',
        assetPath: '$basePath/mood_smile.png',
      ),
      EmotionData(
        type: EmotionType.okay,
        label: '보통',
        assetPath: '$basePath/mood_emotionless.png',
      ),
      EmotionData(
        type: EmotionType.bad,
        label: '안 좋음',
        assetPath: '$basePath/mood_down.png',
      ),
      EmotionData(
        type: EmotionType.angry,
        label: '화남',
        assetPath: '$basePath/mood_angry.png',
      ),
      EmotionData(
        type: EmotionType.terrible,
        label: '매우 안 좋음',
        assetPath: '$basePath/mood_sad.png',
      ),
    ];
  }
} 