import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'fruit_kind.dart';
import 'sumika_game.dart';

class GameHomePage extends StatefulWidget {
  const GameHomePage({super.key});

  @override
  State<GameHomePage> createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  final SumikaGame _game = SumikaGame();

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF263A35);
    const muted = Color(0xFF728078);
    const coral = Color(0xFFCB654C);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(constraints.maxWidth, 480.0);

            return Center(
              child: SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: ink,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Color(0xFFF2CF76),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ころころ果樹園',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'FRUIT DROP STUDY  /  01',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder<FruitKind>(
                            valueListenable: _game.nextFruit,
                            builder: (context, fruit, _) => Container(
                              padding: const EdgeInsets.fromLTRB(11, 7, 12, 7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: ink.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'NEXT',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Container(
                                    width: 19,
                                    height: 19,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: fruit.color,
                                      border: Border.all(
                                        color: ink.withValues(alpha: 0.12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 9),
                          ValueListenableBuilder<int>(
                            valueListenable: _game.score,
                            builder: (context, score, _) => Text(
                              score.toString().padLeft(4, '0'),
                              style: const TextStyle(
                                color: ink,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '同じフルーツを合わせよう',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE5D5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: ink.withValues(alpha: 0.14),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A263A35),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: GameWidget(game: _game),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 17,
                            color: muted,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              '落とす位置をタップ',
                              style: TextStyle(
                                color: muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _game.reset,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('やり直す'),
                            style: FilledButton.styleFrom(
                              foregroundColor: ink,
                              backgroundColor: const Color(0xFFE3E8DB),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 39,
                            height: 39,
                            decoration: BoxDecoration(
                              color: coral,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.sports_esports_rounded,
                              size: 19,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
