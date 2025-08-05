import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../models/emotions/emotion_data.dart';
import '../models/icons/icon_set_data.dart';

// 감정 선택 아이템 위젯
class EmotionSelectorItem extends StatefulWidget {
  final EmotionData emotion;
  final VoidCallback onSelect;
  final bool isSelected;

  const EmotionSelectorItem({
    super.key,
    required this.emotion,
    required this.onSelect,
    this.isSelected = false,
  });

  @override
  State<EmotionSelectorItem> createState() => _EmotionSelectorItemState();
}

class _EmotionSelectorItemState extends State<EmotionSelectorItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
        
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            widget.onSelect();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.isSelected ? Colors.black.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                widget.emotion.assetPath,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

// 아이콘 세트 선택 아이템 위젯
class IconSetSelectorItem extends StatefulWidget {
  final IconSetData iconSet;
  final bool isSelected;
  final Function(String) onSelect;

  const IconSetSelectorItem({
    super.key,
    required this.iconSet,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<IconSetSelectorItem> createState() => _IconSetSelectorItemState();
}

class _IconSetSelectorItemState extends State<IconSetSelectorItem>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
        });
        _animationController.reverse();
        widget.onSelect(widget.iconSet.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: widget.isSelected 
                    ? Border.all(color: Colors.black45, width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      widget.iconSet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.iconSet.emotions.map((emotion) => 
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: Image.asset(
                            emotion.assetPath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ).toList(),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// 감정 아이콘 위젯
class EmotionIcon extends StatelessWidget {
  final String emotionId;
  final String iconSetId;
  final double? size;
  final BoxFit fit;

  const EmotionIcon({
    super.key,
    required this.emotionId,
    required this.iconSetId,
    this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final emotion = AppData.getEmotionById(emotionId, iconSetId);
    if (emotion == null) {
      return const SizedBox.shrink();
    }

    return Image.asset(
      emotion.assetPath,
      width: size,
      height: size,
      fit: fit,
    );
  }
}

// 로딩 인디케이터 위젯
class LoadingIndicator extends StatelessWidget {
  final String message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message = '로딩 중...',
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          message,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// 에러 메시지 위젯
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
} 