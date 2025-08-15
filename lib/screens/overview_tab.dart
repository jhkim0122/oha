import 'dart:async' as dart_async;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/app_data.dart';
import '../hooks/app_hooks.dart';
import 'diary_providers.dart';

class OverviewTab extends HookConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIconSet = ref.watch(selectedIconSetProvider);
    final currentDate = useCurrentDate();
    final showShakeMessage = useState(false);
    final isShaken = useState(false);
    final isAnimating = useState(false);

    final currentMonthEmotions = <String>[];
    final daysInMonth = DateTime(currentDate.now.year, currentDate.now.month + 1, 0).day;
    final emotionSet = ['great', 'good', 'okay', 'bad', 'angry', 'terrible'];
    for (int day = 1; day <= daysInMonth; day++) {
      currentMonthEmotions.add(emotionSet[(day - 1) % emotionSet.length]);
    }

    final game = useMemoized(() => GravityGame(
      emotions: currentMonthEmotions,
      iconSetId: selectedIconSet,
      onAnimationComplete: () {
        isAnimating.value = false;
        isShaken.value = false;
      },
    ), []); // 빈 의존성 배열로 한 번만 생성

    useEffect(() {
      if (!isAnimating.value && isShaken.value) {
        Future.delayed(const Duration(seconds: 3), () {
          isShaken.value = false;
          showShakeMessage.value = false;
        });
      }
    }, [isAnimating.value, isShaken.value]);

    useEffect(() {
        Future.delayed(const Duration(milliseconds: 500), () {
        if (!isAnimating.value && !isShaken.value) {
          Fluttertoast.showToast(
            msg: "화면을 탭하거나 기기를 흔들어보세요!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    }, []); // 빈 의존성 배열로 한 번만 실행

    useEffect(() {
      if ((showShakeMessage.value && !isShaken.value) || (!isAnimating.value && !isShaken.value)) {
        final subscription = accelerometerEvents.listen((event) {
          final speed = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          if (speed > 12.0) {
            isShaken.value = true;
            showShakeMessage.value = false;
            isAnimating.value = true;
            game.startAnimation();
          }
        });
        return subscription.cancel;
      }
      return null;
    }, [showShakeMessage.value, isShaken.value, isAnimating.value]);

    return GestureDetector(
      onTap: () {
          isShaken.value = true;
          showShakeMessage.value = false;
          isAnimating.value = true;
          game.startAnimation();
      },
      child: SizedBox.expand(
        child: GameWidget(
          game: game,
        ),
      ),
    );
  }
}

class GravityGame extends Forge2DGame {
  final List<String> emotions;
  final String iconSetId;
  final VoidCallback? onAnimationComplete;

  GravityGame({
    required this.emotions,
    required this.iconSetId,
    this.onAnimationComplete,
  }) : super(gravity: Vector2(0, 160), zoom: 1.0);

  int _landedCount = 0;
  int _totalItems = 0;
  bool _animationStarted = false;
  bool _animationCompleted = false;
  double _settleTimer = 0.0;
  static const double _settleDelay = 1.0; // 1초간 정지 상태 유지 후 완료로 판단
  dart_async.Timer? _forceResetTimer; // 애니메이션 시작 후 10초 강제 복귀 타이머

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white,
    ));
    
    final emotionAssets = AppData.getEmotionAssetsByIconSet(iconSetId);
    for (final assetPath in emotionAssets) {
      final cleanPath = assetPath.replaceFirst('assets/images/', '');
      try {
        await images.load(cleanPath);
        print('Successfully loaded: $cleanPath');
      } catch (e) {
        print('Failed to load: $cleanPath - $e');
      }
    }

    add(Ground(size));
    
    add(Wall(Vector2(10, size.y / 2), Vector2(20, size.y)));
    add(Wall(Vector2(size.x - 10, size.y / 2), Vector2(20, size.y)));
    add(Wall(Vector2(size.x / 2, 10), Vector2(size.x, 20)));

    _totalItems = emotions.length;

    for (int i = 0; i < emotions.length; i++) {
      final emotion = emotions[i];
      final emotionIndex = AppData.getEmotionIndex(emotion);
      final assetPath = emotionAssets[emotionIndex];

      final screenWidth = size.x;
      final itemsPerRow = 5;
      final itemWidth = screenWidth / itemsPerRow;
      
      final centerX = screenWidth / 2;
      final row = i ~/ itemsPerRow;
      final col = i % itemsPerRow;
      
      final padding = 20.0;
      final spacing = 12.0;
      final itemSize = 60.0;
      
      final totalGridWidth = itemsPerRow * itemSize + (itemsPerRow - 1) * spacing;
      final gridStartX = (screenWidth - totalGridWidth) / 2;
      final startX = gridStartX + (col * (itemSize + spacing)) + (itemSize / 2);
      final startY = padding + (row * (itemSize + spacing)) + (itemSize / 2);

      add(
        FallingEmotionBody(
          assetPath: assetPath,
          position: Vector2(startX, startY),
          onLanded: _onItemLanded,
          isStatic: true,
        ),
      );
    }
  }

  void startAnimation() {
    if (_animationStarted) return;
    print('🚀 애니메이션 시작!');
    _animationStarted = true;
    _animationCompleted = false;
    _settleTimer = 0.0;
    _landedCount = 0;
    _forceResetTimer?.cancel();
    _forceResetTimer = dart_async.Timer(const Duration(seconds: 15), () {
      if (!_animationStarted) return;
      _animationCompleted = true;
      onAnimationComplete?.call();
      _resetToInitialState();
    });
    
    final bodies = children.whereType<FallingEmotionBody>().toList();
    for (final body in bodies) {
      body.startFalling();
    }
  }

  void _onItemLanded() {
    _landedCount++;
    
    if (_landedCount >= _totalItems) {
      print('🎉 모든 아이템이 착지했습니다!');
      _checkAnimationComplete(0.0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_landedCount >= _totalItems && !_animationCompleted) {
      _checkAnimationComplete(dt);
    }
  }

  void _checkAnimationComplete(double dt) {
    if (_animationCompleted) return;
    
    final bodies = children.whereType<FallingEmotionBody>().toList();
    bool allSettled = true;
    
    for (final body in bodies) {
      if (body.body.linearVelocity.length > 0.5 || body.body.angularVelocity.abs() > 0.1) {
        allSettled = false;
        break;
      }
    }
    
    if (allSettled) {
      _settleTimer += dt;
      if (_settleTimer >= _settleDelay) {
        print('🎯 애니메이션 완전 완료! 모든 아이템이 정지했습니다.');
        _animationCompleted = true;
        _forceResetTimer?.cancel();
        onAnimationComplete?.call();
        
        // 3초 후 초기 상태로 복원
        Future.delayed(const Duration(seconds: 3), () {
          _resetToInitialState();
        });
      }
    } else {
      _settleTimer = 0.0; // 움직임이 있으면 타이머 리셋
    }
  }

  void _resetToInitialState() {
    _forceResetTimer?.cancel();
    _forceResetTimer = null;
    final bodies = children.whereType<FallingEmotionBody>().toList();
    
    for (final body in bodies) {
      body.resetToInitialPosition();
    }
    
    _animationStarted = false;
    _animationCompleted = false;
    _settleTimer = 0.0;
    _landedCount = 0;
  }
}

class Ground extends BodyComponent {
  final Vector2 gameSize;

  Ground(this.gameSize);

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..position = Vector2(gameSize.x / 2, gameSize.y - 20)
      ..type = BodyType.static;
    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape()..setAsBoxXY(gameSize.x / 2, 20.0);
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.1
      ..friction = 0.8;
    body.createFixture(fixtureDef);
    
    return body;
  }
}

class Wall extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  Wall(this.position, this.size);

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..position = position
      ..type = BodyType.static;
    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.2
      ..friction = 0.8;
    body.createFixture(fixtureDef);
    
    return body;
  }
}

class FallingEmotionBody extends BodyComponent<GravityGame> {
  final String assetPath;
  final Vector2 position;
  final VoidCallback? onLanded;
  final bool isStatic;

  Sprite? _sprite;
  double _elapsed = 0.0;
  bool _started = false;
  bool _hasLanded = false;
  bool _isStatic = true;

  FallingEmotionBody({
    required this.assetPath,
    required this.position,
    this.onLanded,
    this.isStatic = true,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final gameRef = findGame()!;
    final cleanPath = assetPath.replaceFirst('assets/images/', '');
    final sprite = Sprite(gameRef.images.fromCache(cleanPath));
    final originalSize = sprite.srcSize;

    final targetWidth = gameRef.size.x / 5 * 0.8;
    final aspectRatio = originalSize.x / originalSize.y;

    final adjustedHeight = targetWidth / aspectRatio;
    final _spriteComp = SpriteComponent(
      sprite: sprite,
      size: Vector2(targetWidth, adjustedHeight),
      anchor: Anchor.center,
      position: Vector2.zero(),
    );

    add(_spriteComp);
  }

  void startFalling() {
    _isStatic = false;
    body.setType(BodyType.dynamic);
    final randomX = (Random().nextDouble() - 0.5) * 1.0;
    body.linearVelocity = Vector2(randomX, 0);
    final randomAngular = (Random().nextDouble() - 0.5) * 2.0; // -3.0 ~ 3.0 rad/s
    body.angularVelocity = randomAngular;
  }

  void resetToInitialPosition() {
    _isStatic = true;
    _hasLanded = false;
    _started = false;
    _elapsed = 0.0;
    
    body.setType(BodyType.static);
    body.setTransform(position, 0.0);
    body.linearVelocity = Vector2.zero();
    body.angularVelocity = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isStatic) return;

    final gameRef = findGame()!;
    final groundY = gameRef.size.y - 50;

    // 아이템이 충분히 느려지고 안정화되면 착지로 판단
    if (!_hasLanded && 
        body.linearVelocity.length < 2.0 && 
        body.angularVelocity.abs() < 0.5) {
      
      // 0.5초간 안정화 상태를 유지하면 착지로 판단
      _elapsed += dt;
      if (_elapsed > 0.5) {
        _hasLanded = true;
        body.angularVelocity = 0.0;
        body.linearVelocity = Vector2.zero();
        onLanded?.call();
      }
    } else {
      // 움직임이 있으면 타이머 리셋
      _elapsed = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    canvas.save();
    canvas.translate(body.position.x, body.position.y);
    canvas.rotate(body.angle);

    canvas.restore();
  }

  @override
  bool get renderBody => false;

  @override
  Body createBody() {
    final gameRef = findGame();
    final size = (gameRef?.size.x ?? 250.0) / 5 * 0.75;

    final bodyDef = BodyDef()
      ..position = position
      ..type = isStatic ? BodyType.static : BodyType.dynamic
      ..linearDamping = 0.05
      ..angularDamping = 0.7;
    final body = world.createBody(bodyDef);
    
    final shape = CircleShape()..radius = size / 2;
    
    final fixtureDef = FixtureDef(shape)
      ..density = 0.01
      ..restitution =0.85
      ..friction = 0.1;

    body.createFixture(fixtureDef);
    return body;
  }
}