import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../models/app_data.dart';
import '../hooks/app_hooks.dart';

class CalendarTab extends HookConsumerWidget {
  final UseCurrentDate currentDate;
  final String selectedIconSet;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<DateTime?> selectedDay;
  final PageController pageController;

  const CalendarTab({
    super.key,
    required this.currentDate,
    required this.selectedIconSet,
    required this.selectedDate,
    required this.selectedDay,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 임시 다이어리 데이터 (나중에 Firebase 연동 시 교체)
    final diaryEntries = <Map<String, dynamic>>[
      {'emotion': 'great', 'note': '아주 좋은 하루였어요!'},
      {'emotion': 'good', 'note': '좋은 하루였어요!'},
      {'emotion': 'okay', 'note': '보통의 하루였어요.'},
      {'emotion': 'bad', 'note': '안 좋은 하루였어요.'},
      {'emotion': 'angry', 'note': '화가 난 하루였어요.'},
      {'emotion': 'terrible', 'note': '매우 안 좋은 하루였어요.'},
    ];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Stack(
            children: [
              // 중앙에 월 네비게이션 배치
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_left, color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showMonthYearPicker(context, selectedDate, selectedDay, currentDate, pageController);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${AppData.months[selectedDate.value.month - 1]}, ${selectedDate.value.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_right, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              // 오른쪽 TODAY 버튼
              Positioned(
                right: 0,
                top: 0,
                child: ElevatedButton(
                  onPressed: () {
                    // 오늘 날짜로 이동
                    final today = DateTime.now();
                    final todayMonth = DateTime(today.year, today.month, 1);
                    
                    // 현재 표시된 월과 오늘 월이 다르면 해당 월로 이동
                    if (selectedDate.value.year != today.year || selectedDate.value.month != today.month) {
                      final monthDiff = (today.year - currentDate.now.year) * 12 + (today.month - currentDate.now.month);
                      final targetPage = 1000 + monthDiff;
                      pageController.animateToPage(
                        targetPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    
                    // 오늘 날짜 선택
                    selectedDay.value = today;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Calendar with PageView
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (pageIndex) {
              // 페이지가 변경될 때 선택된 날짜 업데이트
              // pageIndex 0이 현재 월, -1이 이전 월, 1이 다음 월
              final newDate = DateTime(
                currentDate.now.year,
                currentDate.now.month + (pageIndex - 1000), // 중앙값 1000을 기준으로
                1,
              );
              selectedDate.value = newDate;
            },
            itemBuilder: (context, pageIndex) {
              // 페이지 인덱스에 따른 날짜 계산
              // pageIndex 0이 현재 월, -1이 이전 월, 1이 다음 월
              final pageDate = DateTime(
                currentDate.now.year,
                currentDate.now.month + (pageIndex - 1000), // 중앙값 1000을 기준으로
                1,
              );
              return _buildCalendar(context, ref, pageDate, diaryEntries, selectedIconSet, selectedDay);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context, WidgetRef ref, DateTime selectedDate, List<Map<String, dynamic>> diaryEntries, String selectedIconSet, ValueNotifier<DateTime?> selectedDay) {
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // 주차별로 날짜들을 그룹화
    List<List<int>> weeks = [];
    List<int> currentWeek = [];
    
    // 첫 주의 빈 칸들
    for (int i = 1; i < firstWeekday; i++) {
      currentWeek.add(0); // 0은 빈 칸을 의미
    }
    
    // 날짜들 추가
    for (int day = 1; day <= daysInMonth; day++) {
      currentWeek.add(day);
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek = [];
      }
    }
    
    // 마지막 주 처리
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(0);
      }
      weeks.add(currentWeek);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 요일 헤더
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: AppData.koreanWeekdays.map((weekday) => 
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      weekday,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: weekday == '일' ? Colors.red.shade600 : 
                               weekday == '토' ? Colors.blue.shade600 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          // 달력 그리드
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: weeks.asMap().entries.map((entry) {
                  final weekIndex = entry.key;
                  final week = entry.value;
                  final isLastRow = weekIndex == weeks.length - 1;
                  
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200, width: 0.3),
                        ),
                      ),
                      child: Row(
                        children: week.asMap().entries.map((dayEntry) {
                          final dayIndex = dayEntry.key;
                          final day = dayEntry.value;
                          final isFirstColumn = dayIndex == 0;
                          
                          // 해당 날짜의 다이어리 찾기 (임시)
                          Map<String, dynamic>? dayDiary;
                          if (day > 0) {
                            // 모든 날에 감정 데이터 표시 (감정 순서대로 순환)
                            final emotionIndex = (day - 1) % diaryEntries.length;
                            dayDiary = diaryEntries[emotionIndex];
                          }
                          
                          return Expanded(
                            child: _buildDayCell(
                              context, 
                              selectedDate, 
                              day,
                              dayDiary,
                              selectedIconSet,
                              selectedDay,
                              isFirstColumn: isFirstColumn,
                              isLastRow: isLastRow,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime selectedDate, int day, Map<String, dynamic>? dayDiary, String iconSetId, ValueNotifier<DateTime?> selectedDay, {bool isFirstColumn = false, bool isLastRow = false}) {
    if (day == 0) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade200, width: 0.3),
            left: isFirstColumn ? BorderSide.none : BorderSide(color: Colors.grey.shade200, width: 0.3),
          ),
        ),
      );
    }

    final currentDate = DateTime(selectedDate.year, selectedDate.month, day);
    final isToday = currentDate.isAtSameMomentAs(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ));
    final isWeekend = currentDate.weekday == 1 || currentDate.weekday == 7; // 주말
    final isSelected = selectedDay.value != null && 
                      selectedDay.value!.year == currentDate.year &&
                      selectedDay.value!.month == currentDate.month &&
                      selectedDay.value!.day == currentDate.day;

    // 실제 다이어리 데이터 사용
    final hasMoodData = dayDiary != null;
    final moodType = dayDiary?['emotion'] != null ? AppData.getEmotionIndex(dayDiary!['emotion']) : 0;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // 이미 선택된 날짜를 다시 탭하면 상세보기
          _showDayDetail(context, currentDate, hasMoodData);
        } else {
          // 새로운 날짜 선택
          selectedDay.value = currentDate;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: isSelected 
            ? Border.all(color: Colors.blue.shade400, width: 1.5)
            : Border(
                right: BorderSide(color: Colors.grey.shade200, width: 0.3),
                left: isFirstColumn ? BorderSide.none : BorderSide(color: Colors.grey.shade200, width: 0.3),
                bottom: isLastRow ? BorderSide.none : BorderSide(color: Colors.grey.shade200, width: 0.3),
              ),
            borderRadius: isSelected ? BorderRadius.circular(6) : BorderRadius.circular(0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isToday ? Colors.blue.shade500 : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                      color: isToday ? Colors.white : 
                             isWeekend ? (currentDate.weekday == 1 ? Colors.red.shade600 : Colors.blue.shade600) : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            if (hasMoodData)
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(top: 26),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final iconSize = (constraints.maxWidth * 0.8).clamp(30.0, 60.0);
                        final emotionAssets = AppData.getEmotionAssetsByIconSet(iconSetId);
                        return Image.asset(
                          emotionAssets[moodType],
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context, ValueNotifier<DateTime> selectedDate, ValueNotifier<DateTime?> selectedDay, UseCurrentDate currentDate, PageController pageController) {
    DateTime tempSelectedDate = selectedDate.value;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: SizedBox(
              width: 350,
              height: 350,
              child: CalendarDatePicker(
                initialDate: tempSelectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  setState(() {
                    tempSelectedDate = date;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '취소',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // 선택된 날짜의 월로 이동
                  final newSelectedDate = DateTime(tempSelectedDate.year, tempSelectedDate.month, 1);
                  selectedDate.value = newSelectedDate;
                  
                  // selectedDay.value에도 선택된 날짜 설정
                  selectedDay.value = tempSelectedDate;
                  
                  // UI 즉시 업데이트
                  setState(() {});
                  
                  // PageController를 해당 월로 이동
                  final monthDiff = (tempSelectedDate.year - currentDate.now.year) * 12 + (tempSelectedDate.month - currentDate.now.month);
                  final targetPage = 1000 + monthDiff;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade500,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, bool hasMoodData) {
    // 해당 날짜의 감정 데이터 가져오기
    Map<String, dynamic>? dayDiary;
    if (hasMoodData) {
      final emotionIndex = (date.day - 1) % 6; // 6가지 감정
      final emotions = ['great', 'good', 'okay', 'bad', 'angry', 'terrible'];
      final emotionLabels = ['아주 좋음', '좋음', '보통', '안 좋음', '화남', '매우 안 좋음'];
      dayDiary = {
        'emotion': emotions[emotionIndex],
        'note': '${emotionLabels[emotionIndex]}의 하루였어요.',
      };
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${date.year}년 ${date.month}월 ${date.day}일',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (hasMoodData && dayDiary != null) ...[
                Text(
                  '기분: ${dayDiary['note']}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                const Text(
                  '이 날의 기록이 없습니다.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 