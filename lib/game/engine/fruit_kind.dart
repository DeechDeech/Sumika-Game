import 'dart:ui';

import '../game_content.dart';
import 'game_context.dart';

abstract final class FruitKindConstants {
  static const double logicalPixelsPerWorldUnit = 12;

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

  static const int fruit01Color = 0xFFC7475A;
  static const int fruit02Color = 0xFF79549A;
  static const int fruit03Color = 0xFFB98217;
  static const int fruit04Color = 0xFF548B45;
  static const int fruit05Color = 0xFFD36A45;
  static const int fruit06Color = 0xFF287F78;
  static const int fruit07Color = 0xFFA43F79;
  static const int fruit08Color = 0xFF397EAE;
  static const int fruit09Color = 0xFF89772A;
  static const int fruit10Color = 0xFF545FA6;
  static const int fruit11Color = 0xFF278F9E;
  static const int nextIndexOffset = 1;
}

enum FruitKind {
  fruit01(
    GameContent.fruit01Label,
    FruitKindConstants.fruit01Radius,
    FruitKindConstants.fruit01Color,
    FruitKindConstants.fruit01Mass,
  ),
  fruit02(
    GameContent.fruit02Label,
    FruitKindConstants.fruit02Radius,
    FruitKindConstants.fruit02Color,
    FruitKindConstants.fruit02Mass,
  ),
  fruit03(
    GameContent.fruit03Label,
    FruitKindConstants.fruit03Radius,
    FruitKindConstants.fruit03Color,
    FruitKindConstants.fruit03Mass,
  ),
  fruit04(
    GameContent.fruit04Label,
    FruitKindConstants.fruit04Radius,
    FruitKindConstants.fruit04Color,
    FruitKindConstants.fruit04Mass,
  ),
  fruit05(
    GameContent.fruit05Label,
    FruitKindConstants.fruit05Radius,
    FruitKindConstants.fruit05Color,
    FruitKindConstants.fruit05Mass,
  ),
  fruit06(
    GameContent.fruit06Label,
    FruitKindConstants.fruit06Radius,
    FruitKindConstants.fruit06Color,
    FruitKindConstants.fruit06Mass,
  ),
  fruit07(
    GameContent.fruit07Label,
    FruitKindConstants.fruit07Radius,
    FruitKindConstants.fruit07Color,
    FruitKindConstants.fruit07Mass,
  ),
  fruit08(
    GameContent.fruit08Label,
    FruitKindConstants.fruit08Radius,
    FruitKindConstants.fruit08Color,
    FruitKindConstants.fruit08Mass,
  ),
  fruit09(
    GameContent.fruit09Label,
    FruitKindConstants.fruit09Radius,
    FruitKindConstants.fruit09Color,
    FruitKindConstants.fruit09Mass,
  ),
  fruit10(
    GameContent.fruit10Label,
    FruitKindConstants.fruit10Radius,
    FruitKindConstants.fruit10Color,
    FruitKindConstants.fruit10Mass,
  ),
  fruit11(
    GameContent.fruit11Label,
    FruitKindConstants.fruit11Radius,
    FruitKindConstants.fruit11Color,
    FruitKindConstants.fruit11Mass,
  );

  /// 表示、物理特性、画像アセットを果実の種類に結び付けます。
  const FruitKind(this.label, this.radius, this.colorValue, this.mass);

  final String label;
  final double radius;
  final int colorValue;
  final double mass;

  int get imageNumber => index + GameContextConstants.firstFruitImageNumber;

  String get imageFileName =>
      '${GameContextConstants.fruitImageFilePrefix}${imageNumber.toString().padLeft(GameContextConstants.fruitImageNumberWidth, GameContextConstants.imageNumberPaddingCharacter)}${GameContextConstants.imageFileExtension}';

  String get imageAsset =>
      '${GameContextConstants.fruitAssetDirectory}${GameContextConstants.assetPathSeparator}$imageFileName';

  String get closedEyeAsset =>
      '${GameContextConstants.closedEyeAssetDirectory}${GameContextConstants.assetPathSeparator}$imageFileName';

  String get outlinedAsset =>
      '${GameContextConstants.outlinedFruitAssetDirectory}${GameContextConstants.assetPathSeparator}$imageFileName';

  String get outlinedClosedEyeAsset =>
      '${GameContextConstants.outlinedClosedEyeAssetDirectory}${GameContextConstants.assetPathSeparator}$imageFileName';

  /// 32 bit 整数で定義した色を Flutter の Color に変換します。
  Color get color => Color(colorValue);

  double get outlineWidth =>
      radius * GameContextConstants.fruitOutlineWidthRatio;

  /// 合体後の種類を返します。最大サイズの場合は null です。
  FruitKind? get next {
    final nextIndex = index + FruitKindConstants.nextIndexOffset;
    return nextIndex < FruitKind.values.length
        ? FruitKind.values[nextIndex]
        : null;
  }
}
