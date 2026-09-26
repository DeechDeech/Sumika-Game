// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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
