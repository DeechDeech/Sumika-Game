import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

class ArenaComponent extends BodyComponent {
  ArenaComponent({required double width, required double height})
    : super(
        bodyDef: BodyDef(type: BodyType.static),
        fixtureDefs: _fixtures(width / 2, height / 2),
        paint: Paint()..color = const Color(0xFF536A5D),
      );

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

  static FixtureDef _box({
    required double halfWidth,
    required double halfHeight,
    required Vector2 center,
  }) {
    final shape = PolygonShape()..setAsBox(halfWidth, halfHeight, center, 0);
    return FixtureDef(shape, friction: 0.55);
  }
}
