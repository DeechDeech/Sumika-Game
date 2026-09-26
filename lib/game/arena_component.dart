import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

class ArenaComponent extends BodyComponent {
  /// 指定した大きさの、床と左右の壁を持つ静的な箱を作成します。
  ArenaComponent({required double width, required double height})
    : super(
        bodyDef: BodyDef(type: BodyType.static),
        fixtureDefs: _fixtures(width / 2, height / 2),
        paint: Paint()..color = const Color(0xFF536A5D),
      );

  /// 箱の床と左右の壁に使う物理フィクスチャを作成します。
  static List<FixtureDef> _fixtures(double halfWidth, double halfHeight) {
    const wallThickness = 0.42;
    final floorY = halfHeight - wallThickness / 2;

    return [
      _box(
        halfWidth: halfWidth,
        halfHeight: wallThickness / 2,
        center: Vector2(0, floorY),
      ),
      _box(
        halfWidth: wallThickness / 2,
        halfHeight: halfHeight,
        center: Vector2(-halfWidth + wallThickness / 2, 0),
      ),
      _box(
        halfWidth: wallThickness / 2,
        halfHeight: halfHeight,
        center: Vector2(halfWidth - wallThickness / 2, 0),
      ),
    ];
  }

  /// 中心位置と半寸法を指定した長方形の物理形状を作成します。
  static FixtureDef _box({
    required double halfWidth,
    required double halfHeight,
    required Vector2 center,
  }) {
    final shape = PolygonShape()..setAsBox(halfWidth, halfHeight, center, 0);
    return FixtureDef(shape, friction: 0.55);
  }
}
