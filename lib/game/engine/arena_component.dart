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
  static const String dangerAreaBackgroundAsset = 'backgrounds/ship.png';
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
  Image? _dangerAreaBackground;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _dangerAreaBackground = await game.images.load(
        ArenaComponentConstants.dangerAreaBackgroundAsset,
      );
    } on Object {
      _dangerAreaBackground = null;
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
    _drawDangerAreaBackground(canvas);
    super.render(canvas);
    final paint = Paint()
      ..color = const Color(ArenaComponentConstants.dangerLineColorValue);
    final lineY =
        -height / ArenaComponentConstants.halfDimensionDivisor +
        topInset +
        ArenaComponentConstants.dangerLineOffset;
    for (
      var x = -width / ArenaComponentConstants.halfDimensionDivisor;
      x <= width / ArenaComponentConstants.halfDimensionDivisor;
      x += ArenaComponentConstants.dangerDotSpacing
    ) {
      canvas.drawCircle(
        Offset(x, lineY),
        ArenaComponentConstants.dangerDotRadius,
        paint,
      );
    }
  }

  void _drawDangerAreaBackground(Canvas canvas) {
    final image = _dangerAreaBackground;
    if (image == null) return;

    final top = -height / ArenaComponentConstants.halfDimensionDivisor;
    final lineY = top + topInset + ArenaComponentConstants.dangerLineOffset;
    final destination = Rect.fromLTRB(
      -width / ArenaComponentConstants.halfDimensionDivisor,
      top,
      width / ArenaComponentConstants.halfDimensionDivisor,
      lineY,
    );
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
            (sourceHeight - sourceWidth / destinationAspect) / 2,
            sourceWidth,
            sourceWidth / destinationAspect,
          );

    canvas.drawImageRect(
      image,
      sourceRect,
      destination,
      Paint()..filterQuality = FilterQuality.medium,
    );
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
