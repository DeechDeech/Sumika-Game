import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

import 'fruit_kind.dart';

abstract final class FruitComponentConstants {
  static const double density = 1;
  static const double friction = 0.42;
  static const double restitution = 0.12;
}

class FruitComponent extends BodyComponent with ContactCallbacks {
  /// 種類に対応する大きさ・色・物理形状を持つ果実を作成します。
  FruitComponent({
    required this.kind,
    required Vector2 position,
    required this.onFruitContact,
  }) : super(
         bodyDef: BodyDef(type: BodyType.dynamic, position: position),
         fixtureDefs: [
           FixtureDef(
             CircleShape(radius: kind.radius),
             density: FruitComponentConstants.density,
             friction: FruitComponentConstants.friction,
             restitution: FruitComponentConstants.restitution,
           ),
         ],
         paint: Paint()..color = kind.color,
       );

  final FruitKind kind;
  final void Function(FruitComponent first, FruitComponent second)
  onFruitContact;
  bool isMerging = false;

  /// 接触イベントから果実コンポーネントを識別できるよう body に登録します。
  @override
  Body createBody() {
    final fruitBody = super.createBody();
    fruitBody.userData = this;
    return fruitBody;
  }

  /// 他の果実との接触をゲーム本体へ通知し、合体判定を依頼します。
  @override
  void beginContact(Object other, Contact contact) {
    if (other case final FruitComponent otherFruit) {
      onFruitContact(this, otherFruit);
    }
  }
}
