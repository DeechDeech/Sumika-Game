import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

abstract final class ArenaComponentConstants {
  static const double axisOrigin = 0;
  static const double initialAngle = 0;
  static const double halfDimensionDivisor = 2;
  static const double wallThickness = 0.42;
  static const double friction = 0.55;
  static const int fillColorValue = 0xFF536A5D;
}

class ArenaComponent extends BodyComponent {
  /// 指定した大きさの、床と左右の壁を持つ静的な箱を作成します。
  ArenaComponent({required double width, required double height})
    : super(
        bodyDef: BodyDef(type: BodyType.static),
        fixtureDefs: _fixtures(
          width / ArenaComponentConstants.halfDimensionDivisor,
          height / ArenaComponentConstants.halfDimensionDivisor,
        ),
        paint: Paint()
          ..color = const Color(ArenaComponentConstants.fillColorValue),
      );

  /// 箱の床と左右の壁に使う物理フィクスチャを作成します。
  static List<FixtureDef> _fixtures(double halfWidth, double halfHeight) {
    const wallThickness = ArenaComponentConstants.wallThickness;
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
        halfHeight: halfHeight,
        center: Vector2(
          -halfWidth +
              wallThickness / ArenaComponentConstants.halfDimensionDivisor,
          ArenaComponentConstants.axisOrigin,
        ),
      ),
      _box(
        halfWidth: wallThickness / ArenaComponentConstants.halfDimensionDivisor,
        halfHeight: halfHeight,
        center: Vector2(
          halfWidth -
              wallThickness / ArenaComponentConstants.halfDimensionDivisor,
          ArenaComponentConstants.axisOrigin,
        ),
      ),
    ];
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
