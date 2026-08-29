import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  RewardedInterstitialAd? rewardedInterstitialAd;

  final Duration maxCacheDuration = const Duration(hours: 4);
  DateTime? _appOpenLoadTime;
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  final testBannerAdId = 'ca-app-pub-3940256099942544/9214589741';
  final testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  final testAppOpenAdId = 'ca-app-pub-3940256099942544/9257395921';
  final testRewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  final testRewardedInterstitialAdId = 'ca-app-pub-3940256099942544/5354046379';

  final bannerAdId = 'ca-app-pub-8504521984385302/2217275358';
  final interstitialAdId = 'ca-app-pub-8504521984385302/1834131979';
  final appOpenAdId = 'ca-app-pub-8504521984385302/6371262145';
  final rewardedAdId = 'ca-app-pub-3940256099942544/5224354917';
  final rewardedInterstitialAdId = 'ca-app-pub-8504521984385302/4515509207';

  void loadBannerAd(size) async {
    bannerAd = BannerAd(
      adUnitId: testBannerAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => debugPrint('bannedAd loaded.'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
        onAdOpened: (Ad ad) => debugPrint('bannedAd opened.'),
        onAdClosed: (Ad ad) => debugPrint('bannedAd closed.'),
        onAdImpression: (Ad ad) => debugPrint('bannedAd impression.'),
      )
    )
    ..load();
  }

  void loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: testInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          interstitialAd = ad;
          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          interstitialAd!.show();
          interstitialAd = null;
        },
        onAdFailedToLoad: (LoadAdError error) => interstitialAd = null,
      ));
  }

  void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: testRewardedInterstitialAdId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
              onAdShowedFullScreenContent: (ad) {
                debugPrint('$ad onAdShowedFullScreenContent');
              },
              // Called when an impression occurs on the ad.
              onAdImpression: (ad) {
                debugPrint('$ad onAdImpression');
              },
              // Called when the ad failed to show full screen content.
              onAdFailedToShowFullScreenContent: (ad, err) {
                debugPrint('$ad onAdFailedToShowFullScreenContent: $err');
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when the ad dismissed full screen content.
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('$ad onAdDismissedFullScreenContent');
                // Dispose the ad here to free resources.
                ad.dispose();
              },
              // Called when a click is recorded for an ad.
              onAdClicked: (ad) {
                debugPrint('$ad onAdClicked');
              });

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedInterstitialAd = ad;
            rewardedInterstitialAd!.show(
              onUserEarnedReward: (ad, reward) {
                debugPrint('User earned reward: $reward');
              });
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedInterstitialAd failed to load: $error');
          },
        ));
  }

  Future<void> loadRewardedAd(Function? callback) async {
    RewardedAd.load(
      adUnitId: testRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          rewardedAd = ad;
          showRewardedAd(callback);
        },
        onAdFailedToLoad: (LoadAdError error) => rewardedAd = null,
      )
    );
  }

  void showRewardedAd(Function? callback) {
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose());
    rewardedAd!
      .show(onUserEarnedReward: (ad, reward) => callback!(ad, reward));
    rewardedAd = null;
  }

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: testAppOpenAdId,
      //orientation: AppOpenAd.orientationPortrait,
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

  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAppOpenAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      debugPrint('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
      .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    debugPrint('New AppState state: $appState');
    if (appState == AppState.foreground) {
      showAdIfAvailable();
    }
  }
}
