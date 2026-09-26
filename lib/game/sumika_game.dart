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

  @override
  Color backgroundColor() => const Color(0xFFDCE5D5);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await world.add(ArenaComponent(width: size.x, height: size.y));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final target = screenToWorld(event.localPosition);
    _dropFruit(target.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _mergeTouchingFruit();
  }

  void reset() {
    for (final fruit in _fruits) {
      fruit.removeFromParent();
    }
    score.value = 0;
    nextFruit.value = FruitKind.berry;
  }

  Iterable<FruitComponent> get _fruits =>
      world.children.whereType<FruitComponent>();

  void _dropFruit(double targetX) {
    final kind = nextFruit.value;
    final margin = kind.radius + 0.5;
    final safeX = targetX.clamp(-size.x / 2 + margin, size.x / 2 - margin);
    final spawnY = -size.y / 2 + kind.radius + 1.2;

    world.add(FruitComponent(kind: kind, position: Vector2(safeX, spawnY)));

    final startingKinds = FruitKind.values.take(3).toList();
    nextFruit.value = startingKinds[_random.nextInt(startingKinds.length)];
  }

  void _mergeTouchingFruit() {
    final fruits = _fruits.where((fruit) => !fruit.isMerging).toList();

    for (var firstIndex = 0; firstIndex < fruits.length; firstIndex++) {
      final first = fruits[firstIndex];
      final nextKind = first.kind.next;
      if (nextKind == null || first.isRemoving) continue;

      for (
        var secondIndex = firstIndex + 1;
        secondIndex < fruits.length;
        secondIndex++
      ) {
        final second = fruits[secondIndex];
        if (second.kind != first.kind || second.isRemoving) continue;

        final dx = first.position.x - second.position.x;
        final dy = first.position.y - second.position.y;
        final touchDistance = (first.kind.radius + second.kind.radius) * 1.02;
        if (dx * dx + dy * dy > touchDistance * touchDistance) continue;

        first.isMerging = true;
        second.isMerging = true;
        final mergePosition = Vector2(
          (first.position.x + second.position.x) / 2,
          (first.position.y + second.position.y) / 2,
        );
        first.removeFromParent();
        second.removeFromParent();
        world.add(FruitComponent(kind: nextKind, position: mergePosition));
        score.value += (first.kind.index + 1) * 10;
        break;
      }
    }
  }
}
