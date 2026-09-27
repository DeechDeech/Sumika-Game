import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../../app/app_theme.dart';

abstract final class ScorePanelConstants {
  static const double labelFontSize = 10;
  static const double labelLetterSpacing = 1.2;
  static const double labelToValueGap = 9;
  static const double scoreFontSize = 23;
  static const double scoreLineHeight = 1;
  static const double hintFontSize = 11;
  static const int scoreDigits = 5;
  static const String scorePaddingCharacter = '0';
  static const String scoreLabel = 'SCORE';
  static const String mergeHint = '同じフルーツを合わせよう';
}

class ScorePanel extends StatelessWidget {
  /// スコアの値を受け取る表示行を作成します。
  const ScorePanel({required this.score, super.key});

  final ValueListenable<int> score;

  /// スコアと合体案内を表示し、スコア変更時に数字を更新します。
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Text(
          ScorePanelConstants.scoreLabel,
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: ScorePanelConstants.labelFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: ScorePanelConstants.labelLetterSpacing,
          ),
        ),
        const SizedBox(width: ScorePanelConstants.labelToValueGap),
        ValueListenableBuilder<int>(
          valueListenable: score,
          builder: (context, value, _) => Text(
            value.toString().padLeft(
              ScorePanelConstants.scoreDigits,
              ScorePanelConstants.scorePaddingCharacter,
            ),
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: ScorePanelConstants.scoreFontSize,
              fontWeight: FontWeight.w800,
              height: ScorePanelConstants.scoreLineHeight,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
