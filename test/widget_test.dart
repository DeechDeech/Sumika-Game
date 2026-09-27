import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sumika_game/app/sumika_app.dart';
import 'package:sumika_game/game/audio/game_audio_controller.dart';
import 'package:sumika_game/game/engine/fruit_drop_cooldown.dart';
import 'package:sumika_game/game/engine/fruit_component.dart';
import 'package:sumika_game/game/engine/fruit_kind.dart';
import 'package:sumika_game/game/engine/sumika_game.dart';
import 'package:sumika_game/game/presentation/widgets/game_header.dart';
import 'package:sumika_game/game/presentation/widgets/game_audio_settings_sheet.dart';

abstract final class WidgetTestConstants {
  static const Size audioSettingsViewport = Size(400, 800);
  static const double audioSettingsPixelRatio = 1;
  static const double sliderDragDistance = 80;
  static const double halfDurationFactor = 0.5;
  static const String gameTitle = 'スミカゲーム';
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
    expect(cooldown.isReady, isFalse);

    cooldown.advance(halfCooldown);
    expect(cooldown.tryStart(), isFalse);

    cooldown.advance(halfCooldown);
    expect(cooldown.tryStart(), isTrue);
    expect(cooldown.isReady, isFalse);
  });

  test('fruit placement rejects overlap but allows edge contact', () {
    final radius = FruitKind.fruit01.radius;

    expect(
      FruitComponent.circlesOverlap(
        firstPosition: Vector2.zero(),
        firstRadius: radius,
        secondPosition: Vector2.zero(),
        secondRadius: radius,
      ),
      isTrue,
    );
    expect(
      FruitComponent.circlesOverlap(
        firstPosition: Vector2.zero(),
        firstRadius: radius,
        secondPosition: Vector2(radius * 2, 0),
        secondRadius: radius,
      ),
      isFalse,
    );
  });

  test('fruit kinds increase by radius and have five drop choices', () {
    final kinds = FruitKind.values;
    const expectedRadiusPixels = [
      23.0,
      30.5,
      41.5,
      51.5,
      60.5,
      71.0,
      78.5,
      81.0,
      88.5,
      110.0,
      129.5,
    ];

    expect(kinds, hasLength(11));
    for (var index = 1; index < kinds.length; index++) {
      expect(kinds[index].radius, greaterThan(kinds[index - 1].radius));
    }
    for (var index = 0; index < kinds.length; index++) {
      expect(
        kinds[index].radius * FruitKindConstants.logicalPixelsPerWorldUnit,
        closeTo(expectedRadiusPixels[index], 0.001),
      );
    }
    expect(SumikaGameConstants.startingFruitVarietyCount, 5);
    expect(
      kinds.take(SumikaGameConstants.startingFruitVarietyCount),
      hasLength(5),
    );
    expect(kinds.last.next, isNull);
  });

  test('next fruit is separate from the currently selected fruit', () {
    final game = SumikaGame();
    final startingKinds = FruitKind.values.take(
      SumikaGameConstants.startingFruitVarietyCount,
    );

    expect(game.currentFruit.value, SumikaGameConstants.firstFruit);
    expect(startingKinds, contains(game.nextFruit.value));
    game.dispose();
  });

  testWidgets('next preview size and center stay fixed', (tester) async {
    final nextFruit = ValueNotifier<FruitKind>(FruitKind.fruit01);
    final score = ValueNotifier<int>(0);
    addTearDown(nextFruit.dispose);
    addTearDown(score.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameHeader(nextFruit: nextFruit, score: score),
          ),
        ),
      ),
    );
    final cardSize = tester.getSize(
      find.byKey(GameHeaderConstants.nextCardKey),
    );
    final slotCenter = tester.getCenter(
      find.byKey(GameHeaderConstants.nextFruitSlotKey),
    );
    final fruitCenter = tester.getCenter(
      find.byKey(GameHeaderConstants.nextFruitKey),
    );
    final initialFruitSize = tester.getSize(
      find.byKey(GameHeaderConstants.nextFruitKey),
    );

    nextFruit.value = FruitKind.fruit05;
    await tester.pump();

    expect(
      tester.getSize(find.byKey(GameHeaderConstants.nextCardKey)),
      cardSize,
    );
    expect(
      tester.getCenter(find.byKey(GameHeaderConstants.nextFruitSlotKey)),
      slotCenter,
    );
    expect(
      tester.getCenter(find.byKey(GameHeaderConstants.nextFruitKey)),
      fruitCenter,
    );
    final fruitDecoration = tester
        .widget<Container>(find.byKey(GameHeaderConstants.nextFruitKey))
        .foregroundDecoration! as BoxDecoration;
    expect(fruitDecoration.border!.top.color, FruitKind.fruit05.color);
    final largestFruitSize = tester.getSize(
      find.byKey(GameHeaderConstants.nextFruitKey),
    );
    expect(largestFruitSize.width, greaterThan(initialFruitSize.width));
    expect(
      largestFruitSize.width,
      lessThanOrEqualTo(GameHeaderConstants.nextFruitSlotSize),
    );
  });

  test('ship background is included in the asset manifest', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    expect(
      manifest.listAssets(),
      contains('assets/images/backgrounds/ship.png'),
    );
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

  testWidgets('fruit drops at the drag release position', (tester) async {
    final droppedKinds = <FruitKind>[];
    final game = SumikaGame(onFruitDropped: droppedKinds.add);
    const gameSize = Size(400, 600);
    tester.view.physicalSize = gameSize;
    tester.view.devicePixelRatio = WidgetTestConstants.audioSettingsPixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameWidget<SumikaGame>(game: game),
        ),
      ),
    );
    await tester.runAsync(() async {
      await game.toBeLoaded();
    });
    await tester.pump(const Duration(milliseconds: 16));

    final gameBounds = tester.getRect(find.byType(GameWidget<SumikaGame>));
    final gesture = await tester.startGesture(
      Offset(gameBounds.left + gameSize.width * 0.3, gameBounds.top + 40),
    );
    await gesture.moveTo(
      Offset(gameBounds.left + gameSize.width * 0.7, gameBounds.top + 40),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(droppedKinds, isEmpty);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));

    expect(droppedKinds, hasLength(1));
    game.dispose();
  });
}
