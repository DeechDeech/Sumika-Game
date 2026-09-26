import 'dart:ui';

abstract final class FruitKindConstants {
  static const String berryLabel = 'ベリー';
  static const String plumLabel = 'プラム';
  static const String citrusLabel = 'シトラス';
  static const String pearLabel = 'ペアー';
  static const String peachLabel = 'ピーチ';
  static const String melonLabel = 'メロン';
  static const String giantLabel = 'ビッグフルーツ';

  static const double berryRadius = 0.72;
  static const double plumRadius = 0.92;
  static const double citrusRadius = 1.14;
  static const double pearRadius = 1.42;
  static const double peachRadius = 1.78;
  static const double melonRadius = 2.18;
  static const double giantRadius = 2.66;

  static const int berryColor = 0xFFE97867;
  static const int plumColor = 0xFFB978A5;
  static const int citrusColor = 0xFFF1C45F;
  static const int pearColor = 0xFF91B86A;
  static const int peachColor = 0xFFF1A078;
  static const int melonColor = 0xFF70A984;
  static const int giantColor = 0xFFDA6B5B;
  static const int nextIndexOffset = 1;
}

enum FruitKind {
  berry(
    FruitKindConstants.berryLabel,
    FruitKindConstants.berryRadius,
    FruitKindConstants.berryColor,
  ),
  plum(
    FruitKindConstants.plumLabel,
    FruitKindConstants.plumRadius,
    FruitKindConstants.plumColor,
  ),
  citrus(
    FruitKindConstants.citrusLabel,
    FruitKindConstants.citrusRadius,
    FruitKindConstants.citrusColor,
  ),
  pear(
    FruitKindConstants.pearLabel,
    FruitKindConstants.pearRadius,
    FruitKindConstants.pearColor,
  ),
  peach(
    FruitKindConstants.peachLabel,
    FruitKindConstants.peachRadius,
    FruitKindConstants.peachColor,
  ),
  melon(
    FruitKindConstants.melonLabel,
    FruitKindConstants.melonRadius,
    FruitKindConstants.melonColor,
  ),
  giant(
    FruitKindConstants.giantLabel,
    FruitKindConstants.giantRadius,
    FruitKindConstants.giantColor,
  );

  /// 表示名、Forge2D の半径、描画色を果実の種類に結び付けます。
  const FruitKind(this.label, this.radius, this.colorValue);

  final String label;
  final double radius;
  final int colorValue;

  /// 32 bit 整数で定義した色を Flutter の Color に変換します。
  Color get color => Color(colorValue);

  /// 合体後の種類を返します。最大サイズの場合は null です。
  FruitKind? get next {
    final nextIndex = index + FruitKindConstants.nextIndexOffset;
    return nextIndex < FruitKind.values.length
        ? FruitKind.values[nextIndex]
        : null;
  }
}
