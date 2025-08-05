import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/app_data.dart';
import '../models/emotions/emotion_data.dart';
import '../screens/diary_providers.dart';

// 현재 날짜 관련 훅
class UseCurrentDate {
  final DateTime now;
  final String monthName;
  final String weekdayName;
  final String koreanWeekdayName;

  UseCurrentDate({
    required this.now,
    required this.monthName,
    required this.weekdayName,
    required this.koreanWeekdayName,
  });
}

UseCurrentDate useCurrentDate() {
  final now = useState(DateTime.now());
  
  // 매일 자정에 날짜 업데이트
  useEffect(() {
    final timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final currentTime = DateTime.now();
      if (currentTime.day != now.value.day || 
          currentTime.month != now.value.month || 
          currentTime.year != now.value.year) {
        now.value = currentTime;
      }
    });
    
    return timer.cancel;
  }, []);

  return UseCurrentDate(
    now: now.value,
    monthName: AppData.months[now.value.month - 1],
    weekdayName: AppData.weekdays[now.value.weekday - 1],
    koreanWeekdayName: AppData.koreanWeekdays[now.value.weekday - 1],
  );
}

// 감정 데이터 관련 훅
class UseEmotionData {
  final List<EmotionData> emotions;
  final EmotionData? selectedEmotion;
  final Function(String) selectEmotion;
  final Function() clearEmotion;

  UseEmotionData({
    required this.emotions,
    required this.selectedEmotion,
    required this.selectEmotion,
    required this.clearEmotion,
  });
}

UseEmotionData useEmotionData(WidgetRef ref, String iconSetId) {
  final selectedEmotionId = ref.watch(selectedEmotionProvider);
  final emotions = useMemoized(() => AppData.getEmotionsByIconSet(iconSetId), [iconSetId]);
  
  final selectedEmotion = useMemoized(() {
    if (selectedEmotionId == null) return null;
    return AppData.getEmotionById(selectedEmotionId, iconSetId);
  }, [selectedEmotionId, iconSetId]);

  final selectEmotion = useCallback((String emotionId) {
    ref.read(selectedEmotionProvider.notifier).state = emotionId;
  }, [ref]);

  final clearEmotion = useCallback(() {
    ref.read(selectedEmotionProvider.notifier).state = null;
  }, [ref]);

  return UseEmotionData(
    emotions: emotions,
    selectedEmotion: selectedEmotion,
    selectEmotion: selectEmotion,
    clearEmotion: clearEmotion,
  );
}

// 다이어리 저장 관련 훅 (로컬 저장)
class UseDiarySave {
  final bool isSaving;
  final String? error;
  final Future<void> Function(String emotion, String note, String iconSet) saveDiary;

  UseDiarySave({
    required this.isSaving,
    required this.error,
    required this.saveDiary,
  });
}

UseDiarySave useDiarySave(WidgetRef ref) {
  final isSaving = useState(false);
  final error = useState<String?>(null);

  final saveDiary = useCallback((String emotion, String note, String iconSet) async {
    isSaving.value = true;
    error.value = null;
    
    try {
      // 로컬 상태 업데이트만 수행
      ref.read(noteProvider.notifier).state = note;
      
      // 나중에 Firebase 연동 시 여기에 저장 로직 추가
      await Future.delayed(const Duration(milliseconds: 500)); // 임시 딜레이
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isSaving.value = false;
    }
  }, [ref]);

  return UseDiarySave(
    isSaving: isSaving.value,
    error: error.value,
    saveDiary: saveDiary,
  );
}

// 키보드 관련 훅
class UseKeyboardDismiss {
  final VoidCallback dismissKeyboard;

  UseKeyboardDismiss({
    required this.dismissKeyboard,
  });
}

UseKeyboardDismiss useKeyboardDismiss() {
  final dismissKeyboard = useCallback(() {
    FocusManager.instance.primaryFocus?.unfocus();
  }, []);

  return UseKeyboardDismiss(
    dismissKeyboard: dismissKeyboard,
  );
} 