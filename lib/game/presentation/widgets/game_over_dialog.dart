import 'package:flutter/material.dart';

import '../../engine/game_context.dart';
import '../../game_content.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    required this.finalScore,
    required this.onClose,
    required this.onRetry,
    super.key,
  });

  final int finalScore;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        GameContent.gameOverTitle,
        style: TextStyle(fontSize: GameContextConstants.gameOverScoreFontSize),
      ),
      content: Text(
        '${GameContent.gameOverScorePrefix}$finalScore',
        style: const TextStyle(
          fontSize: GameContextConstants.gameOverScoreFontSize,
        ),
      ),
      actions: [
        SizedBox(
          width:
              GameContextConstants.gameOverActionButtonWidth * 2 +
              GameContextConstants.gameOverActionButtonSpacing,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: GameContextConstants.gameOverActionButtonHeight,
                  child: TextButton(
                    onPressed: onClose,
                    style: TextButton.styleFrom(
                      backgroundColor: Color(
                        GameContextConstants.gameOverCloseButtonBackgroundColor,
                      ),
                      foregroundColor: Color(
                        GameContextConstants.gameOverCloseButtonForegroundColor,
                      ),
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize:
                            GameContextConstants.gameOverActionButtonFontSize,
                      ),
                    ),
                    child: const Text(
                      GameContent.closeButton,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
              SizedBox(width: GameContextConstants.gameOverActionButtonSpacing),
              Expanded(
                child: SizedBox(
                  height: GameContextConstants.gameOverActionButtonHeight,
                  child: FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontSize:
                            GameContextConstants.gameOverActionButtonFontSize,
                      ),
                    ),
                    child: const Text(
                      GameContent.retryButton,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
