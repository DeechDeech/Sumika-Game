import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'fruit_kind.dart';

class FruitComponent extends BodyComponent with ContactCallbacks {
  FruitComponent({
    required this.kind,
    required Vector2 position,
    required this.onFruitContact,
  }) : super(
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
  final void Function(FruitComponent first, FruitComponent second)
  onFruitContact;
  bool isMerging = false;

  @override
  Body createBody() {
    final fruitBody = super.createBody();
    fruitBody.userData = this;
    return fruitBody;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other case final FruitComponent otherFruit) {
      onFruitContact(this, otherFruit);
    }
  }
}
