import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../engine/fruit_kind.dart';
import '../../../app/app_theme.dart';
import 'score_panel.dart';

abstract final class GameHeaderConstants {
  static const double brandIconSize = 38;
  static const double iconGap = 8;
  static const double titleFontSize = 19;
  static const double titleLineHeight = 1.1;
  static const double titleToScoreGap = 8;
  static const double nextCardWidth = 112;
  static const double nextCardHeight = 116;
  static const double nextCardPadding = 8;
  static const double nextFruitSlotSize = 84;
  static const double nextLabelFontSize = 10;
  static const double nextFruitDisplayScale = 0.62;
  static const double nextFruitCardRadius = 12;
  static const double borderAlpha = 0.08;
  static const String title = 'スミカゲーム';
  static const String brandLogoAsset = 'assets/images/branding/sumika_logo.png';
  static const Key nextCardKey = ValueKey<String>('next-fruit-card');
  static const Key nextFruitSlotKey = ValueKey<String>('next-fruit-slot');
  static const Key nextFruitKey = ValueKey<String>('next-fruit');
  static const String eyebrow = 'FRUIT DROP STUDY  /  01';
  static const String nextLabel = 'NEXT';
}

class GameHeader extends StatelessWidget {
  /// 次の果実を受け取ってゲーム画面ヘッダーを作成します。
  const GameHeader({required this.nextFruit, required this.score, super.key});

  final ValueListenable<FruitKind> nextFruit;
  final ValueListenable<int> score;

  /// ゲームタイトルと次に落とす果実を表示します。
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    GameHeaderConstants.brandLogoAsset,
                    width: GameHeaderConstants.brandIconSize,
                    height: GameHeaderConstants.brandIconSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: GameHeaderConstants.iconGap),
                  Flexible(
                    child: const Text(
                      GameHeaderConstants.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: GameHeaderConstants.titleFontSize,
                        fontWeight: FontWeight.w800,
                        height: GameHeaderConstants.titleLineHeight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GameHeaderConstants.titleToScoreGap),
              ScorePanel(score: score),
            ],
          ),
        ),
        ValueListenableBuilder<FruitKind>(
          valueListenable: nextFruit,
          builder: (context, fruit, _) {
            final fruitOutlineWidth =
                fruit.outlineWidth *
                FruitKindConstants.logicalPixelsPerWorldUnit *
                GameHeaderConstants.nextFruitDisplayScale *
                2;
            final fruitSize =
                fruit.radius *
                FruitKindConstants.logicalPixelsPerWorldUnit *
                2 *
                GameHeaderConstants.nextFruitDisplayScale;
            return Container(
              key: GameHeaderConstants.nextCardKey,
              width: GameHeaderConstants.nextCardWidth,
              height: GameHeaderConstants.nextCardHeight,
              padding: const EdgeInsets.all(
                GameHeaderConstants.nextCardPadding,
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
              child: Column(
                children: [
                  const Text(
                    GameHeaderConstants.nextLabel,
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: GameHeaderConstants.nextLabelFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox.square(
                        key: GameHeaderConstants.nextFruitSlotKey,
                        dimension: GameHeaderConstants.nextFruitSlotSize,
                        child: Center(
                          child: Container(
                            key: GameHeaderConstants.nextFruitKey,
                            width: fruitSize,
                            height: fruitSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: fruit.color,
                            ),
                            foregroundDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: fruit.color,
                                width: fruitOutlineWidth,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/${fruit.imageAsset}',
                              width: fruitSize,
                              height: fruitSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  ColoredBox(color: fruit.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
