import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'ai_chat_page.dart';
import '../models/app_data.dart';
import '../hooks/app_hooks.dart';
import '../widgets/common_widgets.dart';

class DiaryWritePage extends HookConsumerWidget {
  final String selectedEmotion;
  final String selectedIconSet;
  final String initialNote;
  final Function(String)? onNoteChanged;

  const DiaryWritePage({
    super.key,
    required this.selectedEmotion,
    required this.selectedIconSet,
    this.initialNote = '',
    this.onNoteChanged,
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteController = useTextEditingController(text: initialNote);
    final currentDate = useCurrentDate();
    final diarySave = useDiarySave(ref);
    final keyboardDismiss = useKeyboardDismiss();
    
    final emotion = AppData.getEmotionById(selectedEmotion, selectedIconSet);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${currentDate.monthName}, ${currentDate.now.day}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await diarySave.saveDiary(
                  selectedEmotion,
                  noteController.text,
                  selectedIconSet,
                );
                
                // 로컬 상태 업데이트
                onNoteChanged?.call(noteController.text);
                
                // 성공 메시지 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('다이어리가 저장되었습니다!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                // 오류 메시지 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('저장에 실패했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              '저장',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: keyboardDismiss.dismissKeyboard,
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 
                     MediaQuery.of(context).padding.top - 
                     kToolbarHeight,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 감정 표시
                  Center(
                    child: Column(
                      children: [
                        EmotionIcon(
                          emotionId: selectedEmotion,
                          iconSetId: selectedIconSet,
                          size: 80,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 제목
                  const Text(
                    '오늘 기록하기',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 일기 작성 영역
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: noteController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (value) => onNoteChanged?.call(value),
                        onTapOutside: (event) {
                          keyboardDismiss.dismissKeyboard();
                        },
                        cursorColor: Colors.black,
                        decoration: const InputDecoration(
                          hintText: '오늘 하루는 어땠나요?\n\n무슨 일이 있었는지, 어떤 생각을 했는지 자유롭게 적어보세요...',
                          hintStyle: TextStyle(
                            color: Colors.black38,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // AI 상담 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AIChatPage(
                              selectedEmotion: selectedEmotion,
                              selectedIconSet: selectedIconSet,
                              diaryContent: noteController.text,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: const Text(
                        '오늘 일기로 AI와 상담하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 