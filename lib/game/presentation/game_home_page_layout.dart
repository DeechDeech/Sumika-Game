import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/sumika_game.dart';
import 'game_home_page_constants.dart';
import 'widgets/game_board.dart';
import 'widgets/game_controls.dart';
import 'widgets/game_header.dart';
import 'widgets/score_panel.dart';

class GameHomePageLayout extends StatelessWidget {
  /// ゲーム状態を受け取り、画面全体のレイアウトを作成します。
  const GameHomePageLayout({
    required this.game,
    required this.onOpenAudioSettings,
    super.key,
  });

  final SumikaGame game;
  final VoidCallback onOpenAudioSettings;

  /// 画面幅に合わせて各ゲーム UI 部品を配置します。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(
              constraints.maxWidth,
              GameHomePageConstants.maxContentWidth,
            );

            return Center(
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    GameHomePageConstants.horizontalInset,
                    GameHomePageConstants.topInset,
                    GameHomePageConstants.horizontalInset,
                    GameHomePageConstants.bottomInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GameHeader(nextFruit: game.nextFruit),
                      const SizedBox(
                        height: GameHomePageConstants.headerToScoreSpacing,
                      ),
                      ScorePanel(score: game.score),
                      const SizedBox(
                        height: GameHomePageConstants.scoreToBoardSpacing,
                      ),
                      Expanded(child: GameBoard(game: game)),
                      const SizedBox(
                        height: GameHomePageConstants.boardToControlsSpacing,
                      ),
                      GameControls(
                        onReset: game.reset,
                        onOpenAudioSettings: onOpenAudioSettings,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
