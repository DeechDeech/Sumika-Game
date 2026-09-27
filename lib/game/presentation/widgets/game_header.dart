import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../engine/fruit_kind.dart';
import '../../../app/app_theme.dart';

abstract final class GameHeaderConstants {
  static const double brandIconSize = 42;
  static const double brandIconRadius = 14;
  static const double iconGap = 12;
  static const double titleFontSize = 21;
  static const double titleLineHeight = 1.1;
  static const double eyebrowGap = 3;
  static const double eyebrowFontSize = 10;
  static const double nextCardHorizontalPadding = 12;
  static const double nextCardVerticalPadding = 8;
  static const double nextCardRightPadding = 12;
  static const double nextFruitGap = 8;
  static const double nextLabelFontSize = 10;
  static const double nextFruitSize = 36;
  static const double nextFruitCardRadius = 14;
  static const double fruitOutlineWidth = 1.5;
  static const double borderAlpha = 0.08;
  static const String title = 'スミカゲーム';
  static const String eyebrow = 'FRUIT DROP STUDY  /  01';
  static const String nextLabel = 'NEXT';
}

class GameHeader extends StatelessWidget {
  /// 次の果実を受け取ってゲーム画面ヘッダーを作成します。
  const GameHeader({required this.nextFruit, super.key});

  final ValueListenable<FruitKind> nextFruit;

  /// ゲームタイトルと次に落とす果実を表示します。
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: GameHeaderConstants.brandIconSize,
          height: GameHeaderConstants.brandIconSize,
          decoration: BoxDecoration(
            color: AppTheme.ink,
            borderRadius: BorderRadius.circular(
              GameHeaderConstants.brandIconRadius,
            ),
          ),
          child: const Icon(Icons.eco_rounded, color: AppTheme.fruitAccent),
        ),
        const SizedBox(width: GameHeaderConstants.iconGap),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GameHeaderConstants.title,
                style: TextStyle(
                  fontSize: GameHeaderConstants.titleFontSize,
                  fontWeight: FontWeight.w800,
                  height: GameHeaderConstants.titleLineHeight,
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<FruitKind>(
          valueListenable: nextFruit,
          builder: (context, fruit, _) => Container(
            padding: const EdgeInsets.fromLTRB(
              GameHeaderConstants.nextCardHorizontalPadding,
              GameHeaderConstants.nextCardVerticalPadding,
              GameHeaderConstants.nextCardRightPadding,
              GameHeaderConstants.nextCardVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(
                GameHeaderConstants.nextFruitCardRadius,
              ),
              border: Border.all(
                color: AppTheme.ink.withValues(
                  alpha: GameHeaderConstants.borderAlpha,
                ),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  GameHeaderConstants.nextLabel,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: GameHeaderConstants.nextLabelFontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: GameHeaderConstants.nextFruitGap),
                Container(
                  width: GameHeaderConstants.nextFruitSize,
                  height: GameHeaderConstants.nextFruitSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fruit.color,
                    border: Border.all(
                      color: fruit.color,
                      width: GameHeaderConstants.fruitOutlineWidth,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/${fruit.imageAsset}',
                    width: GameHeaderConstants.nextFruitSize,
                    height: GameHeaderConstants.nextFruitSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: fruit.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
