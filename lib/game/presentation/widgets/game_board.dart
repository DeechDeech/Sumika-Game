import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../engine/sumika_game.dart';
import '../../../app/app_theme.dart';

abstract final class GameBoardConstants {
  static const Key boardContainerKey = ValueKey<String>('game-board-container');
  static const double borderRadius = 20;
  static const double borderWidth = 1.5;
  static const int borderColorValue = 0xFF718279;
  static const int shadowColorValue = 0x1A263A35;
  static const double shadowOffsetX = 0;
  static const double shadowOffsetY = 8;
  static const double shadowBlurRadius = 18;
}

class GameBoard extends StatelessWidget {
  /// Flame ゲームを枠付きの盤面として表示するウィジェットを作成します。
  const GameBoard({required this.game, super.key});

  final SumikaGame game;

  /// 盤面の背景、縁取り、影を描画し、ゲームを表示します。
  @override
  Widget build(BuildContext context) {
    return Container(
      key: GameBoardConstants.boardContainerKey,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.gameArea,
        borderRadius: BorderRadius.circular(GameBoardConstants.borderRadius),
        border: Border.all(
          color: const Color(GameBoardConstants.borderColorValue),
          width: GameBoardConstants.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(GameBoardConstants.shadowColorValue),
            blurRadius: GameBoardConstants.shadowBlurRadius,
            offset: Offset(
              GameBoardConstants.shadowOffsetX,
              GameBoardConstants.shadowOffsetY,
            ),
          ),
        ],
      ),
      child: GameWidget(game: game),
    );
  }
}
