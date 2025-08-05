// 앱 전체에서 사용하는 공통 데이터 모델들
// 이 파일은 기존 코드와의 호환성을 위해 유지되며, 내부적으로는 새로운 구조를 사용합니다.

import 'utils/date_utils.dart';
import 'utils/emotion_utils.dart';
import 'icons/icon_set_factory.dart';
import 'emotions/emotion_data.dart';
import 'icons/icon_set_data.dart';

// 앱 전체 데이터 관리 클래스
class AppData {
  // 기존 코드와의 호환성을 위한 정적 메서드들
  
  // 월 이름 배열
  static List<String> get months => DateUtils.months;

  // 요일 이름 배열
  static List<String> get weekdays => DateUtils.weekdays;

  // 한국어 요일 배열
  static List<String> get koreanWeekdays => DateUtils.koreanWeekdays;

  // 아이콘 세트 데이터 (기존 코드와의 호환성을 위해 유지)
  static List<IconSetData> get iconSets => IconSetFactory.createAllIconSets();

  // 아이콘 세트 ID로 데이터 가져오기
  static IconSetData? getIconSetById(String id) {
    return EmotionUtils.getIconSetById(id);
  }

  // 감정 ID로 감정 데이터 가져오기
  static EmotionData? getEmotionById(String emotionId, String iconSetId) {
    return EmotionUtils.getEmotionById(emotionId, iconSetId);
  }

  // 감정 ID로 인덱스 가져오기
  static int getEmotionIndex(String emotionId) {
    return EmotionUtils.getEmotionIndex(emotionId);
  }

  // 인덱스로 감정 ID 가져오기
  static String getEmotionIdByIndex(int index) {
    return EmotionUtils.getEmotionIdByIndex(index);
  }

  // 아이콘 세트의 모든 감정 데이터 가져오기
  static List<EmotionData> getEmotionsByIconSet(String iconSetId) {
    return EmotionUtils.getEmotionsByIconSet(iconSetId);
  }

  // 아이콘 세트의 감정 에셋 경로들 가져오기
  static List<String> getEmotionAssetsByIconSet(String iconSetId) {
    return EmotionUtils.getEmotionAssetsByIconSet(iconSetId);
  }
} 