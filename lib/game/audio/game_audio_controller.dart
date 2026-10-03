import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../engine/fruit_kind.dart';

abstract final class GameAudioConstants {
  static const String backgroundMusicAsset = 'background_music.mp3';
  static const String mergeSoundAsset = 'fruit_merge.mp3';
  static const double defaultBgmVolume = 0.35;
  static const double defaultSeVolume = 0.8;
  static const double minimumVolume = 0;
  static const double maximumVolume = 1;
  static const Duration bgmVolumeUpdateInterval = Duration(milliseconds: 60);
  static const int maximumConcurrentSePlayers = 4;
  static const bool audioInitiallyAvailable = true;
  static const bool bgmObserverInitiallyInitialized = false;
  static const int initialPlaybackGeneration = 0;

  // 種類別の効果音を追加したら、ここで果実ごとの音源へ差し替えます。
  static const Map<FruitKind, String> mergeSoundByFruit = {
    FruitKind.fruit01: mergeSoundAsset,
    FruitKind.fruit02: mergeSoundAsset,
    FruitKind.fruit03: mergeSoundAsset,
    FruitKind.fruit04: mergeSoundAsset,
    FruitKind.fruit05: mergeSoundAsset,
    FruitKind.fruit06: mergeSoundAsset,
    FruitKind.fruit07: mergeSoundAsset,
    FruitKind.fruit08: mergeSoundAsset,
    FruitKind.fruit09: mergeSoundAsset,
    FruitKind.fruit10: mergeSoundAsset,
    FruitKind.fruit11: mergeSoundAsset,
  };
}

abstract final class GameAudioLogMessages {
  static const String mergeSoundPoolInitializationFailed =
      'Merge sound pool initialization failed: ';
  static const String mergeSoundPoolCleanupFailed =
      'Merge sound pool cleanup failed: ';
  static const String audioAssetLoadingTimedOut =
      'Audio asset loading timed out: ';
  static const String audioUnavailable =
      'Audio playback is unavailable on this platform: ';
  static const String audioAssetLoadingFailed = 'Audio asset loading failed: ';
  static const String bgmPlayerPreparationTimedOut =
      'BGM player preparation timed out: ';
  static const String bgmUnavailable = 'BGM playback is unavailable: ';
  static const String bgmPlaybackFailed = 'BGM playback failed: ';
  static const String mergeSoundPoolPreparationTimedOut =
      'Merge sound pool preparation timed out: ';
  static const String soundEffectsUnavailable =
      'Sound effects are unavailable: ';
  static const String mergeSoundPoolPreparationFailed =
      'Merge sound pool preparation failed: ';
  static const String bgmStopUnavailable = 'BGM stop is unavailable: ';
  static const String bgmStopTimedOut = 'BGM stop timed out: ';
  static const String bgmStopFailed = 'BGM stop failed: ';
  static const String bgmVolumeControlUnavailable =
      'BGM volume control is unavailable: ';
  static const String bgmVolumeUpdateTimedOut = 'BGM volume update timed out: ';
  static const String bgmVolumeUpdateFailed = 'BGM volume update failed: ';
  static const String mergeSoundPlaybackTimedOut =
      'Merge sound playback timed out: ';
  static const String mergeSoundPlaybackFailed =
      'Merge sound playback failed: ';
}

class GameAudioController with WidgetsBindingObserver {
  /// コントローラーをアプリ内で一つだけ使うための非公開コンストラクターです。
  GameAudioController._() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// アプリ全体で共有する音量状態と音声プレイヤー管理を返します。
  static final GameAudioController instance = GameAudioController._();

  final ValueNotifier<double> bgmVolume = ValueNotifier<double>(
    GameAudioConstants.defaultBgmVolume,
  );
  final ValueNotifier<double> seVolume = ValueNotifier<double>(
    GameAudioConstants.defaultSeVolume,
  );

  Future<void>? _assetLoading;
  final Map<String, AudioPool> _mergeSoundPools = {};
  Future<void>? _soundPoolLoading;
  bool _bgmAvailable = GameAudioConstants.audioInitiallyAvailable;
  bool _seAvailable = GameAudioConstants.audioInitiallyAvailable;
  bool _bgmObserverInitialized =
      GameAudioConstants.bgmObserverInitiallyInitialized;
  bool _shouldPlayAudio = false;
  bool _isForeground = true;
  int _playbackGeneration = GameAudioConstants.initialPlaybackGeneration;
  final Stopwatch _bgmVolumeClock = Stopwatch()..start();
  Duration _lastBgmVolumeUpdate = Duration.zero;
  Timer? _bgmVolumeUpdateTimer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_restoreAudioAfterResume());
      return;
    }

    _isForeground = false;
    _playbackGeneration++;
    FlameAudio.bgm.isPlaying = false;
    _bgmVolumeUpdateTimer?.cancel();
    _bgmVolumeUpdateTimer = null;
    unawaited(_clearMergeSoundPools());
  }

  Future<void> _restoreAudioAfterResume() async {
    await _clearMergeSoundPools();
    _isForeground = true;
    if (!_shouldPlayAudio) return;

    _bgmAvailable = GameAudioConstants.audioInitiallyAvailable;
    _seAvailable = GameAudioConstants.audioInitiallyAvailable;
    await start();
  }

  Future<void> _clearMergeSoundPools() async {
    final loading = _soundPoolLoading;
    if (loading != null) {
      try {
        await loading;
      } on Object catch (error) {
        debugPrint(
          '${GameAudioLogMessages.mergeSoundPoolInitializationFailed}$error',
        );
      }
    }

    final pools = _mergeSoundPools.values.toSet().toList();
    _mergeSoundPools.clear();
    _soundPoolLoading = null;
    try {
      await Future.wait(pools.map((pool) => pool.dispose()));
    } on Object catch (error) {
      debugPrint('${GameAudioLogMessages.mergeSoundPoolCleanupFailed}$error');
    }
  }

  /// 音源を先読みし、ゲーム用 BGM をループ再生します。
  Future<void> start() async {
    _shouldPlayAudio = true;
    final generation = ++_playbackGeneration;
    try {
      await (_assetLoading ??= FlameAudio.audioCache.load(
        GameAudioConstants.backgroundMusicAsset,
      ));
    } on TimeoutException catch (error) {
      _bgmAvailable = false;
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.audioAssetLoadingTimedOut}$error');
      return;
    } on MissingPluginException catch (error) {
      _bgmAvailable = false;
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.audioUnavailable}$error');
      return;
    } on PlatformException catch (error) {
      _bgmAvailable = false;
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.audioAssetLoadingFailed}$error');
      return;
    }

    if (generation != _playbackGeneration) return;
    await _startBgm(generation);
    if (generation == _playbackGeneration) {
      await _prepareMergeSounds();
    }
  }

  /// BGM プレイヤーを初期化して再生し、準備タイムアウトを音声機能内で処理します。
  Future<void> _startBgm(int generation) async {
    if (!_bgmAvailable) return;

    try {
      if (!_bgmObserverInitialized) {
        await FlameAudio.bgm.initialize();
        _bgmObserverInitialized = true;
      }
      if (generation != _playbackGeneration || FlameAudio.bgm.isPlaying) return;

      await FlameAudio.bgm.play(
        GameAudioConstants.backgroundMusicAsset,
        volume: bgmVolume.value,
      );
      if (generation != _playbackGeneration) {
        await FlameAudio.bgm.stop();
      }
    } on TimeoutException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmPlayerPreparationTimedOut}$error');
    } on MissingPluginException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmUnavailable}$error');
    } on PlatformException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmPlaybackFailed}$error');
    }
  }

  /// 果実種類別の SE を、再利用可能なプレイヤープールへ事前登録します。
  Future<void> _prepareMergeSounds() async {
    if (!_seAvailable || _mergeSoundPools.isNotEmpty) return;

    try {
      await (_soundPoolLoading ??= _createMergeSoundPools());
    } on TimeoutException catch (error) {
      _seAvailable = false;
      debugPrint(
        '${GameAudioLogMessages.mergeSoundPoolPreparationTimedOut}$error',
      );
    } on MissingPluginException catch (error) {
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.soundEffectsUnavailable}$error');
    } on PlatformException catch (error) {
      _seAvailable = false;
      debugPrint(
        '${GameAudioLogMessages.mergeSoundPoolPreparationFailed}$error',
      );
    }
  }

  /// 各 SE ファイルにつき一つのプレイヤープールを生成します。
  Future<void> _createMergeSoundPools() async {
    final soundAssets = GameAudioConstants.mergeSoundByFruit.values.toSet();
    for (final asset in soundAssets) {
      _mergeSoundPools[asset] = await FlameAudio.createPool(
        asset,
        minPlayers: 1,
        maxPlayers: GameAudioConstants.maximumConcurrentSePlayers,
      );
    }
  }

  /// ゲーム画面を離れるときに BGM を停止します。
  Future<void> stop() async {
    _shouldPlayAudio = false;
    _playbackGeneration++;
    if (!_bgmAvailable || !FlameAudio.bgm.isPlaying) return;

    try {
      await FlameAudio.bgm.stop();
    } on MissingPluginException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmStopUnavailable}$error');
    } on TimeoutException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmStopTimedOut}$error');
    } on PlatformException catch (error) {
      debugPrint('${GameAudioLogMessages.bgmStopFailed}$error');
    }
  }

  /// BGM 音量を即時表示し、再生中のプレイヤーへ間引いて反映します。
  void setBgmVolume(double volume) {
    final normalizedVolume = _normalizeVolume(volume);
    bgmVolume.value = normalizedVolume;
    if (!_bgmAvailable || !FlameAudio.bgm.isPlaying) return;

    _bgmVolumeUpdateTimer?.cancel();
    final elapsed = _bgmVolumeClock.elapsed - _lastBgmVolumeUpdate;
    final remaining = GameAudioConstants.bgmVolumeUpdateInterval - elapsed;
    if (remaining <= Duration.zero) {
      _lastBgmVolumeUpdate = _bgmVolumeClock.elapsed;
      unawaited(_applyBgmVolume());
      return;
    }

    _bgmVolumeUpdateTimer = Timer(remaining, () {
      _bgmVolumeUpdateTimer = null;
      _lastBgmVolumeUpdate = _bgmVolumeClock.elapsed;
      unawaited(_applyBgmVolume());
    });
  }

  /// スライダー操作終了時に保留中の最新 BGM 音量を適用します。
  void flushBgmVolume() {
    _bgmVolumeUpdateTimer?.cancel();
    _bgmVolumeUpdateTimer = null;
    if (!_bgmAvailable || !FlameAudio.bgm.isPlaying) return;

    _lastBgmVolumeUpdate = _bgmVolumeClock.elapsed;
    unawaited(_applyBgmVolume());
  }

  /// 現在の音量値をネイティブの BGM プレイヤーへ送ります。
  Future<void> _applyBgmVolume() async {
    if (!_bgmAvailable || !FlameAudio.bgm.isPlaying) return;

    try {
      await FlameAudio.bgm.audioPlayer.setVolume(bgmVolume.value);
    } on MissingPluginException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmVolumeControlUnavailable}$error');
    } on TimeoutException catch (error) {
      _bgmAvailable = false;
      debugPrint('${GameAudioLogMessages.bgmVolumeUpdateTimedOut}$error');
    } on PlatformException catch (error) {
      debugPrint('${GameAudioLogMessages.bgmVolumeUpdateFailed}$error');
    }
  }

  /// SE 音量を 0.0〜1.0 に収め、次回以降の効果音に適用します。
  void setSeVolume(double volume) {
    seVolume.value = _normalizeVolume(volume);
  }

  /// 合体した果実の種類に対応する効果音を現在の SE 音量で再生します。
  Future<void> playMergeSound(FruitKind kind) async {
    if (!_isForeground ||
        !_seAvailable ||
        seVolume.value <= GameAudioConstants.minimumVolume) {
      return;
    }

    await _prepareMergeSounds();
    if (!_seAvailable) return;

    final soundAsset =
        GameAudioConstants.mergeSoundByFruit[kind] ??
        GameAudioConstants.mergeSoundAsset;
    try {
      await _mergeSoundPools[soundAsset]?.start(volume: seVolume.value);
    } on MissingPluginException catch (error) {
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.soundEffectsUnavailable}$error');
    } on TimeoutException catch (error) {
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.mergeSoundPlaybackTimedOut}$error');
    } on PlatformException catch (error) {
      _seAvailable = false;
      debugPrint('${GameAudioLogMessages.mergeSoundPlaybackFailed}$error');
    }
  }

  /// 投下した果実の種類に対応する既存の効果音を再生します。
  Future<void> playDropSound(FruitKind kind) => playMergeSound(kind);

  /// BGM 音量を 0.0〜1.0 の範囲へ制限します。
  double _normalizeVolume(double volume) => volume.clamp(
    GameAudioConstants.minimumVolume,
    GameAudioConstants.maximumVolume,
  );
}
