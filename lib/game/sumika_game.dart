import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import 'arena_component.dart';
import 'fruit_component.dart';
import 'fruit_kind.dart';

class SumikaGame extends Forge2DGame with TapCallbacks {
  /// 下向きの重力とゲーム用カメラを設定した物理ゲームを作成します。
  SumikaGame() : super(gravity: Vector2(0, 10), zoom: 12);

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<FruitKind> nextFruit = ValueNotifier<FruitKind>(
    FruitKind.berry,
  );
  final Random _random = Random();
  final List<(FruitComponent, FruitComponent)> _pendingMerges = [];

  /// ゲーム領域の背景色を返します。
  @override
  Color backgroundColor() => const Color(0xFFDCE5D5);

  /// Flame の読み込み後に、果実を受け止める箱を物理世界へ追加します。
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final worldSize = _worldSize;
    await world.add(ArenaComponent(width: worldSize.x, height: worldSize.y));
  }

  /// タップ位置をワールド座標へ変換し、その位置に果実を投下します。
  @override
  void onTapDown(TapDownEvent event) {
    final target = screenToWorld(event.localPosition);
    _dropFruit(target.x);
  }

  /// Forge2D を更新した後、接触コールバックで記録した合体を処理します。
  @override
  void update(double dt) {
    super.update(dt);
    _processPendingMerges();
  }

  /// 盤面の果実と合体予約を消し、スコアと次の果実を初期状態へ戻します。
  void reset() {
    _pendingMerges.clear();
    for (final fruit in _fruits) {
      fruit.removeFromParent();
    }
    score.value = 0;
    nextFruit.value = FruitKind.berry;
  }

  /// 物理ワールドに現在登録されている果実だけを取り出します。
  Iterable<FruitComponent> get _fruits =>
      world.children.whereType<FruitComponent>();

  /// カメラのズームを考慮した、画面サイズのワールド座標表現です。
  Vector2 get _worldSize =>
      Vector2(size.x / camera.viewfinder.zoom, size.y / camera.viewfinder.zoom);

  /// 果実の大きさに合わせて横位置を制限し、盤面上端から投下します。
  void _dropFruit(double targetX) {
    final kind = nextFruit.value;
    final worldSize = _worldSize;
    final margin = kind.radius + 0.5;
    final safeX = targetX.clamp(
      -worldSize.x / 2 + margin,
      worldSize.x / 2 - margin,
    );
    final spawnY = -worldSize.y / 2 + kind.radius + 1.2;

    world.add(
      FruitComponent(
        kind: kind,
        position: Vector2(safeX, spawnY),
        onFruitContact: _queueMerge,
      ),
    );

    final startingKinds = FruitKind.values.take(3).toList();
    nextFruit.value = startingKinds[_random.nextInt(startingKinds.length)];
  }

  /// 同じ種類の果実が接触した組を一度だけ合体予約へ追加します。
  void _queueMerge(FruitComponent first, FruitComponent second) {
    if (first.kind != second.kind ||
        first.kind.next == null ||
        first.isMerging ||
        second.isMerging) {
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

      final nextKind = first.kind.next!;
      final mergePosition = Vector2(
        (first.position.x + second.position.x) / 2,
        (first.position.y + second.position.y) / 2,
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
      score.value += (first.kind.index + 1) * 10;
    }
    _pendingMerges.clear();
  }
}
