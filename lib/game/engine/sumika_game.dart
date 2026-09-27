import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import 'arena_component.dart';
import 'fruit_drop_cooldown.dart';
import 'fruit_component.dart';
import 'fruit_kind.dart';
import 'drop_ship_component.dart';

abstract final class SumikaGameConstants {
  static const double gravityX = 0;
  static const double gravityY = 10;
  static const double cameraZoom = FruitKindConstants.logicalPixelsPerWorldUnit;
  static const Color backgroundColor = Color(0xFFDCE5D5);
  static const double horizontalDropMargin = 0.5;
  static const double verticalSpawnMargin = 0.45;
  static const double arenaTopInset = 12;
  static const double repeatedDropJitter = 0.04;
  static const double worldCenterDivisor = 2;
  static const int startingFruitVarietyCount = 5;
  static const int initialScore = 0;
  static const int maximumScore = 99999;
  static const int scoreTierOffset = 1;
  static const int scorePerTier = 10;
  static const FruitKind firstFruit = FruitKind.fruit01;
}

class SumikaGame extends Forge2DGame
  with MultiTouchDragDetector, MouseMovementDetector {
  /// 下向きの重力とゲーム用カメラを設定した物理ゲームを作成します。
  SumikaGame({this.onFruitDropped, this.onFruitMerged, this.onGameOver})
    : super(
        gravity: Vector2(
          SumikaGameConstants.gravityX,
          SumikaGameConstants.gravityY,
        ),
        zoom: SumikaGameConstants.cameraZoom,
      );

  /// 果実の投下が成立したとき、投下した種類を通知します。
  final void Function(FruitKind kind)? onFruitDropped;

  /// 果実の合体成立時に、合体した果実の種類を通知します。
  final void Function(FruitKind kind)? onFruitMerged;
  final void Function(int finalScore)? onGameOver;

  final Random _random = Random();
  final ValueNotifier<int> score = ValueNotifier<int>(
    SumikaGameConstants.initialScore,
  );
  final ValueNotifier<FruitKind> currentFruit = ValueNotifier<FruitKind>(
    SumikaGameConstants.firstFruit,
  );
  late final ValueNotifier<FruitKind> nextFruit = ValueNotifier<FruitKind>(
    _randomStartingFruit(),
  );
  final List<(FruitComponent, FruitComponent)> _pendingMerges = [];
  final FruitDropCooldown _dropCooldown = FruitDropCooldown();
  DropShipComponent? _dropShip;
  double? _lastDropX;
  int? _activeDropPointer;
  double _dragTargetX = 0;
  bool _gameOver = false;

  /// ゲーム領域の背景色を返します。
  @override
  Color backgroundColor() => SumikaGameConstants.backgroundColor;

  /// Flame の読み込み後に、果実を受け止める箱を物理世界へ追加します。
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final worldSize = _worldSize;
    await world.add(
      ArenaComponent(
        width: worldSize.x,
        height: worldSize.y,
        topInset: SumikaGameConstants.arenaTopInset,
      ),
    );
    _dropShip = DropShipComponent(
      fruitKind: currentFruit.value,
      position: Vector2.zero(),
    );
    world.add(_dropShip!);
    _moveDropShip(0);
  }

  /// 押した位置へプレビューを移動し、離すまで投下位置を追跡します。
  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    if (_gameOver || _dropShip == null || !_dropCooldown.isReady) return;

    _activeDropPointer = pointerId;
    _dragTargetX = screenToWorld(info.eventPosition.widget).x;
    _moveDropShip(_dragTargetX);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (_activeDropPointer != pointerId || _gameOver) return;

    _dragTargetX = screenToWorld(info.eventPosition.widget).x;
    _moveDropShip(_dragTargetX);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    if (_activeDropPointer != pointerId) return;

    _activeDropPointer = null;
    if (!_gameOver) _dropFruit(_dragTargetX);
  }

  @override
  void onDragCancel(int pointerId) {
    if (_activeDropPointer == pointerId) _activeDropPointer = null;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (_gameOver || _dropShip == null || _activeDropPointer != null) return;
    _dragTargetX = screenToWorld(info.eventPosition.widget).x;
    _moveDropShip(_dragTargetX);
  }

  /// Forge2D を更新した後、接触コールバックで記録した合体を処理します。
  @override
  void update(double dt) {
    super.update(dt);
    _dropCooldown.advance(dt);
    _processPendingMerges();
    _checkGameOver();
  }

  /// 盤面の果実と合体予約を消し、スコアと次の果実を初期状態へ戻します。
  void reset() {
    _pendingMerges.clear();
    _dropCooldown.reset();
    _lastDropX = null;
    _activeDropPointer = null;
    _gameOver = false;
    for (final fruit in _fruits) {
      fruit.removeFromParent();
    }
    score.value = SumikaGameConstants.initialScore;
    currentFruit.value = SumikaGameConstants.firstFruit;
    nextFruit.value = _randomStartingFruit();
    _moveDropShip(0);
  }

  /// 物理ワールドに現在登録されている果実だけを取り出します。
  Iterable<FruitComponent> get _fruits =>
      world.children.whereType<FruitComponent>();

  /// カメラのズームを考慮した、画面サイズのワールド座標表現です。
  Vector2 get _worldSize =>
      Vector2(size.x / camera.viewfinder.zoom, size.y / camera.viewfinder.zoom);

  double get _dangerLineY =>
      -_worldSize.y / SumikaGameConstants.worldCenterDivisor +
      SumikaGameConstants.arenaTopInset +
      ArenaComponentConstants.dangerLineOffset;

  void _moveDropShip(double targetX) {
    final kind = currentFruit.value;
    final margin = kind.radius + SumikaGameConstants.horizontalDropMargin;
    final halfWidth = _worldSize.x / SumikaGameConstants.worldCenterDivisor;
    final safeX = targetX.clamp(-halfWidth + margin, halfWidth - margin);
    _dropShip?.follow(fruitKind: kind, x: safeX, lineY: _dangerLineY);
  }

  /// 果実の大きさに合わせて横位置を制限し、盤面上端から投下します。
  void _dropFruit(double targetX) {
    final kind = currentFruit.value;
    final worldSize = _worldSize;
    final margin = kind.radius + SumikaGameConstants.horizontalDropMargin;
    final minX = -worldSize.x / SumikaGameConstants.worldCenterDivisor + margin;
    final maxX = worldSize.x / SumikaGameConstants.worldCenterDivisor - margin;
    final safeX = targetX.clamp(minX, maxX).toDouble();
    var spawnX = safeX;
    if (_lastDropX == safeX) {
      var offset =
          (_random.nextDouble() * 2 - 1) *
          SumikaGameConstants.repeatedDropJitter;
      if (offset == 0) offset = SumikaGameConstants.repeatedDropJitter;
      spawnX = (safeX + offset).clamp(minX, maxX).toDouble();
      if (spawnX == safeX) {
        spawnX = (safeX - offset).clamp(minX, maxX).toDouble();
      }
    }
    final spawnPosition = Vector2(spawnX, _dropShip!.fruitCenterPosition.y);
    final overlapsExistingFruit = _fruits.any(
      (fruit) =>
          fruit.isMounted &&
          !fruit.isRemoving &&
          fruit.overlapsAt(spawnPosition, kind),
    );
    if (overlapsExistingFruit || !_dropCooldown.tryStart()) return;

    _lastDropX = safeX;
    _moveDropShip(spawnX);

    world.add(
      FruitComponent(
        kind: kind,
        position: spawnPosition,
        onFruitContact: _queueMerge,
      ),
    );
    onFruitDropped?.call(kind);

    currentFruit.value = nextFruit.value;
    nextFruit.value = _randomStartingFruit();
    _moveDropShip(spawnX);
  }

  FruitKind _randomStartingFruit() {
    final startingKinds = FruitKind.values
        .take(SumikaGameConstants.startingFruitVarietyCount)
        .toList();
    return startingKinds[_random.nextInt(startingKinds.length)];
  }

  /// 同じ種類の果実が接触した組を一度だけ合体予約へ追加します。
  void _queueMerge(FruitComponent first, FruitComponent second) {
    if (first.kind != second.kind || first.isMerging || second.isMerging) {
      return;
    }

    first.isMerging = true;
    second.isMerging = true;
    _pendingMerges.add((first, second));
  }

  /// 物理計算の終了後に予約済みの果実を置き換え、スコアを加算します。
  void _processPendingMerges() {
    for (final (first, second) in _pendingMerges) {
      if (first.isRemoving || second.isRemoving) continue;

      final mergeScore =
          (first.kind.index + SumikaGameConstants.scoreTierOffset) *
          SumikaGameConstants.scorePerTier;
      score.value = min(
        score.value + mergeScore,
        SumikaGameConstants.maximumScore,
      );
      final nextKind = first.kind.next;
      if (nextKind == null) {
        first.removeFromParent();
        second.removeFromParent();
        onFruitMerged?.call(first.kind);
        continue;
      }
      final mergePosition = Vector2(
        (first.position.x + second.position.x) /
            SumikaGameConstants.worldCenterDivisor,
        (first.position.y + second.position.y) /
            SumikaGameConstants.worldCenterDivisor,
      );
      first.removeFromParent();
      second.removeFromParent();
      world.add(
        FruitComponent(
          kind: nextKind,
          position: mergePosition,
          onFruitContact: _queueMerge,
        ),
      );
      onFruitMerged?.call(first.kind);
    }
    _pendingMerges.clear();
  }

  void _checkGameOver() {
    if (_gameOver) return;
    final hasSettledFruitAboveLine = _fruits.any(
      (fruit) =>
          fruit.isMounted &&
          !fruit.isRemoving &&
          !fruit.isMerging &&
          !fruit.body.isAwake &&
          fruit.position.y - fruit.kind.radius < _dangerLineY,
    );
    if (!hasSettledFruitAboveLine) return;

    _gameOver = true;
    onGameOver?.call(score.value);
  }
}
