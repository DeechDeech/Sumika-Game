import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../audio/game_audio_controller.dart';
import '../../../app/app_theme.dart';
import '../../game_content.dart';

abstract final class GameAudioSettingsConstants {
  static const double horizontalInset = 24;
  static const double topInset = 24;
  static const double bottomInset = 28;
  static const double titleFontSize = 18;
  static const double titleToSliderGap = 20;
  static const double sliderRowGap = 14;
  static const double labelWidth = 58;
  static const double percentageWidth = 42;
  static const double sliderLabelFontSize = 14;
  static const int sliderDivisions = 20;
  static const double percentScale = 100;
}

class GameAudioSettingsSheet extends StatelessWidget {
  /// BGM と効果音の音量を設定するシートを作成します。
  const GameAudioSettingsSheet({required this.controller, super.key});

  final GameAudioController controller;

  /// BGM と SE の独立した音量スライダーを表示します。
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          GameAudioSettingsConstants.horizontalInset,
          GameAudioSettingsConstants.topInset,
          GameAudioSettingsConstants.horizontalInset,
          GameAudioSettingsConstants.bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              GameContent.audioSettings,
              style: TextStyle(
                color: AppTheme.ink,
                fontSize: GameAudioSettingsConstants.titleFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: GameAudioSettingsConstants.titleToSliderGap),
            _AudioVolumeSlider(
              label: GameContent.bgmLabel,
              volume: controller.bgmVolume,
              onChanged: controller.setBgmVolume,
              onChangeEnd: (_) => controller.flushBgmVolume(),
            ),
            const SizedBox(height: GameAudioSettingsConstants.sliderRowGap),
            _AudioVolumeSlider(
              label: GameContent.soundEffectLabel,
              volume: controller.seVolume,
              onChanged: controller.setSeVolume,
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioVolumeSlider extends StatelessWidget {
  /// ラベルと音量通知値を表示する行を作成します。
  const _AudioVolumeSlider({
    required this.label,
    required this.volume,
    required this.onChanged,
    this.onChangeEnd,
  });

  final String label;
  final ValueListenable<double> volume;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  /// 音量の現在値を表示し、スライダー操作をコントローラーへ渡します。
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: volume,
      builder: (context, value, _) => Row(
        children: [
          SizedBox(
            width: GameAudioSettingsConstants.labelWidth,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: GameAudioSettingsConstants.sliderLabelFontSize,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: GameAudioConstants.minimumVolume,
              max: GameAudioConstants.maximumVolume,
              divisions: GameAudioSettingsConstants.sliderDivisions,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          SizedBox(
            width: GameAudioSettingsConstants.percentageWidth,
            child: Text(
              '${(value * GameAudioSettingsConstants.percentScale).round()}${GameContent.percentSuffix}',
              textAlign: TextAlign.end,
              style: const TextStyle(color: AppTheme.muted),
            ),
          ),
        ],
      ),
    );
  }
}
