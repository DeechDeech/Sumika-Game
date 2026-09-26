import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sumika_game/app/sumika_app.dart';
import 'package:sumika_game/game/audio/game_audio_controller.dart';
import 'package:sumika_game/game/engine/fruit_drop_cooldown.dart';
import 'package:sumika_game/game/engine/sumika_game.dart';
import 'package:sumika_game/game/presentation/widgets/game_audio_settings_sheet.dart';

abstract final class WidgetTestConstants {
  static const Size audioSettingsViewport = Size(400, 800);
  static const double audioSettingsPixelRatio = 1;
  static const double sliderDragDistance = 80;
  static const double halfDurationFactor = 0.5;
  static const String gameTitle = 'ころころ果樹園';
  static const String resetLabel = 'やり直す';
  static const String audioSettingsTooltip = '音量設定';
  static const String bgmLabel = 'BGM';
  static const String seLabel = '効果音';
  static const String cooldownTestName = 'fruit drops respect cooldown';
  static const String sliderTestName =
      'audio sliders respond to dragging independently';
  static const String gameScreenTestName =
      'game screen loads with a Flame game widget';
}

/// クールタイム、音量操作、ゲーム画面の表示を個別に検証します。
void main() {
  test(WidgetTestConstants.cooldownTestName, () {
    final cooldown = FruitDropCooldown();
    final halfCooldown =
        FruitDropCooldownConstants.durationSeconds *
        WidgetTestConstants.halfDurationFactor;

    expect(cooldown.tryStart(), isTrue);
    expect(cooldown.tryStart(), isFalse);

    cooldown.advance(halfCooldown);
    expect(cooldown.tryStart(), isFalse);

    cooldown.advance(halfCooldown);
    expect(cooldown.tryStart(), isTrue);
  });

  testWidgets(WidgetTestConstants.sliderTestName, (tester) async {
    tester.view.physicalSize = WidgetTestConstants.audioSettingsViewport;
    tester.view.devicePixelRatio = WidgetTestConstants.audioSettingsPixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final audio = GameAudioController.instance;
    audio.setBgmVolume(GameAudioConstants.defaultBgmVolume);
    audio.setSeVolume(GameAudioConstants.defaultSeVolume);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameAudioSettingsSheet(controller: audio)),
      ),
    );

    expect(find.text(WidgetTestConstants.bgmLabel), findsOneWidget);
    expect(find.text(WidgetTestConstants.seLabel), findsOneWidget);

    final sliders = find.byType(Slider);
    expect(sliders, findsNWidgets(2));
    await tester.drag(
      sliders.first,
      const Offset(WidgetTestConstants.sliderDragDistance, 0),
    );
    await tester.pump();

    expect(
      tester.widget<Slider>(sliders.first).value,
      isNot(GameAudioConstants.defaultBgmVolume),
    );
    expect(
      tester.widget<Slider>(sliders.at(1)).value,
      GameAudioConstants.defaultSeVolume,
    );
  });

  testWidgets(WidgetTestConstants.gameScreenTestName, (tester) async {
    await tester.pumpWidget(const SumikaApp());
    await tester.pump();

    expect(find.text(WidgetTestConstants.gameTitle), findsOneWidget);
    expect(find.byType(GameWidget<SumikaGame>), findsOneWidget);
    expect(find.text(WidgetTestConstants.resetLabel), findsOneWidget);
    expect(
      find.byTooltip(WidgetTestConstants.audioSettingsTooltip),
      findsOneWidget,
    );
  });
}
