import 'package:flutter/material.dart';

import '../game/presentation/game_home_page.dart';
import 'app_theme.dart';

class SumikaApp extends StatelessWidget {
  /// アプリのルートウィジェットを作成します。
  const SumikaApp({super.key});

  /// 共通テーマを適用し、最初にゲーム画面を表示します。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTheme.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const GameHomePage(),
    );
  }
}
