abstract final class GameContextConstants {
  static const String assetPathSeparator = '/';
  static const String imageAssetRoot = 'assets/images';
  static const String brandingAssetDirectory = 'branding';
  static const String titleLogoFileName = 'title_logo.png';
  static const String fruitAssetDirectory = 'fruits';
  static const String fruitImageFilePrefix = 'fruit';
  static const String imageFileExtension = '.png';
  static const String imageNumberPaddingCharacter = '0';
  static const String closedEyeDirectoryName = 'close';
  static const int firstFruitImageNumber = 1;
  static const int fruitImageNumberWidth = 2;
  static const String closedEyeAssetDirectory =
      '$fruitAssetDirectory$assetPathSeparator$closedEyeDirectoryName';
  static const double fruitOutlineWidthRatio = 0.04;
  static const double dropPreviewBlinkIntervalSeconds = 3.5;
  static const double dropPreviewBlinkDurationSeconds = 0.14;
  static const double mergedFruitClosedDurationSeconds = 2;
  static const bool mergedFruitStartsEyesClosed = true;
  static const bool closePreviewFruitsOnGameOver = true;
  static const double gameOverScoreFontSize = 28;
  static const double gameOverActionButtonHeight = 48;
  static const double gameOverActionButtonWidth = 136;
  static const double gameOverActionButtonSpacing = 8;
  static const double gameOverActionButtonFontSize = 12;
  static const int gameOverCloseButtonBackgroundColor = 0xFF757575;
  static const int gameOverCloseButtonForegroundColor = 0xFFFFFFFF;
  static const double gameFieldAspectRatio = 2 / 3;
}
