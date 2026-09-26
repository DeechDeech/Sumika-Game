import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/game_audio_controller.dart';
import '../engine/sumika_game.dart';
import 'game_home_page_layout.dart';
import 'widgets/game_audio_settings_sheet.dart';

class GameHomePage extends StatefulWidget {
  /// ゲーム画面を表示するルートページを作成します。
  const GameHomePage({super.key});

  /// ゲームページのライフサイクルを管理する State を作成します。
  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final GameAudioController _audio = GameAudioController.instance;
  late final SumikaGame _game = SumikaGame(
    onFruitMerged: (kind) => unawaited(_audio.playMergeSound(kind)),
  );

  /// 音声を初期化して、ゲーム中の BGM 再生を開始します。
  @override
  void initState() {
    super.initState();
    unawaited(_audio.start());
  }

  /// ページ終了時に Flame のゲームループとリソースを破棄します。
  @override
  void dispose() {
    unawaited(_audio.stop());
    _game.dispose();
    super.dispose();
  }

  /// ゲームインスタンスを表示レイアウトへ渡します。
  @override
  Widget build(BuildContext context) {
    return GameHomePageLayout(
      game: _game,
      onOpenAudioSettings: _openAudioSettings,
    );
  }

  /// BGM と効果音の個別音量を調節するシートを開きます。
  void _openAudioSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => GameAudioSettingsSheet(controller: _audio),
    );
  }
}
