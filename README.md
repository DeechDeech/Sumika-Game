# ころころ果樹園

Flutter・Flame・Forge2D で作った、フルーツ落下ゲームの試作プロジェクトです。画面をタップするとフルーツが落ち、同じ種類同士が触れると合体します。図形や背景をオリジナルの素材に差し替える前提で、ゲーム進行と見た目の設定を分けています。

## 起動

```powershell
flutter pub get
flutter run -d windows
```

Chrome で試す場合は `flutter run -d chrome` を使います。Android 実機・エミュレーターでは `flutter run -d android` で起動できます。

## カスタマイズ箇所

- `lib/game/fruit_kind.dart`: フルーツの種類、色、当たり判定の半径
- `lib/game/fruit_component.dart`: フルーツの物理ボディと現在の図形描画
- `lib/game/arena_component.dart`: 箱の壁・床と背景の見た目
- `lib/game/sumika_game.dart`: 重力、投下、合体、スコア
- `assets/images/fruits/`: 差し替え用フルーツ画像
- `assets/images/backgrounds/`: 差し替え用背景画像

画像を追加したら `pubspec.yaml` の `flutter.assets` に登録します。画像の見た目と Forge2D の当たり判定は別々なので、画像を変更しても物理形状は `fruit_kind.dart` で調整できます。

## チェック

```powershell
flutter analyze
flutter test
```

ファンメイド作品として公開する場合は、既存作品の名称・ロゴ・画像・音源などの利用条件を確認し、独自または利用許諾済みの素材を使ってください。
