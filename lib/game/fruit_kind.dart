import 'dart:ui';

enum FruitKind {
  berry('ベリー', 0.72, 0xFFE97867),
  plum('プラム', 0.92, 0xFFB978A5),
  citrus('シトラス', 1.14, 0xFFF1C45F),
  pear('ペアー', 1.42, 0xFF91B86A),
  peach('ピーチ', 1.78, 0xFFF1A078),
  melon('メロン', 2.18, 0xFF70A984),
  giant('ビッグフルーツ', 2.66, 0xFFDA6B5B);

  const FruitKind(this.label, this.radius, this.colorValue);

  final String label;
  final double radius;
  final int colorValue;

  Color get color => Color(colorValue);

  FruitKind? get next {
    final nextIndex = index + 1;
    return nextIndex < FruitKind.values.length
        ? FruitKind.values[nextIndex]
        : null;
  }
}
