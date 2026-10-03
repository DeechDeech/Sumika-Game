import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'game_context.dart';
import 'fruit_kind.dart';

abstract final class DropShipConstants {
  static const double dropLineGap = 0.16;
  static const double fruitComponentPadding = 0.2;
}

class DropShipComponent extends PositionComponent
    with HasGameReference<FlameGame> {
  DropShipComponent({required FruitKind fruitKind, required Vector2 position})
    : _fruitKind = fruitKind,
      super(position: position, anchor: Anchor.center) {
    _updateSize();
  }

  FruitKind _fruitKind;
  Image? _fruitImage;
  Image? _closedEyeImage;
  int _imageRequest = 0;
  double _blinkTimer = GameContextConstants.dropPreviewBlinkIntervalSeconds;
  bool _isBlinking = false;
  bool _eyesForcedClosed = false;
  bool _isGameOver = false;

  Vector2 get fruitCenterPosition => Vector2(position.x, position.y);

  void follow({
    required FruitKind fruitKind,
    required double x,
    required double lineY,
  }) {
    if (_fruitKind != fruitKind) {
      _fruitKind = fruitKind;
      _updateSize();
      _fruitImage = null;
      _closedEyeImage = null;
      unawaited(_loadFruitImage());
    }
    position.setValues(x, lineY - size.y / 2 - DropShipConstants.dropLineGap);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadFruitImage();
  }

  void _updateSize() {
    final diameter =
        _fruitKind.radius * 2 + DropShipConstants.fruitComponentPadding;
    size = Vector2.all(diameter);
  }

  Future<void> _loadFruitImage() async {
    final request = ++_imageRequest;
    final kind = _fruitKind;
    try {
      final image = await game.images.load(kind.imageAsset);
      if (request != _imageRequest) return;
      _fruitImage = image;
      unawaited(_loadClosedEyeImage(kind, request));
    } on Object {
      if (request != _imageRequest) return;
      _fruitImage = null;
    }
  }

  Future<void> _loadClosedEyeImage(FruitKind kind, int request) async {
    try {
      final image = await game.images.load(kind.closedEyeAsset);
      if (request == _imageRequest) _closedEyeImage = image;
    } on Object {
      if (request == _imageRequest) _closedEyeImage = null;
    }
  }

  void setGameOver(bool gameOver) {
    _isGameOver = gameOver;
    _eyesForcedClosed =
        gameOver && GameContextConstants.closePreviewFruitsOnGameOver;
    _isBlinking = false;
    _blinkTimer = GameContextConstants.dropPreviewBlinkIntervalSeconds;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) return;

    _blinkTimer -= dt;
    if (_blinkTimer > 0) return;

    _isBlinking = !_isBlinking;
    _blinkTimer = _isBlinking
        ? GameContextConstants.dropPreviewBlinkDurationSeconds
        : GameContextConstants.dropPreviewBlinkIntervalSeconds;
  }

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final radius = _fruitKind.radius;
    final fruitCenter = Offset(width / 2, height / 2);
    final fruitRect = Rect.fromCircle(center: fruitCenter, radius: radius);
    final fruitImage = _eyesForcedClosed || _isBlinking
        ? _closedEyeImage ?? _fruitImage
        : _fruitImage;
    if (fruitImage == null) {
      canvas.drawCircle(fruitCenter, radius, Paint()..color = _fruitKind.color);
    } else {
      canvas.save();
      canvas.clipPath(Path()..addOval(fruitRect));
      canvas.drawImageRect(
        fruitImage,
        Rect.fromLTWH(
          0,
          0,
          fruitImage.width.toDouble(),
          fruitImage.height.toDouble(),
        ),
        fruitRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      fruitCenter,
      radius,
      Paint()
        ..color = _fruitKind.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _fruitKind.outlineWidth,
    );
  }
}
