import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';

import 'fruit_kind.dart';

abstract final class FruitComponentConstants {
  static const double friction = 0.42;
  static const double restitution = 0.12;
  static const double outlineWidth = 0.08;
  static const double overlapTolerance = 0.0001;
}

class FruitComponent extends BodyComponent with ContactCallbacks {
  static Future<Set<String>>? _assetManifestPaths;

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
             density: kind.mass / (math.pi * kind.radius * kind.radius),
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
  Image? _image;

  bool overlapsAt(Vector2 candidatePosition, FruitKind candidateKind) {
    return circlesOverlap(
      firstPosition: position,
      firstRadius: kind.radius,
      secondPosition: candidatePosition,
      secondRadius: candidateKind.radius,
    );
  }

  static bool circlesOverlap({
    required Vector2 firstPosition,
    required double firstRadius,
    required Vector2 secondPosition,
    required double secondRadius,
  }) {
    final minimumSeparation =
        firstRadius + secondRadius - FruitComponentConstants.overlapTolerance;
    return (firstPosition - secondPosition).length < minimumSeparation;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final assetPaths = await (_assetManifestPaths ??= _loadAssetManifest());
      if (!assetPaths.contains('assets/images/${kind.imageAsset}')) return;
      _image = await game.images.load(kind.imageAsset);
    } on Object {
      _image = null;
    }
  }

  static Future<Set<String>> _loadAssetManifest() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }

  @override
  void render(Canvas canvas) {
    final image = _image;
    if (image == null) {
      super.render(canvas);
      _drawOutline(canvas);
      return;
    }

    final diameter = kind.radius * 2;
    final imageWidth = diameter * image.width / image.height;
    final clip = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: kind.radius));
    canvas.save();
    canvas.clipPath(clip);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromCenter(center: Offset.zero, width: imageWidth, height: diameter),
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.restore();
    _drawOutline(canvas);
  }

  void _drawOutline(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      kind.radius,
      Paint()
        ..color = kind.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = FruitComponentConstants.outlineWidth,
    );
  }

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
