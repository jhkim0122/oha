import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'diary_providers.dart';
import 'diary_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenIndexProvider);
    
    final selectedEmotion = ref.watch(selectedEmotionProvider);
    final note = ref.watch(noteProvider);
    final selectedIconSet = ref.watch(selectedIconSetProvider);
    

    
    return Scaffold(
      body: _buildContent(context, ref, currentIndex, selectedEmotion, note, selectedIconSet),
      bottomNavigationBar: _buildBottomNavigation(ref, currentIndex),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, int currentIndex, 
      String? selectedEmotion, String note, String selectedIconSet) {
    switch (currentIndex) {
      case 0:
        return DiaryPage(
          selectedEmotion: selectedEmotion,
          note: note,
          selectedIconSet: selectedIconSet,
          onEmotionChanged: (emotion) => ref.read(selectedEmotionProvider.notifier).state = emotion,
          onNoteChanged: (note) => ref.read(noteProvider.notifier).state = note,
          onIconSetChanged: (iconSet) => ref.read(selectedIconSetProvider.notifier).state = iconSet,
        );
      case 1:
        return const CalendarPage();
      case 2:
        return const SettingsPage();
      default:
        return DiaryPage(
          selectedEmotion: selectedEmotion,
          note: note,
          selectedIconSet: selectedIconSet,
          onEmotionChanged: (emotion) => ref.read(selectedEmotionProvider.notifier).state = emotion,
          onNoteChanged: (note) => ref.read(noteProvider.notifier).state = note,
          onIconSetChanged: (iconSet) => ref.read(selectedIconSetProvider.notifier).state = iconSet,
        );
    }
  }

  Widget _buildBottomNavigation(WidgetRef ref, int currentIndex) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(mainScreenIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined, size: 24),
            activeIcon: Icon(Icons.edit, size: 24),
            label: '일기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined, size: 24),
            activeIcon: Icon(Icons.calendar_month, size: 24),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 24),
            activeIcon: Icon(Icons.settings, size: 24),
            label: '설정',
          ),
        ],
      ),
    );
  }
} 