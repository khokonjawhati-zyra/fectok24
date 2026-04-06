import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

/// A_111: SOVEREIGN AI 6-NETWORK HYPER-LOGIC [V15]
/// This module orchestrates real ad delivery across 6 top-tier networks:
/// AdMob, Unity, AppLovin, IronSource, Meta, Minintegral
class SovereignAdEngine {
  final List<String> adSequence = ['ADM', 'UNT', 'APL', 'IRS', 'META', 'VGL'];
  int _currentIndex = 0;
  
  // Operational Logic [V15 Master Standards]
  int adsPerMinute = 4;
  int rotationInterval = 15;
  bool isRealMode = false;
  bool isRandomMode = false;
  bool isMasterEnabled = false; // V15: Hard-Control Logic [A_111]
  
  // Master Google AdMob Omni-Mediation Config
  // AppLovin MAX dependencies removed for V15 Google compliance.
  // V15 Master Ad Vault: Simulation Fallback [A_111]
  final Map<String, String> simulationVods = {
    'ADM': 'grok_video_2026-02-07-20-12-25_1771315851.mp4',
    'UNT': 'grok_video_2026-02-07-20-13-49_1771315530.mp4',
    'APL': 'grok_video_2026-02-07-20-12-25_1771315851.mp4',
    'IRS': 'grok_video_2026-02-07-20-13-49_1771315530.mp4',
    'META': 'grok_video_2026-02-07-20-12-25_1771315851.mp4',
    'VGL': 'grok_video_2026-02-07-20-13-49_1771315530.mp4', 
  };

  // Real Production Slots (Synced from Admin)
  final Map<String, String> networkApiKeys = {
    'ADM': '', // AdMob Native Unit ID — synced from Admin Panel
    'UNT': '', // Unity via AppLovin MAX Ad Unit ID
    'APL': '', // AppLovin Network via MAX Ad Unit ID
    'IRS': '', // IronSource via AppLovin MAX Ad Unit ID
    'META': '', // Meta Placement via AppLovin MAX Ad Unit ID
    'VGL': '', // Vungle via AppLovin MAX Ad Unit ID
  };

  static final SovereignAdEngine _instance = SovereignAdEngine._internal();
  factory SovereignAdEngine() => _instance;
  SovereignAdEngine._internal() {
    _startRotationPulse();
  }

  StreamController<String> adStream = StreamController<String>.broadcast();
  String currentNetwork = 'ADM';
  Timer? _rotationTimer;
  
  // ✅ Callback to notify parent widget when Native Ad loads
  VoidCallback? onAdLoaded;

  // Real SDK Controllers [A_111: The Master Mediation Logic]
  gma.NativeAd? googleNativeAd;
  gma.NativeAd? nextGoogleNativeAd; // Zero-Latency Buffer [Double-Buffering]
  bool isGoogleAdLoaded = false;
  bool isNextAdLoading = false;

  void _startRotationPulse() {
    _rotationTimer?.cancel();
    if (!isMasterEnabled) {
      debugPrint("[A_111] Rotation Pulse: HALTED [Master Switch OFF]");
      return;
    }
    _rotationTimer = Timer.periodic(Duration(seconds: rotationInterval), (timer) {
      rotateAdsSequential();
    });

    // Zero-Latency Pre-loader: Trigger 5 seconds BEFORE rotation switch
    Timer.periodic(const Duration(seconds: 1), (timer) {
       if (!isMasterEnabled) {
         timer.cancel(); // Strong Kill-Switch Protection
         return;
       }
       if (_rotationTimer != null && _rotationTimer!.tick > 0) {
          int currentTickInCycle = _rotationTimer!.tick % (rotationInterval == 0 ? 1 : rotationInterval);
          if (currentTickInCycle == (rotationInterval > 5 ? rotationInterval - 5 : 1)) {
             _preLoadNextNetworkSlot();
          }
       }
    });
  }

  /// Update rotation interval dynamically from Admin Slice Bar
  set updateInterval(int seconds) {
    rotationInterval = seconds;
    _startRotationPulse();
    debugPrint("[A_111] Rotation Interval set to ${rotationInterval}s");
  }

  /// V15 Ignition: Initialize Real SDKs with Strict Policy Guard
  Future<void> ignite() async {
    debugPrint("[A_111] Initializing Sovereign Ad-Revenue Bridge...");
    await gma.MobileAds.instance.initialize();
    debugPrint("[A_111] Google AdMob SDK (Omni-Mediation): INITIALIZED");
    _refreshRealMode();
    if (!kIsWeb) {
      String id = networkApiKeys[currentNetwork] ?? "";
      if (_isValidRealId(id)) {
        loadGoogleNativeAd(id);
      }
    }
  }

  void _refreshRealMode() {
    bool hasRealId = networkApiKeys.entries.any((e) => _isValidRealId(e.value));
    isRealMode = hasRealId;
    debugPrint("[A_111] Real Mode Check: $isRealMode");
  }

  bool _isValidRealId(String id) {
    if (id.isEmpty) return false;
    if (id.contains('LIVE_X') || id.contains('YOUR_') || id.contains('DEFAULT-')) return false;
    if (id.contains('(') || id.contains(')') || id.contains(' / ')) return false;
    return true;
  }

  void loadGoogleNativeAd(String adUnitId) {
    if (kIsWeb) return; 
    debugPrint("[A_111] Google AdMob: Requesting Native Ad [$currentNetwork -> $adUnitId]");
    isGoogleAdLoaded = false;
    googleNativeAd?.dispose();
    googleNativeAd = gma.NativeAd(
      adUnitId: adUnitId,
      factoryId: 'adFactoryExample',
      request: const gma.AdRequest(),
      listener: gma.NativeAdListener(
        onAdLoaded: (ad) {
          isGoogleAdLoaded = true;
          adStream.add(currentNetwork);
          onAdLoaded?.call();
          debugPrint("[A_111] Native Ad LOADED [SUCCESS]");
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("[A_111] Native Ad FAILED [ERROR: $error]");
          ad.dispose();
          isGoogleAdLoaded = false;
        },
      ),
    );
    googleNativeAd!.load();
  }

  void syncAdminSlots(Map<String, dynamic> slots) {
    slots.forEach((key, value) {
      if (networkApiKeys.containsKey(key)) {
        networkApiKeys[key] = value.toString();
      }
    });
    _refreshRealMode();
    if (!kIsWeb) {
      String currentId = networkApiKeys[currentNetwork] ?? "";
      if (_isValidRealId(currentId)) {
        loadGoogleNativeAd(currentId);
      }
    }
    debugPrint("[A_111] Admin Slots Synced. Real Mode: $isRealMode");
  }

  String? getAdSource(String network) {
    String id = networkApiKeys[network] ?? "";
    if (_isValidRealId(id)) return id;
    String vod = simulationVods[network] ?? "grok_video_default.mp4";
    return '/video_stream/stream/$vod';
  }

  void _preLoadNextNetworkSlot() {
    if (kIsWeb || isNextAdLoading) return;
    
    int nextSlotIndex = (isRandomMode) 
        ? Random().nextInt(adSequence.length) 
        : (_currentIndex + 1) % adSequence.length;
    
    String nextNetwork = adSequence[nextSlotIndex];
    String nextId = networkApiKeys[nextNetwork] ?? "";

    if (_isValidRealId(nextId)) {
      debugPrint("[A_111: Matubbori] Pre-loading Next Slot: $nextNetwork [Zero-Latency Handshake]");
      isNextAdLoading = true;
      nextGoogleNativeAd?.dispose();
      
      nextGoogleNativeAd = gma.NativeAd(
        adUnitId: nextId,
        factoryId: 'adFactoryExample',
        request: const gma.AdRequest(),
        listener: gma.NativeAdListener(
          onAdLoaded: (ad) {
            isNextAdLoading = false;
            debugPrint("[A_111: Matubbori] Pre-load READY for $nextNetwork");
          },
          onAdFailedToLoad: (ad, error) {
            isNextAdLoading = false;
            ad.dispose();
            nextGoogleNativeAd = null;
            debugPrint("[A_111: Matubbori] Pre-load FAILED for $nextNetwork: $error");
          },
        ),
      );
      nextGoogleNativeAd!.load();
    }
  }

  void rotateAdsSequential() {
    if (!isMasterEnabled) return;
    // V15 Gap Fix: Clean up old ad state
    isGoogleAdLoaded = false;
    
    if (isRandomMode) {
      _currentIndex = Random().nextInt(adSequence.length);
    } else {
      _currentIndex = (_currentIndex + 1) % adSequence.length;
    }
    currentNetwork = adSequence[_currentIndex];
    
    debugPrint("AD_ROTATOR: Switching to $currentNetwork [Mode: ${isRandomMode ? 'RANDOM' : 'SEQUENTIAL'}]");

    // A_111: The Matubbori Swap (Zero-Latency)
    if (!kIsWeb) {
      // Check if we have a pre-loaded ad ready to go
      if (nextGoogleNativeAd != null) {
        googleNativeAd?.dispose();
        googleNativeAd = nextGoogleNativeAd;
        nextGoogleNativeAd = null;
        isGoogleAdLoaded = true;
        onAdLoaded?.call(); // Instant UI update
        debugPrint("[A_111: Matubbori] Zero-Latency Swap: $currentNetwork is LIVE!");
      } else {
        // Fallback: Real-time load if pre-loader failed or missed
        String id = networkApiKeys[currentNetwork] ?? "";
        if (_isValidRealId(id)) {
          loadGoogleNativeAd(id);
        } else {
          googleNativeAd?.dispose();
          googleNativeAd = null;
          debugPrint("[A_111] $currentNetwork has no real ID. Simulation Mode Active.");
        }
      }
    }
    
    adStream.add(currentNetwork);
  }

  /// V15 Gap Fix: Sync rotation interval from Admin Panel
  void syncRotationInterval(int seconds) {
    if (seconds > 0 && seconds != rotationInterval) {
      rotationInterval = seconds;
      _startRotationPulse();
      debugPrint("[A_111] Rotation Interval Synced: ${rotationInterval}s");
    }
  }

  /// V15: High-Precision Master Control [Joralo Logic]
  void syncMasterControl(bool enabled) {
    if (isMasterEnabled != enabled) {
      isMasterEnabled = enabled;
      debugPrint("[A_111] Master Control: ${enabled ? 'ACTIVE' : 'OFF'} [Hard-Gate Enforced]");
      if (!enabled) {
        // Kill everything immediately
        _rotationTimer?.cancel();
        googleNativeAd?.dispose();
        googleNativeAd = null;
        isGoogleAdLoaded = false;
        isNextAdLoading = false;
        nextGoogleNativeAd?.dispose();
        nextGoogleNativeAd = null;
        adStream.add(currentNetwork); // Pulse UI update
      } else {
        _startRotationPulse();
      }
    }
  }

  void dispose() {
    _rotationTimer?.cancel();
    googleNativeAd?.dispose();
    adStream.close();
  }

  String get networkDisplayName {
    switch (currentNetwork) {
      case 'ADM': return 'AdMob';
      case 'UNT': return 'Unity';
      case 'APL': return 'AppLovin';
      case 'IRS': return 'IronSource';
      case 'META': return 'Meta';
      case 'VGL': return 'Vungle';
      default: return 'Sovereign';
    }
  }
}
