import 'package:flutter/material.dart';

import '../../../app/app_theme.dart';
import '../../game_content.dart';

abstract final class GameControlsConstants {
  static const double touchIconSize = 17;
  static const double touchHintGap = 6;
  static const double touchHintFontSize = 12;
  static const double resetIconSize = 18;
  static const double resetButtonHorizontalPadding = 14;
  static const double resetButtonVerticalPadding = 10;
  static const double buttonGap = 8;
  static const double settingsButtonSize = 39;
  static const double settingsButtonRadius = 13;
  static const double settingsIconSize = 19;
}

class GameControls extends StatelessWidget {
  /// リセットと音量設定の操作を受け取るコントロール行を作成します。
  const GameControls({
    required this.onReset,
    required this.onOpenAudioSettings,
    super.key,
  });

  final VoidCallback onReset;
  final VoidCallback onOpenAudioSettings;

  /// 落下ヒント、リセットボタン、音量設定ボタンを表示します。
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.touch_app_rounded,
          size: GameControlsConstants.touchIconSize,
          color: AppTheme.muted,
        ),
        const SizedBox(width: GameControlsConstants.touchHintGap),
        const Expanded(
          child: Text(
            GameContent.dropHint,
            style: TextStyle(
              color: AppTheme.muted,
              fontSize: GameControlsConstants.touchHintFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: onReset,
          icon: const Icon(
            Icons.refresh_rounded,
            size: GameControlsConstants.resetIconSize,
          ),
          label: const Text(GameContent.resetButton),
          style: FilledButton.styleFrom(
            foregroundColor: AppTheme.ink,
            backgroundColor: AppTheme.controlSurface,
            padding: const EdgeInsets.symmetric(
              horizontal: GameControlsConstants.resetButtonHorizontalPadding,
              vertical: GameControlsConstants.resetButtonVerticalPadding,
            ),
          ),
        ),
        const SizedBox(width: GameControlsConstants.buttonGap),
        IconButton.filledTonal(
          onPressed: onOpenAudioSettings,
          tooltip: GameContent.audioSettings,
          icon: const Icon(
            Icons.tune_rounded,
            size: GameControlsConstants.settingsIconSize,
          ),
          style: IconButton.styleFrom(
            foregroundColor: AppTheme.cardSurface,
            backgroundColor: AppTheme.coral,
            fixedSize: const Size(
              GameControlsConstants.settingsButtonSize,
              GameControlsConstants.settingsButtonSize,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                GameControlsConstants.settingsButtonRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
