// Flutter ウィジェットテストの基本例です。
//
// WidgetTester を使ってタップやスクロールなどの操作を行い、
// ウィジェットツリーや画面に表示された値を確認できます。

import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';

import 'package:sumika_game/game/sumika_game.dart';
import 'package:sumika_game/main.dart';

void main() {
  testWidgets('game screen loads with a Flame game widget', (tester) async {
    await tester.pumpWidget(const SumikaApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ころころ果樹園'), findsOneWidget);
    expect(find.byType(GameWidget<SumikaGame>), findsOneWidget);
    expect(find.text('やり直す'), findsOneWidget);
  });
}
