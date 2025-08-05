import 'package:hooks_riverpod/hooks_riverpod.dart';

// DiaryPage 관련 provider
final selectedEmotionProvider = StateProvider<String?>((ref) => null);
final noteProvider = StateProvider<String>((ref) => '');
final selectedIconSetProvider = StateProvider<String>((ref) => 'meboogi'); // 기본값은 meboogi

// MainScreen의 BottomNavigationBar 인덱스 provider
final mainScreenIndexProvider = StateProvider<int>((ref) => 0); 