# ころころ果樹園

Flutter・Flame・Forge2D で作った、フルーツ落下ゲームの試作プロジェクトです。画面をタップするとフルーツが落ち、同じ種類同士が触れると合体します。図形や背景をオリジナルの素材に差し替える前提で、ゲーム進行と見た目の設定を分けています。

## 起動

```powershell
flutter pub get
flutter run -d windows
```

Chrome で試す場合は `flutter run -d chrome` を使います。Android 実機・エミュレーターでは `flutter run -d android` で起動できます。

## カスタマイズ箇所

- `lib/game/engine/fruit_kind.dart`: フルーツの種類、色、当たり判定の半径
- `lib/game/engine/fruit_component.dart`: フルーツの物理ボディと現在の図形描画
- `lib/game/engine/arena_component.dart`: 箱の壁・床と背景の見た目
- `lib/game/engine/sumika_game.dart`: 重力、投下、合体、スコア
- `lib/game/audio/game_audio_controller.dart`: BGM/SE 再生、音量、果実種類別SE設定
- `lib/game/presentation/game_home_page.dart`: Flame ゲームの所有と画面ライフサイクル
- `lib/game/presentation/game_home_page_layout.dart`: ゲーム画面のレイアウト
- `lib/game/presentation/game_home_page_constants.dart`: 画面内で共有する表示定数
- `lib/game/presentation/widgets/`: ヘッダー、スコア、盤面、操作 UI、音量設定
- `lib/app/app_theme.dart`: アプリ全体のテーマと色
- `lib/app/sumika_app.dart`: MaterialApp の設定
- `assets/audio/`: 再生する BGM と効果音
- `assets/images/fruits/`: 差し替え用フルーツ画像
- `assets/images/backgrounds/`: 差し替え用背景画像

画像を追加したら `pubspec.yaml` の `flutter.assets` に登録します。画像の見た目と Forge2D の当たり判定は別々なので、画像を変更しても物理形状は `lib/game/engine/fruit_kind.dart` で調整できます。

ゲーム中は指定 BGM をループ再生し、果実が合体した時に効果音を再生します。画面下部の音量設定ボタンから BGM と効果音の音量を別々に調節できます。種類別の効果音は `GameAudioConstants.mergeSoundByFruit` で割り当てます。

## チェック

```powershell
flutter analyze
flutter test
```

ファンメイド作品として公開する場合は、既存作品の名称・ロゴ・画像・音源などの利用条件を確認し、独自または利用許諾済みの素材を使ってください。
