import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/foundation.dart';

import 'arena_component.dart';
import 'fruit_component.dart';
import 'fruit_kind.dart';

class SumikaGame extends Forge2DGame with TapCallbacks {
  SumikaGame() : super(gravity: Vector2(0, 10), zoom: 12);

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<FruitKind> nextFruit = ValueNotifier<FruitKind>(
    FruitKind.berry,
  );
  final Random _random = Random();
  final List<(FruitComponent, FruitComponent)> _pendingMerges = [];

  @override
  Color backgroundColor() => const Color(0xFFDCE5D5);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final worldSize = _worldSize;
    await world.add(
      ArenaComponent(width: worldSize.x, height: worldSize.y),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final target = screenToWorld(event.localPosition);
    _dropFruit(target.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _processPendingMerges();
  }

  void reset() {
    _pendingMerges.clear();
    for (final fruit in _fruits) {
      fruit.removeFromParent();
    }
    score.value = 0;
    nextFruit.value = FruitKind.berry;
  }

  Iterable<FruitComponent> get _fruits =>
      world.children.whereType<FruitComponent>();

  Vector2 get _worldSize => Vector2(
    size.x / camera.viewfinder.zoom,
    size.y / camera.viewfinder.zoom,
  );

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
