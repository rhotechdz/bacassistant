import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdMobService extends ChangeNotifier {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  RewardedInterstitialAd? rewardedInterstitialAd;

  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _hasBeenBackgrounded = false;
  bool _suppressNextForegroundAd = false;
  bool _isListeningToAppState = false;
  int _activeFullScreenContentCount = 0;

  final testBannerAdId = 'ca-app-pub-3940256099942544/9214589741';
  final testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  final testAppOpenAdId = 'ca-app-pub-3940256099942544/9257395921';
  final testRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  final testRewardedInterstitialAdId = 'ca-app-pub-3940256099942544/5354046379';

  final bannerAdId = 'ca-app-pub-8504521984385302/2217275358';
  final interstitialAdId = 'ca-app-pub-8504521984385302/1834131979';
  final appOpenAdId = 'ca-app-pub-8504521984385302/6371262145';
  final rewardedAdId = 'ca-app-pub-8504521984385302/4515509207';
  final rewardedInterstitialAdId = 'ca-app-pub-8504521984385302/4515509207';

  String get _bannerUnitId => kDebugMode ? testBannerAdId : bannerAdId;
  String get _interstitialUnitId =>
      kDebugMode ? testInterstitialAdId : interstitialAdId;
  String get _appOpenUnitId => kDebugMode ? testAppOpenAdId : appOpenAdId;
  String get _rewardedUnitId => kDebugMode ? testRewardedAdId : rewardedAdId;
  String get _rewardedInterstitialUnitId =>
      kDebugMode ? testRewardedInterstitialAdId : rewardedInterstitialAdId;

  void loadBannerAd(AdSize size) {
    bannerAd?.dispose();
    bannerAd = BannerAd(
      adUnitId: _bannerUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('BannerAd loaded.');
          notifyListeners();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          bannerAd = null;
          notifyListeners();
        },
        onAdOpened: (Ad ad) => debugPrint('BannerAd opened.'),
        onAdClosed: (Ad ad) => debugPrint('BannerAd closed.'),
        onAdImpression: (Ad ad) => debugPrint('BannerAd impression.'),
      ),
    )..load();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isShowingAd = false;
              _activeFullScreenContentCount--;
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isShowingAd = false;
              _activeFullScreenContentCount--;
              ad.dispose();
            },
          );
          _showFullScreenAd(() => interstitialAd!.show());
          interstitialAd = null;
        },
        onAdFailedToLoad: (LoadAdError error) => interstitialAd = null,
      ),
    );
  }

  void loadRewardedInterstitialAd() {
    if (rewardedInterstitialAd != null) {
      return;
    }

    RewardedInterstitialAd.load(
      adUnitId: _rewardedInterstitialUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          debugPrint('$ad loaded.');
          rewardedInterstitialAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          rewardedInterstitialAd = null;
          notifyListeners();
        },
      ),
    );
  }

  bool get isRewardedInterstitialAdAvailable => rewardedInterstitialAd != null;

  Future<bool> showRewardedInterstitialAd({
    VoidCallback? onDismissed,
    void Function(Ad, AdError)? onFailedToShow,
  }) async {
    final ad = rewardedInterstitialAd;
    if (ad == null || _isShowingAd || _activeFullScreenContentCount > 0) {
      return false;
    }

    rewardedInterstitialAd = null;
    final completer = Completer<bool>();
    _isShowingAd = true;
    _activeFullScreenContentCount++;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => debugPrint('$ad shown.'),
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
        onFailedToShow?.call(ad, error);
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
        onDismissed?.call();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );
    ad.show(onUserEarnedReward: (_, __) {});
    loadRewardedInterstitialAd();
    return completer.future;
  }

  Future<void> loadRewardedAd(Function? callback) async {
    await RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          rewardedAd = ad;
          showRewardedAd(callback);
        },
        onAdFailedToLoad: (LoadAdError error) => rewardedAd = null,
      ),
    );
  }

  void showRewardedAd(Function? callback) {
    final ad = rewardedAd;
    if (ad == null || _isShowingAd || _activeFullScreenContentCount > 0) {
      return;
    }
    _isShowingAd = true;
    _activeFullScreenContentCount++;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => debugPrint('$ad shown.'),
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) => callback?.call(ad, reward),
    );
    rewardedAd = null;
  }

  void loadAppOpenAd() {
    if (_appOpenAd != null) {
      return;
    }
    AppOpenAd.load(
      adUnitId: _appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  bool get isAdAvailable => _appOpenAd != null;

  void showAdIfAvailable() {
    if (!_hasBeenBackgrounded ||
        _isShowingAd ||
        _activeFullScreenContentCount > 0) {
      return;
    }
    if (!isAdAvailable) {
      debugPrint('Tried to show app-open ad before available.');
      loadAppOpenAd();
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      debugPrint('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }

    final ad = _appOpenAd!;
    _isShowingAd = true;
    _activeFullScreenContentCount++;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        _activeFullScreenContentCount--;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd = null;
    ad.show();
  }

  void listenToAppStateChanges() {
    if (_isListeningToAppState) {
      return;
    }
    _isListeningToAppState = true;
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.listen(_onAppStateChanged);
  }

  void _onAppStateChanged(AppState appState) {
    debugPrint('New AppState state: $appState');
    if (appState == AppState.foreground) {
      if (_suppressNextForegroundAd) {
        _suppressNextForegroundAd = false;
        loadAppOpenAd();
        return;
      }
      showAdIfAvailable();
    } else {
      _hasBeenBackgrounded = true;
    }
  }

  void suppressNextAppOpenAd() {
    _suppressNextForegroundAd = true;
  }

  Future<bool> shouldShowTriggerAd(
    SharedPreferences preferences,
    String key,
  ) async {
    final count = preferences.getInt(key) ?? 0;
    await preferences.setInt(key, count + 1);
    return count.isOdd;
  }

  void beginFullScreenContent() {
    _activeFullScreenContentCount++;
  }

  void endFullScreenContent() {
    if (_activeFullScreenContentCount > 0) {
      _activeFullScreenContentCount--;
    }
  }

  void _showFullScreenAd(VoidCallback show) {
    if (_isShowingAd || _activeFullScreenContentCount > 0) {
      return;
    }
    _isShowingAd = true;
    _activeFullScreenContentCount++;
    show();
  }
}
