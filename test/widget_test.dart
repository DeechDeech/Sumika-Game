import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sumika_game/app/sumika_app.dart';
import 'package:sumika_game/game/audio/game_audio_controller.dart';
import 'package:sumika_game/game/engine/fruit_drop_cooldown.dart';
import 'package:sumika_game/game/engine/fruit_component.dart';
import 'package:sumika_game/game/engine/fruit_kind.dart';
import 'package:sumika_game/game/engine/game_context.dart';
import 'package:sumika_game/game/game_content.dart';
import 'package:sumika_game/game/engine/sumika_game.dart';
import 'package:sumika_game/game/presentation/widgets/game_board.dart';
import 'package:sumika_game/game/presentation/widgets/game_header.dart';
import 'package:sumika_game/game/presentation/widgets/game_over_dialog.dart';
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
    const expectedLabels = [
      'フルーツ01',
      'フルーツ02',
      'フルーツ03',
      'フルーツ04',
      'フルーツ05',
      'フルーツ06',
      'フルーツ07',
      'フルーツ08',
      'フルーツ09',
      'フルーツ10',
      'フルーツ11',
    ];
    const expectedColors = [
      0xFFC7475A,
      0xFF79549A,
      0xFFB98217,
      0xFF548B45,
      0xFFD36A45,
      0xFF287F78,
      0xFFA43F79,
      0xFF397EAE,
      0xFF89772A,
      0xFF545FA6,
      0xFF278F9E,
    ];
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
    expect(kinds.map((kind) => kind.label), expectedLabels);
    expect(kinds.map((kind) => kind.colorValue), expectedColors);
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

  test('fruit outline width scales with fruit size', () {
    final kinds = FruitKind.values;

    for (var index = 1; index < kinds.length; index++) {
      expect(
        kinds[index].outlineWidth,
        greaterThan(kinds[index - 1].outlineWidth),
      );
      expect(
        kinds[index].outlineWidth / kinds[index].radius,
        closeTo(GameContextConstants.fruitOutlineWidthRatio, 0.000001),
      );
    }
  });

  test('merge score remains fixed after game over', () {
    expect(
      scoreAfterMerge(currentScore: 120, mergeScore: 30, gameOver: true),
      120,
    );
    expect(
      scoreAfterMerge(currentScore: 120, mergeScore: 30, gameOver: false),
      150,
    );
  });

  test('merged fruits start with eyes closed', () {
    final fruit = FruitComponent(
      kind: FruitKind.fruit02,
      position: Vector2.zero(),
      onFruitContact: (_, _) {},
      closeEyesUntilSettled: GameContextConstants.mergedFruitStartsEyesClosed,
    );

    expect(fruit.eyesClosed, isTrue);
  });

  test('game over leaves placed fruits with open eyes', () {
    final fruit = FruitComponent(
      kind: FruitKind.fruit04,
      position: Vector2.zero(),
      onFruitContact: (_, _) {},
      closeEyesUntilSettled: GameContextConstants.mergedFruitStartsEyesClosed,
    );

    fruit.setEyesClosed(false);

    expect(fruit.eyesClosed, isFalse);
  });

  test('merged fruit opens eyes two seconds after creation while moving', () {
    final timer = FruitSettledEyeTimer();

    expect(timer.advance(1), isFalse);
    expect(timer.advance(1), isTrue);
  });

  testWidgets('game-over close button returns to the game screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: const Text('Game screen'),
            floatingActionButton: FloatingActionButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => GameOverDialog(
                  finalScore: 120,
                  onClose: () => Navigator.of(dialogContext).pop(),
                  onRetry: () {},
                ),
              ),
              child: const Text('Show game over'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show game over'));
    await tester.pumpAndSettle();
    expect(find.text('${GameContent.gameOverScorePrefix}120'), findsOneWidget);
    final closeButton = find.widgetWithText(
      TextButton,
      GameContent.closeButton,
    );
    final retryButton = find.widgetWithText(
      FilledButton,
      GameContent.retryButton,
    );
    expect(tester.getSize(closeButton), tester.getSize(retryButton));
    final closeButtonStyle = tester.widget<TextButton>(closeButton).style!;
    final retryButtonStyle = tester.widget<FilledButton>(retryButton).style!;
    expect(
      closeButtonStyle.textStyle!.resolve({})!.fontSize,
      retryButtonStyle.textStyle!.resolve({})!.fontSize,
    );
    expect(tester.widget<Text>(find.text(GameContent.retryButton)).maxLines, 1);
    expect(
      tester.getCenter(closeButton).dx,
      lessThan(tester.getCenter(retryButton).dx),
    );
    expect(
      tester
          .widget<TextButton>(closeButton)
          .style!
          .backgroundColor!
          .resolve({}),
      const Color(GameContextConstants.gameOverCloseButtonBackgroundColor),
    );
    expect(
      tester
          .widget<Text>(find.text('${GameContent.gameOverScorePrefix}120'))
          .style!
          .fontSize,
      GameContextConstants.gameOverScoreFontSize,
    );
    expect(
      tester.widget<Text>(find.text(GameContent.gameOverTitle)).style!.fontSize,
      GameContextConstants.gameOverScoreFontSize,
    );

    await tester.tap(find.text(GameContent.closeButton));
    await tester.pumpAndSettle();

    expect(find.text('Game screen'), findsOneWidget);
    expect(find.text('${GameContent.gameOverScorePrefix}120'), findsNothing);
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
    final isGameOver = ValueNotifier<bool>(false);
    addTearDown(nextFruit.dispose);
    addTearDown(score.dispose);
    addTearDown(isGameOver.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GameHeader(
              nextFruit: nextFruit,
              score: score,
              isGameOver: isGameOver,
            ),
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
    final fruitDecoration =
        tester
                .widget<Container>(find.byKey(GameHeaderConstants.nextFruitKey))
                .foregroundDecoration!
            as BoxDecoration;
    expect(fruitDecoration.border!.top.color, FruitKind.fruit05.color);
    final largestFruitSize = tester.getSize(
      find.byKey(GameHeaderConstants.nextFruitKey),
    );
    expect(largestFruitSize.width, greaterThan(initialFruitSize.width));
    expect(
      largestFruitSize.width,
      lessThanOrEqualTo(GameHeaderConstants.nextFruitSlotSize),
    );

    isGameOver.value = true;
    await tester.pump();
    final closedOddNumberedPreview = tester.widget<Image>(
      find.descendant(
        of: find.byKey(GameHeaderConstants.nextFruitKey),
        matching: find.byType(Image),
      ),
    );
    expect(
      (closedOddNumberedPreview.image as AssetImage).assetName,
      'assets/images/${FruitKind.fruit05.closedEyeAsset}',
    );

    nextFruit.value = FruitKind.fruit04;
    await tester.pump();
    final closedEvenNumberedPreview = tester.widget<Image>(
      find.descendant(
        of: find.byKey(GameHeaderConstants.nextFruitKey),
        matching: find.byType(Image),
      ),
    );
    expect(
      (closedEvenNumberedPreview.image as AssetImage).assetName,
      'assets/images/${FruitKind.fruit04.closedEyeAsset}',
    );
  });

  test('game images are included in the asset manifest', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assetPaths = manifest.listAssets().toSet();

    expect(assetPaths, contains('assets/images/backgrounds/ship_original.png'));
    expect(assetPaths, contains('assets/images/backgrounds/ship.png'));
    expect(assetPaths, contains('assets/images/backgrounds/deck.png'));
    expect(assetPaths, contains('assets/images/branding/app_icon.png'));
    expect(assetPaths, contains('assets/images/branding/title_logo.png'));
    for (final kind in FruitKind.values) {
      expect(assetPaths, contains('assets/images/${kind.imageAsset}'));
      expect(assetPaths, contains('assets/images/${kind.closedEyeAsset}'));
      expect(assetPaths, contains('assets/images/${kind.outlinedAsset}'));
      expect(
        assetPaths,
        contains('assets/images/${kind.outlinedClosedEyeAsset}'),
      );
    }
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
    final fieldSize = tester.getSize(find.byType(GameBoard));
    expect(
      fieldSize.width / fieldSize.height,
      closeTo(GameContextConstants.gameFieldAspectRatio, 0.001),
    );
    final boardDecoration =
        tester
                .widget<Container>(
                  find.byKey(GameBoardConstants.boardContainerKey),
                )
                .decoration!
            as BoxDecoration;
    expect(
      boardDecoration.border!.top.color,
      const Color(GameBoardConstants.borderColorValue),
    );
  });

  testWidgets('fruit can be dragged when starting over another fruit', (
    tester,
  ) async {
    final droppedKinds = <FruitKind>[];
    final game = SumikaGame(onFruitDropped: droppedKinds.add);
    const gameSize = Size(400, 600);
    tester.view.physicalSize = gameSize;
    tester.view.devicePixelRatio = WidgetTestConstants.audioSettingsPixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<SumikaGame>(game: game)),
      ),
    );
    await tester.runAsync(() async {
      await game.toBeLoaded();
    });
    game.world.add(
      FruitComponent(
        kind: FruitKind.fruit01,
        position: Vector2.zero(),
        onFruitContact: (_, _) {},
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    final gameBounds = tester.getRect(find.byType(GameWidget<SumikaGame>));
    final gesture = await tester.startGesture(gameBounds.center);
    await gesture.moveTo(
      Offset(gameBounds.left + gameSize.width * 0.7, gameBounds.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(droppedKinds, isEmpty);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));

    expect(droppedKinds, hasLength(1));
    game.dispose();
  });

  testWidgets('drop preview moves after game over without dropping', (
    tester,
  ) async {
    final droppedKinds = <FruitKind>[];
    final game = SumikaGame(onFruitDropped: droppedKinds.add);
    const gameSize = Size(400, 600);
    tester.view.physicalSize = gameSize;
    tester.view.devicePixelRatio = WidgetTestConstants.audioSettingsPixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GameWidget<SumikaGame>(game: game)),
      ),
    );
    await tester.runAsync(() async {
      await game.toBeLoaded();
    });
    await tester.pump(const Duration(milliseconds: 16));

    game.isGameOver.value = true;
    game.enableDropPreviewMovementAfterGameOver();
    final initialX = game.dropPreviewX;
    expect(initialX, isNotNull);
    final gameBounds = tester.getRect(find.byType(GameWidget<SumikaGame>));
    final gesture = await tester.startGesture(gameBounds.center);
    await gesture.moveTo(
      Offset(gameBounds.left + gameSize.width * 0.75, gameBounds.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(game.dropPreviewX, isNot(initialX));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));
    expect(droppedKinds, isEmpty);

    game.dispose();
  });
}
