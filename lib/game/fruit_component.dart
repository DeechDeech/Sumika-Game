import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'fruit_kind.dart';

class FruitComponent extends BodyComponent {
  FruitComponent({required this.kind, required Vector2 position})
    : super(
        bodyDef: BodyDef(type: BodyType.dynamic, position: position),
        fixtureDefs: [
          FixtureDef(
            CircleShape(radius: kind.radius),
            density: 1,
            friction: 0.42,
            restitution: 0.12,
          ),
        ],
        paint: Paint()..color = kind.color,
      );

  final FruitKind kind;
  bool isMerging = false;
}
