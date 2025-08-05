import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/app_data.dart';
import '../hooks/app_hooks.dart';
import '../widgets/common_widgets.dart';

class AIChatPage extends HookConsumerWidget {
  final String selectedEmotion;
  final String selectedIconSet;
  final String diaryContent;

  const AIChatPage({
    super.key,
    required this.selectedEmotion,
    required this.selectedIconSet,
    required this.diaryContent,
  });



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = useState<List<ChatMessage>>([]);
    final textController = useTextEditingController();
    final isLoading = useState(false);
    final scrollController = useScrollController();
    final keyboardDismiss = useKeyboardDismiss();

    final emotion = AppData.getEmotionById(selectedEmotion, selectedIconSet);

    // 초기 메시지 설정
    useEffect(() {
      if (messages.value.isEmpty) {
        final initialMessage = ChatMessage(
          text: '안녕하세요! 오늘 하루는 ${emotion?.label ?? '알 수 없음'}이시군요. 일기를 읽어보고 상담해드릴게요.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        messages.value = [initialMessage];
        
        // AI가 일기를 분석하고 상담 시작
        _analyzeDiaryAndStartConsultation(messages, diaryContent);
      }
      return null;
    }, []);

    void _sendMessage() async {
      if (textController.text.trim().isEmpty) return;

      final userMessage = ChatMessage(
        text: textController.text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      messages.value = [...messages.value, userMessage];
      textController.clear();

      // AI 응답 생성
      isLoading.value = true;
      await _generateAIResponse(messages, userMessage.text);
      isLoading.value = false;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            EmotionIcon(
              emotionId: selectedEmotion,
              iconSetId: selectedIconSet,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'AI 상담사',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: keyboardDismiss.dismissKeyboard,
        child: Column(
          children: [
            // 채팅 메시지 영역
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.value.length + (isLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.value.length && isLoading.value) {
                    return _buildLoadingMessage();
                  }
                  return _buildMessage(messages.value[index]);
                },
              ),
            ),
            // 입력 영역
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          hintText: '메시지를 입력하세요...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        onTapOutside: (event) {
                          keyboardDismiss.dismissKeyboard();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade600 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const LoadingIndicator(
              message: '생각 중',
              size: 16,
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _analyzeDiaryAndStartConsultation(
    ValueNotifier<List<ChatMessage>> messages,
    String diaryContent,
  ) async {
    if (diaryContent.trim().isEmpty) {
      final message = ChatMessage(
        text: '일기 내용이 없네요. 오늘 하루에 대해 이야기해주세요!',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.value = [...messages.value, message];
      return;
    }

    final prompt = '''
당신은 따뜻하고 공감적인 AI 상담사입니다. 사용자의 일기를 읽고 상담해주세요.

일기 내용: $diaryContent

위 내용을 바탕으로:
1. 공감을 표현하고
2. 일기 내용에 대한 관찰을 해주고
3. 적절한 조언이나 격려를 제공해주세요.

답변은 친근하고 따뜻한 톤으로, 2-3문장 정도로 작성해주세요.
''';

    await _generateAIResponse(messages, prompt, isInitialMessage: true);
  }

  Future<void> _generateAIResponse(
    ValueNotifier<List<ChatMessage>> messages,
    String userInput, {
    bool isInitialMessage = false,
  }) async {
    try {
      // Gemini API 키 (Google AI Studio에서 발급)
      const apiKey = 'AIzaSyBWDZIlkfEIuZURtC_5AF6uLVvS3AaG9tQ'; // 여기에 실제 Gemini API 키를 넣으세요
      
      // Gemini 모델 초기화
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 300,
        ),
      );

      String prompt;
      if (isInitialMessage) {
        final emotion = AppData.getEmotionById(selectedEmotion, selectedIconSet);
        prompt = '''
당신은 따뜻하고 공감적인 AI 상담사입니다. 사용자의 일기를 읽고 상담해주세요.

사용자의 기분: ${emotion?.label ?? '알 수 없음'}
일기 내용: $diaryContent

위 내용을 바탕으로:
1. 공감을 표현하고
2. 일기 내용에 대한 관찰을 해주고
3. 적절한 조언이나 격려를 제공해주세요.

답변은 친근하고 따뜻한 톤으로, 2-3문장 정도로 작성해주세요.
''';
      } else {
        prompt = '''
당신은 따뜻하고 공감적인 AI 상담사입니다. 사용자의 메시지에 대해 상담해주세요.

사용자 메시지: $userInput

위 메시지에 대해 공감적이고 도움이 되는 답변을 해주세요. 
답변은 친근하고 따뜻한 톤으로, 1-2문장 정도로 작성해주세요.
정신의학적으로 조언을 제공해주세요.
''';
      }

      // Gemini API 호출
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        final aiResponse = response.text!.trim();

        final aiMessage = ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        );

        messages.value = [...messages.value, aiMessage];
      } else {
        throw Exception('Gemini API 응답이 비어있습니다.');
      }
    } catch (e) {
      print('Gemini API 오류: $e');
      final errorMessage = ChatMessage(
        text: '죄송합니다. 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      messages.value = [...messages.value, errorMessage];
    }
  }


}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 