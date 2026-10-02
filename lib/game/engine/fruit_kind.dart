import 'dart:ui';

abstract final class FruitKindConstants {
  static const double logicalPixelsPerWorldUnit = 12;
  static const double outlineWidthRatio = 0.04;

  static const String fruit01Label = 'ベリー';
  static const String fruit02Label = 'プラム';
  static const String fruit03Label = 'シトラス';
  static const String fruit04Label = 'ペアー';
  static const String fruit05Label = 'ピーチ';
  static const String fruit06Label = 'メロン';
  static const String fruit07Label = 'ビッグフルーツ';
  static const String fruit08Label = 'フルーツ08';
  static const String fruit09Label = 'フルーツ09';
  static const String fruit10Label = 'フルーツ10';
  static const String fruit11Label = 'フルーツ11';

  static const double fruit01Radius = 23 / logicalPixelsPerWorldUnit;
  static const double fruit02Radius = 30.5 / logicalPixelsPerWorldUnit;
  static const double fruit03Radius = 41.5 / logicalPixelsPerWorldUnit;
  static const double fruit04Radius = 51.5 / logicalPixelsPerWorldUnit;
  static const double fruit05Radius = 60.5 / logicalPixelsPerWorldUnit;
  static const double fruit06Radius = 71 / logicalPixelsPerWorldUnit;
  static const double fruit07Radius = 78.5 / logicalPixelsPerWorldUnit;
  static const double fruit08Radius = 81 / logicalPixelsPerWorldUnit;
  static const double fruit09Radius = 88.5 / logicalPixelsPerWorldUnit;
  static const double fruit10Radius = 110 / logicalPixelsPerWorldUnit;
  static const double fruit11Radius = 129.5 / logicalPixelsPerWorldUnit;

  static const double fruit01Mass = 4;
  static const double fruit02Mass = 3.5;
  static const double fruit03Mass = 3;
  static const double fruit04Mass = 2.5;
  static const double fruit05Mass = 2;
  static const double fruit06Mass = 1.5;
  static const double fruit07Mass = 1;
  static const double fruit08Mass = 0.8;
  static const double fruit09Mass = 0.6;
  static const double fruit10Mass = 0.45;
  static const double fruit11Mass = 0.3;

  static const int fruit01Color = 0xFFE97867;
  static const int fruit02Color = 0xFFB978A5;
  static const int fruit03Color = 0xFFF1C45F;
  static const int fruit04Color = 0xFF91B86A;
  static const int fruit05Color = 0xFFF1A078;
  static const int fruit06Color = 0xFF70A984;
  static const int fruit07Color = 0xFFDA6B5B;
  static const int fruit08Color = 0xFF6E9FC7;
  static const int fruit09Color = 0xFFDBA94B;
  static const int fruit10Color = 0xFF8D79B8;
  static const int fruit11Color = 0xFF5D9B91;
  static const int nextIndexOffset = 1;
}

enum FruitKind {
  fruit01(
    FruitKindConstants.fruit01Label,
    FruitKindConstants.fruit01Radius,
    FruitKindConstants.fruit01Color,
    FruitKindConstants.fruit01Mass,
    'fruits/fruit01.png',
  ),
  fruit02(
    FruitKindConstants.fruit02Label,
    FruitKindConstants.fruit02Radius,
    FruitKindConstants.fruit02Color,
    FruitKindConstants.fruit02Mass,
    'fruits/fruit02.png',
  ),
  fruit03(
    FruitKindConstants.fruit03Label,
    FruitKindConstants.fruit03Radius,
    FruitKindConstants.fruit03Color,
    FruitKindConstants.fruit03Mass,
    'fruits/fruit03.png',
  ),
  fruit04(
    FruitKindConstants.fruit04Label,
    FruitKindConstants.fruit04Radius,
    FruitKindConstants.fruit04Color,
    FruitKindConstants.fruit04Mass,
    'fruits/fruit04.png',
  ),
  fruit05(
    FruitKindConstants.fruit05Label,
    FruitKindConstants.fruit05Radius,
    FruitKindConstants.fruit05Color,
    FruitKindConstants.fruit05Mass,
    'fruits/fruit05.png',
  ),
  fruit06(
    FruitKindConstants.fruit06Label,
    FruitKindConstants.fruit06Radius,
    FruitKindConstants.fruit06Color,
    FruitKindConstants.fruit06Mass,
    'fruits/fruit06.png',
  ),
  fruit07(
    FruitKindConstants.fruit07Label,
    FruitKindConstants.fruit07Radius,
    FruitKindConstants.fruit07Color,
    FruitKindConstants.fruit07Mass,
    'fruits/fruit07.png',
  ),
  fruit08(
    FruitKindConstants.fruit08Label,
    FruitKindConstants.fruit08Radius,
    FruitKindConstants.fruit08Color,
    FruitKindConstants.fruit08Mass,
    'fruits/fruit08.png',
  ),
  fruit09(
    FruitKindConstants.fruit09Label,
    FruitKindConstants.fruit09Radius,
    FruitKindConstants.fruit09Color,
    FruitKindConstants.fruit09Mass,
    'fruits/fruit09.png',
  ),
  fruit10(
    FruitKindConstants.fruit10Label,
    FruitKindConstants.fruit10Radius,
    FruitKindConstants.fruit10Color,
    FruitKindConstants.fruit10Mass,
    'fruits/fruit10.png',
  ),
  fruit11(
    FruitKindConstants.fruit11Label,
    FruitKindConstants.fruit11Radius,
    FruitKindConstants.fruit11Color,
    FruitKindConstants.fruit11Mass,
    'fruits/fruit11.png',
  );

  /// 表示、物理特性、画像アセットを果実の種類に結び付けます。
  const FruitKind(
    this.label,
    this.radius,
    this.colorValue,
    this.mass,
    this.imageAsset,
  );

  final String label;
  final double radius;
  final int colorValue;
  final double mass;
  final String imageAsset;

  String get closedEyeAsset => 'fruits/close/${imageAsset.split('/').last}';

  /// 32 bit 整数で定義した色を Flutter の Color に変換します。
  Color get color => Color(colorValue);

  double get outlineWidth => radius * FruitKindConstants.outlineWidthRatio;

  /// 合体後の種類を返します。最大サイズの場合は null です。
  FruitKind? get next {
    final nextIndex = index + FruitKindConstants.nextIndexOffset;
    return nextIndex < FruitKind.values.length
        ? FruitKind.values[nextIndex]
        : null;
  }
}
