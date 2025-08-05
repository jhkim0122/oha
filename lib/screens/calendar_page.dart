import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../hooks/app_hooks.dart';
import 'diary_providers.dart';
import 'calendar_tab.dart';
import 'overview_tab.dart';

class CalendarPage extends HookConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDate = useCurrentDate();
    final selectedIconSet = ref.watch(selectedIconSetProvider);
    
    // 현재 선택된 월을 관리
    final selectedDate = useState(DateTime(currentDate.now.year, currentDate.now.month, 1));
    
    // 선택된 날짜 관리
    final selectedDay = useState<DateTime?>(null);
    
    // PageController 추가 - 중앙값 1000을 초기 페이지로 설정
    final pageController = usePageController(initialPage: 1000);
    
    // 탭 인덱스 관리
    final selectedTabIndex = useState(0);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tab Bar
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedTabIndex.value = 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedTabIndex.value == 0 ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Calendar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedTabIndex.value == 0 ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectedTabIndex.value = 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selectedTabIndex.value == 1 ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Overview',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: selectedTabIndex.value == 1 ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: selectedTabIndex.value == 0
                ? CalendarTab(
                    currentDate: currentDate,
                    selectedIconSet: selectedIconSet,
                    selectedDate: selectedDate,
                    selectedDay: selectedDay,
                    pageController: pageController,
                  )
                : const OverviewTab(),
            ),
          ],
        ),
      ),
    );
  }
} 