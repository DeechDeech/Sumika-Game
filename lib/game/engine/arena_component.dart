import 'dart:async';
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

abstract final class ArenaComponentConstants {
  static const double axisOrigin = 0;
  static const double initialAngle = 0;
  static const double halfDimensionDivisor = 2;
  static const double wallThickness = 0.42;
  static const double friction = 0.55;
  static const double dangerDotRadius = 0.075;
  static const double dangerDotSpacing = 0.55;
  static const double dangerLineOffset = 0.22;
  static const String upperBackgroundAsset = 'backgrounds/ship.png';
  static const String lowerBackgroundAsset = 'backgrounds/deck.png';
  static const int fillColorValue = 0xFF536A5D;
  static const int dangerLineColorValue = 0xFFE7C96E;
}

class ArenaComponent extends BodyComponent {
  ArenaComponent({
    required this.width,
    required this.height,
    required this.topInset,
  }) : super(
         bodyDef: BodyDef(type: BodyType.static),
         fixtureDefs: _fixtures(
           width / ArenaComponentConstants.halfDimensionDivisor,
           height / ArenaComponentConstants.halfDimensionDivisor,
           topInset,
         ),
         paint: Paint()
           ..color = const Color(ArenaComponentConstants.fillColorValue),
       );

  final double width;
  final double height;
  final double topInset;
  Image? _upperBackground;
  Image? _lowerBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(_loadBackgrounds());
  }

  Future<void> _loadBackgrounds() async {
    try {
      _upperBackground = await game.images.load(
        ArenaComponentConstants.upperBackgroundAsset,
      );
    } on Object {
      _upperBackground = null;
    }
    try {
      _lowerBackground = await game.images.load(
        ArenaComponentConstants.lowerBackgroundAsset,
      );
    } on Object {
      _lowerBackground = null;
    }
  }

  /// 箱の床と左右の壁に使う物理フィクスチャを作成します。
  static List<FixtureDef> _fixtures(
    double halfWidth,
    double halfHeight,
    double topInset,
  ) {
    const wallThickness = ArenaComponentConstants.wallThickness;
    final topY = -halfHeight + topInset;
    final bottomY = halfHeight;
    final wallCenterY = (topY + bottomY) / 2;
    final wallHalfHeight = (bottomY - topY) / 2;
    final floorY =
        halfHeight -
        wallThickness / ArenaComponentConstants.halfDimensionDivisor;

    return [
      _box(
        halfWidth: halfWidth,
        halfHeight:
            wallThickness / ArenaComponentConstants.halfDimensionDivisor,
        center: Vector2(ArenaComponentConstants.axisOrigin, floorY),
      ),
      _box(
        halfWidth: wallThickness / ArenaComponentConstants.halfDimensionDivisor,
        halfHeight: wallHalfHeight,
        center: Vector2(
          -halfWidth +
              wallThickness / ArenaComponentConstants.halfDimensionDivisor,
          wallCenterY,
        ),
      ),
      _box(
        halfWidth: wallThickness / ArenaComponentConstants.halfDimensionDivisor,
        halfHeight: wallHalfHeight,
        center: Vector2(
          halfWidth -
              wallThickness / ArenaComponentConstants.halfDimensionDivisor,
          wallCenterY,
        ),
      ),
    ];
  }

  @override
  void render(Canvas canvas) {
    final halfWidth = width / ArenaComponentConstants.halfDimensionDivisor;
    final top = -height / ArenaComponentConstants.halfDimensionDivisor;
    final bottom = height / ArenaComponentConstants.halfDimensionDivisor;
    final lineY = top + topInset + ArenaComponentConstants.dangerLineOffset;
    final upperBounds = Rect.fromLTRB(-halfWidth, top, halfWidth, lineY);
    final lowerBounds = Rect.fromLTRB(-halfWidth, lineY, halfWidth, bottom);
    _drawBackground(
      canvas,
      _upperBackground,
      upperBounds,
      upperBounds,
      cropFromBottom: true,
    );
    _drawBackground(canvas, _lowerBackground, lowerBounds, lowerBounds);
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(ArenaComponentConstants.dangerLineColorValue);
    for (
      var x = -halfWidth;
      x <= halfWidth;
      x += ArenaComponentConstants.dangerDotSpacing
    ) {
      canvas.drawCircle(
        Offset(x, lineY),
        ArenaComponentConstants.dangerDotRadius,
        paint,
      );
    }
  }

  void _drawBackground(
    Canvas canvas,
    Image? image,
    Rect destination,
    Rect clip, {
    bool cropFromBottom = false,
  }) {
    if (image == null) return;

    final sourceWidth = image.width.toDouble();
    final sourceHeight = image.height.toDouble();
    final sourceAspect = sourceWidth / sourceHeight;
    final destinationAspect = destination.width / destination.height;
    final sourceRect = sourceAspect > destinationAspect
        ? Rect.fromLTWH(
            (sourceWidth - sourceHeight * destinationAspect) / 2,
            0,
            sourceHeight * destinationAspect,
            sourceHeight,
          )
        : Rect.fromLTWH(
            0,
            cropFromBottom
                ? sourceHeight - sourceWidth / destinationAspect
                : (sourceHeight - sourceWidth / destinationAspect) / 2,
            sourceWidth,
            sourceWidth / destinationAspect,
          );

    canvas
      ..save()
      ..clipRect(clip)
      ..drawImageRect(
        image,
        sourceRect,
        destination,
        Paint()..filterQuality = FilterQuality.medium,
      )
      ..restore();
  }

  /// 中心位置と半寸法を指定した長方形の物理形状を作成します。
  static FixtureDef _box({
    required double halfWidth,
    required double halfHeight,
    required Vector2 center,
  }) {
    final shape = PolygonShape()
      ..setAsBox(
        halfWidth,
        halfHeight,
        center,
        ArenaComponentConstants.initialAngle,
      );
    return FixtureDef(shape, friction: ArenaComponentConstants.friction);
  }
}
