import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'diary_providers.dart';
import 'diary_write_page.dart';
import '../models/app_data.dart';
import '../hooks/app_hooks.dart';
import '../widgets/common_widgets.dart';

class DiaryPage extends HookConsumerWidget {
  final String? selectedEmotion;
  final String note;
  final String selectedIconSet;
  final Function(String?)? onEmotionChanged;
  final Function(String)? onNoteChanged;
  final Function(String)? onIconSetChanged;

  const DiaryPage({
    super.key,
    this.selectedEmotion,
    this.note = '',
    this.selectedIconSet = 'meboogi',
    this.onEmotionChanged,
    this.onNoteChanged,
    this.onIconSetChanged,
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteController = useTextEditingController(text: note);
    final emotionData = useEmotionData(ref, selectedIconSet);
    final keyboardDismiss = useKeyboardDismiss();

    useEffect(() {
      noteController.text = note;
      return null;
    }, [note]);

    final now = DateTime.now();
    final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
                   'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    final weekdays = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${months[now.month - 1]}, ${now.day}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        weekdays[now.weekday - 1],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20), // 설정 버튼 제거 후 공간 유지
                ],
              ),
              const Spacer(),
              // Main Question
              const Center(
                child: Text(
                  '오늘 하루는 어땠나요?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (emotionData.selectedEmotion == null) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => _showEmotionSelector(context, emotionData),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E5E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                _buildEmotionDisplay(context, emotionData),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmotionDisplay(BuildContext context, UseEmotionData emotionData) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                right: 92,
                child: GestureDetector(
                  onTap: () {
                    emotionData.clearEmotion();
                    onNoteChanged?.call('');
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Center(
                child: EmotionIcon(
                  emotionId: emotionData.selectedEmotion!.id,
                  iconSetId: selectedIconSet,
                  size: 120,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            _showEmotionSelector(context, emotionData);
          },
          child: const Text(
            '다시 선택하기',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // 마음 기록하기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiaryWritePage(
                    selectedEmotion: emotionData.selectedEmotion!.id,
                    selectedIconSet: selectedIconSet,
                    initialNote: note,
                    onNoteChanged: onNoteChanged,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              '마음 기록하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmotionSelector(BuildContext context, UseEmotionData emotionData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  '오늘의 기분을 선택해주세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 24,
                    alignment: WrapAlignment.spaceEvenly,
                    children: emotionData.emotions.map((emotion) => EmotionSelectorItem(
                      emotion: emotion,
                      onSelect: () {
                        emotionData.selectEmotion(emotion.id);
                        Navigator.pop(context);
                      },
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }


}

 