import 'package:flutter/material.dart';

import 'game/game_home_page.dart';

/// Flutter アプリを起動し、ルートウィジェットを画面に表示します。
void main() {
  runApp(const SumikaApp());
}

class SumikaApp extends StatelessWidget {
  /// アプリのルートウィジェットを作成します。
  const SumikaApp({super.key});

  /// アプリ名、配色テーマ、最初に表示するゲーム画面を設定します。
  // このウィジェットはアプリのルートです。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ころころ果樹園',
      theme: ThemeData(
        // ここではアプリ全体のテーマを設定します。
        // ホットリロードでテーマの変更をすぐに確認できます。
        // ホットリロードではアプリの状態が保たれます。
        // 状態も初期化したい場合は、ホットリスタートを使います。
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCB654C),
          surface: const Color(0xFFF2F3E9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F3E9),
      ),
      home: const GameHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  /// Flutter の初期カウンターデモ用画面を作成します（現在は未使用）。
  const MyHomePage({super.key, required this.title});

  // この画面は StatefulWidget で、下の State オブジェクトが表示状態を管理します。

  // このクラスは親ウィジェットから渡される値（ここではタイトル）を保持します。
  // ウィジェットは不変オブジェクトのため、フィールドには final を付けます。

  final String title;

  /// 初期カウンターデモの状態オブジェクトを作成します。
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// デモ画面のボタン操作に応じてカウンターを 1 増やします。
  void _incrementCounter() {
    setState(() {
      // setState を呼ぶと、状態が変わったことを Flutter に通知します。
      // 下の build メソッドが再実行され、新しい値が画面に反映されます。
      // setState を呼ばずに _counter だけを変更した場合、build は再実行されず、
      // 画面上では何も変化しません。
      _counter++;
    });
  }

  /// 初期カウンターデモの画面を組み立てます（現在は未使用）。
  @override
  Widget build(BuildContext context) {
    // このメソッドは、上の _incrementCounter などから setState が呼ばれるたびに
    // 再実行されます。
    //
    // Flutter は build メソッドを高速に再実行できるよう最適化されています。
    // そのため、個々のウィジェットを手作業で更新せず、必要な画面を再構築できます。
    return Scaffold(
      appBar: AppBar(
        // ここを Colors.amber などに変更してホットリロードすると、
        // 他の色はそのままで AppBar の色だけが変わります。
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // App.build が作成した MyHomePage のタイトルを AppBar に表示します。
        title: Text(widget.title),
      ),
      body: Center(
        // Center は子ウィジェットを親の中央に配置します。
        child: Column(
          // Column は子ウィジェットを縦方向に並べ、横幅は子に合わせます。
          // 通常は親の高さに合わせて配置されます。
          //
          // Column には、子の配置やサイズを調整するプロパティがあります。
          // mainAxisAlignment で主軸方向の配置を指定します。
          // Column の主軸は縦方向なので、ここでは子を縦方向の中央に配置します。
          // 交差軸は横方向です。
          //
          // IDE の「Toggle Debug Paint」を選ぶか、コンソールで `p` キーを押すと、
          // 各ウィジェットの枠線を表示できます。
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
