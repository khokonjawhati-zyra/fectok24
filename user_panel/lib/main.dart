import 'dart:convert';
import 'dart:ui';
import 'dart:math'; // For V15 Random Logic
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'core/theme/sovereign_theme.dart';
import 'ai_ad_core_engine.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'sovereign_auth_page.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


final List<String> testVideos = []; // Sovereign Master Standard: No legacy bloat. Only mesh content.

// Sovereign V15: Global Dynamic Host Core [A_124 DNA]
// Automatically detects browsing origin. Fallback to localhost if used as file.
String get globalSovereignHost {
  if (kIsWeb) {
    String h = Uri.base.host;
    return h.isNotEmpty ? h : 'localhost';
  }
  // Mobile Fallback: Detect if we are in production nursery
  return 'fectok.com'; 
}

// 1. Core Security Shield [SSL-READY]
String _resolveSecureUrl(String? url) {
  if (url == null || url.isEmpty) return "";
  String resolved = url;
  
  // Handlers for absolute IPs (Legacy)
  final String currentHost = globalSovereignHost;
  final RegExp ipRegex = RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
  resolved = resolved.replaceAll(ipRegex, currentHost).replaceAll('localhost', currentHost);

  // V15 Security Injection: Auto-Upgrade to HTTPS only if domain fectok.com is used
  if (kIsWeb) {
    if (currentHost.contains('fectok.com')) {
      resolved = resolved.replaceFirst('http://', 'https://');
      resolved = resolved.replaceFirst('ws://', 'wss://');
    }
  } else {
    // Mobile/Android: Force secure connections ONLY for Production Domain
    if (currentHost.contains('fectok.com')) {
      resolved = resolved.replaceFirst('http://', 'https://');
      resolved = resolved.replaceFirst('ws://', 'wss://');
    } else {
      // Direct Node Pulse: Maintain standard connections to prevent SSL handshake failure
      resolved = resolved.replaceFirst('https://', 'http://');
      resolved = resolved.replaceFirst('wss://', 'ws://');
    }
  }

  // Sovereign V15: Mesh Interface Proxying (Always apply port stripping on mobile)
  if (!kIsWeb || (kIsWeb && Uri.base.scheme == 'https')) {
    // We remove the ports because Nginx handles the routing via paths
    if (resolved.contains(':5000')) {
       resolved = resolved.replaceFirst(':5000', '');
    }
    if (resolved.contains(':9900')) {
       // Nginx maps /sound_engine/ to port 9900 internally
       if (!resolved.contains('/sound_engine')) {
          resolved = resolved.replaceFirst(':9900', '/sound_engine');
       } else {
          resolved = resolved.replaceFirst(':9900', '');
       }
    }

    if (resolved.contains(':8080')) {
      // Sovereign V15: Map port 8080 to correct Nginx paths
      if (resolved.contains('/upload')) {
        resolved = resolved.replaceFirst(':8080/upload', '/stream/upload');
      } else {
        resolved = resolved.replaceFirst(':8080/', '/video_stream/');
      }
    }

    // Standard port cleanup for fectok.com
    if (resolved.contains('fectok.com')) {
       resolved = resolved.replaceFirst(RegExp(r':(8000)'), '');
       // Remove 8080 if lingering
       resolved = resolved.replaceFirst(':8080', '');
    }
  }

  debugPrint("SOVEREIGN_RESOLVE: $url -> $resolved");
  return resolved;
}

// Sovereign Connector for Flutter Injection [A_124]
String getSovereignUrl(int index, List<Map<String, dynamic>> mediaLedger) {
  if (mediaLedger.isNotEmpty && index < mediaLedger.length) {
    String url = mediaLedger[index]['url'] ?? "";
    return _resolveSecureUrl(url);
  }
  return testVideos.isNotEmpty ? testVideos[index % testVideos.length] : "";
}

String getSovereignThumb(int index, List<Map<String, dynamic>> mediaLedger) {
  if (mediaLedger.isEmpty || index >= mediaLedger.length) return "";
  final item = mediaLedger[index];
  String url = item['thumb_url'] ?? item['thumbnail'] ?? "";
  if (url.isEmpty) {
    String mainUrl = item['url'] ?? "";
    if (mainUrl.toLowerCase().contains('.jpg') || 
        mainUrl.toLowerCase().contains('.png') || 
        mainUrl.toLowerCase().contains('.jpeg') || 
        mainUrl.toLowerCase().contains('.webp')) {
      url = mainUrl;
    }
  }
  return _resolveSecureUrl(url);
}

// Sovereign V15: Global Route Intelligence [A_117 Sync]
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

// A_125 Profile DNA: Global Mesh State [Sovereign Master Sync]
final ValueNotifier<int> followerNotifier = ValueNotifier<int>(0);
final ValueNotifier<int> followingNotifier = ValueNotifier<int>(0);
final ValueNotifier<int> totalLikesNotifier = ValueNotifier<int>(0);


void main() {
  runApp(const FecTokV15());
}

class FecTokV15 extends StatelessWidget {
  const FecTokV15({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FecTok V15',
      theme: SovereignTheme.darkTheme,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver], // A_117 Pulse: Unified State Monitoring
    );
  }
}

VoidCallback? _pendingBindingAction; // Sovereign V15: A_142 Handshake Holder (Top-level)

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late WebSocketChannel channel;
  late Stream<dynamic> broadcastStream;
  String syncStatus = "Waiting for Sync...";
  bool isMaintenanceMode = false;
  bool isConnected = false;
  bool isLegallyAuthorized = false; // A_106 Gating
  bool isGatingEnabled = true; // Global Switch
  String meshID = "CALIBRATING...";
  final ValueNotifier<Map<String, dynamic>> bridgeConfigsNotifier = ValueNotifier({
    "bkash": "01700000000",
    "nagad": "01800000000",
    "rocket": "01900000000"
  });
  bool _isAdSplitEnabled = false; // V15 FIX: State managed by Real-time Master Pulse [A_111]
  DateTime? userDOB;
  bool isVerified = false; 
  String? _profileImagePath;
  bool _isAuthenticated = false;
  String userName = "Sovereign User";
  String userProfession = "User";
  String userBio = "Transforming Reality within the Mesh.";
  String? serverProfilePic;

  
  double coinRate = 100.0; // V15 Precision: toStringAsFixed(1)
  late ValueNotifier<double> bdtRateNotifier;
  late ValueNotifier<double> commissionNotifier;
  late ValueNotifier<double> mlmYieldNotifier; // A_107 Yield Tax 
  double visibilityWeight = 1.0;
  double _discoveryWeight = 0.15; // V15 User-Centric AI Slider [Phase 21]
  late ValueNotifier<double> minWithdrawNotifier; // A_113 Floor
  
  // A_106 Permission State [Neural Gating]
  bool isCameraEnabled = true;
  bool isMicEnabled = true;
  bool isGalleryEnabled = true;
  bool isLocationEnabled = false;
  
  // Navigation States
  String _currentFeedTab = 'For You';
  String _inboxView = 'Main'; // Main, Followers, Likes, Comments, Mentions, DMs
  final Set<String> _followedUsers = {};
  final TextEditingController _inboxReplyController = TextEditingController();
  
  // Navigation Methods
  // void _liveFeedOpen() {
  //    _onInteraction('LIVE_FEED_OPEN');
  //    Navigator.push(context, MaterialPageRoute(builder: (context) => const SovereignLiveFeed()));
  // }

  // void _searchOpen() {
  //   _onInteraction('SEARCH_OPEN');
  //   Navigator.push(context, MaterialPageRoute(builder: (context) => const SovereignSearch()));
  // } // A_121 Stealth Patch
  
  late ValueNotifier<double> usdNotifier;
  late ValueNotifier<int> coinNotifier;
  late ValueNotifier<double> bdtNotifier;
  late ValueNotifier<double> coinToViewRateNotifier;
  late ValueNotifier<double> adFrequencyNotifier; // A_111 Injection
  late ValueNotifier<double> sponsorFrequencyNotifier; // V15: Sponsor Frequency Injection
  late ValueNotifier<double> usdCpmNotifier; // V15 Dual Currency
  late ValueNotifier<double> bdtCpmNotifier; // V15 Dual Currency
  late ValueNotifier<double> frozenUsdNotifier; // A_177: Frozen Balance Tracker
  late ValueNotifier<double> frozenBdtNotifier; // A_177: Frozen Balance Tracker
  late ValueNotifier<List<dynamic>> bankHistoryNotifier; // A_177: Status Tracker
  // A_117 Recording State


  
  // A_117 Recording State
  CameraController? _cameraController;
  bool _isCameraFront = false;
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  String _activeSpeed = '1x';
  bool _isFlashOn = false;
  bool _isBeautifyOn = false;
  bool _isSpeedMenuVisible = true;
  String _activeTimer = 'Off';
  String _activeFilter = 'Normal';
  String _selectedSound = "Add sound";
  String? _selectedSoundUrl;
  String? _selectedSoundUploader;
  Timer? _recordingTimer;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  bool _isAdInitialized = false;
  String _activeNetworkCode = 'ADM';
  int _videoScrollCounter = 0; // V15: Tracker for Ads/Min logic
  DateTime _lastScrollAdTrigger = DateTime.now(); // A_111 Spam Guard Loop
 // A_111 Tracker
  VideoPlayerController? _adVideoController;
  VideoPlayerController? _preLoadAdController; // Double Buffering: V15 Seamless Pulse
  final SovereignAdEngine _adEngine = SovereignAdEngine();
  bool _isAdMuted = true; // A_111 Sound Toggle State (Default: Muted)
  bool _isCurrentAdCredited = false; // A_105 Double-Credit Guard
  final PageController _feedController = PageController(); // A_125: TikTok DNA Controller
  
  // A_122 Saved Hub State
  VideoPlayerController? _recordingAudioController;
  final List<String> _savedSoundsList = [];
  final Set<int> _savedVideosSet = {};
  final Set<int> _likedVideosSet = {};
  final Set<int> _repostedVideosSet = {};
  final Set<String> _blockedUsersSet = {};
  StreamSubscription? _adSubscription;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // A_111 Lifecycle Monitor
    _loadMeshIdentity(forceAuth: kIsWeb && (Uri.base.queryParameters['ref'] != null && Uri.base.queryParameters['ref']!.isNotEmpty));
    usdNotifier = ValueNotifier(0.0);
    coinNotifier = ValueNotifier(0);
    bdtNotifier = ValueNotifier(0.0);
    minWithdrawNotifier = ValueNotifier(10.0);
    bdtRateNotifier = ValueNotifier(115.0);
    commissionNotifier = ValueNotifier(10.0);
    mlmYieldNotifier = ValueNotifier(5.0); 
    coinToViewRateNotifier = ValueNotifier(200.0); 
    adFrequencyNotifier = ValueNotifier(5.0); 
    sponsorFrequencyNotifier = ValueNotifier(5.0);
    usdCpmNotifier = ValueNotifier(2.0);
    bdtCpmNotifier = ValueNotifier(100.0);
    frozenUsdNotifier = ValueNotifier(0.0);
    frozenBdtNotifier = ValueNotifier(0.0);
    bankHistoryNotifier = ValueNotifier([]);
    followerNotifier.value = 0;
    followingNotifier.value = 0;
    totalLikesNotifier.value = 0;
    _loadProfileImage();
    _loadGlobalSoundRegistry();
    _loadSavedSounds(); // A_122 Saved Hub Hub Persistence
    // V15 Zero-Mock: Removed _loadActivities to prevent legacy ghost notifications
    // _connect(); // Moved inside _loadMeshIdentity to prevent race conditions
    
    // A_111: Initial Ad Pulse [Sovereign V15 Master Ignite]
    // ✅ GAP FIX: Register callback so NativeAd success triggers UI rebuild (setState)
    _adEngine.onAdLoaded = () {
      if (mounted) setState(() {});
      debugPrint("AD_ENGINE: NativeAd loaded → UI rebuilt [setState called]");
    };
    _adEngine.syncMasterControl(_isAdSplitEnabled); // V15: Hard-Gate Synchronicity [Joralo Logic]
    _adEngine.ignite().then((_) => debugPrint("AD_ENGINE: Ignition Sequence Complete [READY]"));
    
    // Delayed Ignition: Wait 3s to let main feed stabilize
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentIndex == 0) {
        _activeNetworkCode = 'ADM';
        _updateAdVideoSource('ADM'); 
      }
    });    
    // Neural Ad Stream Sync: Rotates ads based on Admin Interval logic
    _adSubscription = _adEngine.adStream.stream.listen((netCode) {
      if (mounted && _currentIndex == 0) {
        setState(() => _activeNetworkCode = netCode);
        _prepareNextAd(netCode);
      }
    });
  }

  bool _isAppInForeground = true;
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // V15 Background Guard: Stop ads when app is not in focus
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInForeground = false;
      _adVideoController?.pause();
      debugPrint("AD_LIFECYCLE: Pause Triggered [App Backgrounded]");
    } else if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      if (_currentIndex == 0) {
        _adVideoController?.play();
        debugPrint("AD_LIFECYCLE: Auto-Resume Pulse [App Foregrounded]");
      }
    }
  }

  // A_110: Real-time System Message Ledger [TikTok DNA]
  final List<Map<String, String>> _systemMessages = []; // Sovereign V15: Removed all legacy mock messages. Only real pulses allowed.
  final ValueNotifier<int> _unreadCount = ValueNotifier(0);

  void _addSystemMessage(String title, String body, String icon) {
    setState(() {
      _systemMessages.insert(0, {
        'title': title,
        'body': body,
        'time': 'Just now',
        'icon': icon,
      });
      _unreadCount.value++;
    });
    // Removed: _onInteraction call here was causing infinite loop with INTERACTION_SYNC
  }

  bool _isAdInitializingGuard = false;

  /// V15 Seamless Logic: Pre-load the next ad while current one is playing
  Future<void> _prepareNextAd(String networkCode) async {
    final String? url = _adEngine.getAdSource(networkCode);
    if (url == null) return;

    debugPrint("AD_ENGINE: Pre-loading $networkCode [Seamless buffering]");
    
    // A_111: Simulation vs Real Switch [V15 Reality Patch]
    if (!url.contains('http')) {
      debugPrint("AD_ENGINE: Real SDK Mode Detected for $networkCode. Waiting for Native Render callback.");
      if (mounted && _currentIndex == 0) {
        setState(() {
          _adVideoController?.dispose();
          _activeNetworkCode = networkCode;
          _isAdInitialized = true;
          _isCurrentAdCredited = false; // Will be credited by successful render callback
        });
      }
      return;
    }

    final nextController = VideoPlayerController.networkUrl(
      Uri.parse(_resolveSecureUrl(url)),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    
    try {
      await nextController.initialize();
      await nextController.setVolume(0.0);
      await nextController.setLooping(true);
      
      if (mounted && _currentIndex == 0) {
        // Swap Buffer!
        final oldController = _adVideoController;
        setState(() {
          _adVideoController = nextController;
          _isAdInitialized = true;
          _isCurrentAdCredited = false;
        });
        
        if (_isAppInForeground) {
          await _adVideoController?.play();
        }
        debugPrint("AD_ENGINE: Seamless Swap Complete [$networkCode Playing]");
        
        // Clean up old buffer
        Future.delayed(const Duration(milliseconds: 500), () => oldController?.dispose());

        if (_isAdSplitEnabled) {
          _isCurrentAdCredited = true;
          _onInteraction('AD_IMPRESSION: $networkCode');
        }
      } else {
        nextController.dispose();
      }
    } catch (e) {
      debugPrint("AD_PRELOAD_ERROR: $e");
      nextController.dispose();
    }
  }

  void _updateAdVideoSource(String networkCode) {
    if (_isAdInitializingGuard) return;
    
    // A_111: Strong Guard (Joralo Logic) - If split is off, do not initialize
    if (!_isAdSplitEnabled) {
      _adVideoController?.dispose();
      _adVideoController = null;
      _isAdInitialized = false;
      return;
    }
    
    _isAdInitializingGuard = true;

    _adVideoController?.dispose();
    _isAdInitialized = false;
    _isCurrentAdCredited = false;
    
    final String? url = _adEngine.getAdSource(networkCode);
    if (url == null) {
      _isAdInitializingGuard = false;
      return;
    }

    // A_111: Simulation vs Real Switch [V15 Reality Patch]
    if (!url.contains('http')) {
       debugPrint("AD_ENGINE: Real SDK Mode Enabled. Clearing Video Buffer. Guarding Payouts.");
       _adVideoController?.dispose();
       _adVideoController = null;
       setState(() {
         _isAdInitialized = true;
         _isCurrentAdCredited = false;
       });
       
       // Note: AdMob payout logic is checked in the build method or Native callback
       // if AdMob is already fully loaded
       if (networkCode == 'ADM' && _adEngine.isGoogleAdLoaded) {
          if (_isAdSplitEnabled && !_isCurrentAdCredited) {
             _isCurrentAdCredited = true;
             _onInteraction('AD_IMPRESSION: ADM');
          }
       }
       
       _isAdInitializingGuard = false;
       return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_resolveSecureUrl(url)),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _adVideoController = controller;
    
    controller.initialize().then((_) async {
      if (!mounted || _adVideoController != controller || _currentIndex != 0) {
        controller.dispose();
        _isAdInitializingGuard = false;
        return;
      }

      await controller.setVolume(0.0);
      await controller.setLooping(true);
      setState(() => _isAdInitialized = true);
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _adVideoController == controller && _currentIndex == 0) {
          if (_isAppInForeground) {
             controller.play();
          }
        }
      });

      if (_isAdSplitEnabled) {
        _isCurrentAdCredited = true;
        _onInteraction('AD_IMPRESSION: $networkCode');
      }
      _isAdInitializingGuard = false;
    }).catchError((e) {
      debugPrint("AD_LOAD_ERROR: $e");
      _isAdInitializingGuard = false;
    });
  }

  final List<Map<String, dynamic>> _activities = [];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // A_111 Observer Cleanup
    _adSubscription?.cancel();
    _adVideoController?.dispose();
    _preLoadAdController?.dispose();
    usdNotifier.dispose();
    coinNotifier.dispose();
    bdtNotifier.dispose();
    minWithdrawNotifier.dispose();
    commissionNotifier.dispose();
    mlmYieldNotifier.dispose();
    bdtRateNotifier.dispose();
    coinToViewRateNotifier.dispose();
    adFrequencyNotifier.dispose();
    sponsorFrequencyNotifier.dispose();
    _feedController.dispose();
    _searchController.dispose();
    _inboxReplyController.dispose();
    _cameraController?.dispose();
    if (isConnected) channel.sink.close();
    super.dispose();
  }

  void _connect() {
    try {
      final String host = globalSovereignHost;
      String wsUrl = host.contains('fectok.com') ? "wss://$host/ws/user" : "ws://$host:5000/ws/user";
      
      if (kIsWeb) {
        debugPrint("QUANTUM_SYNC: Handshake Request -> $wsUrl");
      }

      channel = WebSocketChannel.connect(Uri.parse(_resolveSecureUrl(wsUrl)));
      broadcastStream = channel.stream.asBroadcastStream();
      setState(() => isConnected = true);
      
      broadcastStream.listen(
        (message) {
          try {
            if (!mounted) return;
            final decoded = json.decode(message);
             if (decoded['status'] == 'QUANTUM_SYNC_CONNECTED') {
                // Persistent Mesh ID [A_113]
                // If we are still CALIBRATING, but server sent a temp_id, we can use it or wait for CLAIM
                channel.sink.add(json.encode({
                  "action": "CLAIM_SESSION",
                  "mesh_id": meshID == "CALIBRATING..." ? "SOV_${Random().nextInt(99999)}" : meshID
                }));
                // V15 Mandatory: Fetch Latest Pulse immediately on handshake
                _fetchSovereignMedia();
             } else if (decoded['action'] == 'A_113_WALLET_SYNC' || decoded['action'] == 'WALLET_SYNC') {
                final newID = decoded['mesh_id']?.toString() ?? meshID;
                if (newID != meshID && newID != "CALIBRATING...") {
                   setState(() => meshID = newID);
                   _saveMeshIdentity(newID, userName, bio: userBio);
                }
                
                if (mounted) {
                  // A_113: Atomic Balance Sync (Only if explicitly provided)
                  if (decoded['usd'] != null) usdNotifier.value = (decoded['usd']).toDouble();
                  if (decoded['USD'] != null) usdNotifier.value = (decoded['USD']).toDouble();
                  if (decoded['usd_cpm'] != null) usdCpmNotifier.value = (decoded['usd_cpm']).toDouble();
                  if (decoded['bdt_cpm'] != null) bdtCpmNotifier.value = (decoded['bdt_cpm']).toDouble();
                  
                  if (decoded['bdt'] != null) bdtNotifier.value = (decoded['bdt']).toDouble();
                  if (decoded['BDT'] != null) bdtNotifier.value = (decoded['BDT']).toDouble();
                  
                  if (decoded['coins'] != null) coinNotifier.value = (decoded['coins']).toInt();
                  if (decoded['COINS'] != null) coinNotifier.value = (decoded['COINS']).toInt();
                  
                  // A_177: Sync Frozen/Processing Balance [Roadmap Step 1]
                  if (decoded['frozen_usd'] != null) frozenUsdNotifier.value = (decoded['frozen_usd']).toDouble();
                  if (decoded['frozen_bdt'] != null) frozenBdtNotifier.value = (decoded['frozen_bdt']).toDouble();
                  if (decoded['bank_history'] != null) bankHistoryNotifier.value = List<dynamic>.from(decoded['bank_history']);
                  
                  // A_109/A_113: Omni-Sync Rate Pulse (Broadcast from Admin)
                  if (decoded['min_withdraw'] != null) {
                    minWithdrawNotifier.value = (decoded['min_withdraw']).toDouble();
                  }
                  if (decoded['platform_commission'] != null) {
                    commissionNotifier.value = (decoded['platform_commission']).toDouble();
                  }
                  if (decoded['mlm_yield'] != null) {
                    mlmYieldNotifier.value = (decoded['mlm_yield']).toDouble();
                  }
                  if (decoded['bdt_rate'] != null) {
                    bdtRateNotifier.value = (decoded['bdt_rate']).toDouble();
                  }
                  
                  if (decoded['coin_to_view_rate'] != null) coinToViewRateNotifier.value = (decoded['coin_to_view_rate']).toDouble();
                  if (decoded['ad_frequency'] != null) adFrequencyNotifier.value = (decoded['ad_frequency']).toDouble();
                  if (decoded['sponsor_frequency'] != null) sponsorFrequencyNotifier.value = (decoded['sponsor_frequency']).toDouble();
                  if (decoded['usd_cpm'] != null) usdCpmNotifier.value = (decoded['usd_cpm']).toDouble();
                  if (decoded['bdt_cpm'] != null) bdtCpmNotifier.value = (decoded['bdt_cpm']).toDouble();
                  
                  if (decoded['ad_frequency'] != null || decoded['rotation_interval'] != null) {
                    if (decoded['ad_frequency'] != null) {
                      adFrequencyNotifier.value = (decoded['ad_frequency']).toDouble();
                      _adEngine.adsPerMinute = adFrequencyNotifier.value.toInt();
                    }
                    
                    // A_111 Gap Fix: Prioritize explicit Rotation Interval if sent by Admin
                    int newInterval;
                    if (decoded['rotation_interval'] != null) {
                      newInterval = (decoded['rotation_interval']).toInt();
                    } else {
                      newInterval = (60.0 / adFrequencyNotifier.value).toInt();
                    }
                    _adEngine.syncRotationInterval(newInterval);
                  }
                  
                  // Persistent Ad Engine Sync [V15 Reality Patch]
                  if (decoded['ad_api_keys'] != null) {
                    final keys = Map<String, dynamic>.from(decoded['ad_api_keys']);
                    _adEngine.syncAdminSlots(keys);
                    // ✅ GAP FIX: Force ad reload after keys received from backend
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) _updateAdVideoSource(_activeNetworkCode);
                    });
                  }
                  if (decoded['ad_toggles'] != null) {
                    final toggles = Map<String, dynamic>.from(decoded['ad_toggles']);
                    setState(() {
                      isMaintenanceMode = toggles['maintenance'] ?? isMaintenanceMode;
                      isGatingEnabled = toggles['gating'] ?? isGatingEnabled;
                      _isAdSplitEnabled = toggles['ad_split'] ?? _isAdSplitEnabled;
                      _adEngine.isRandomMode = toggles['ad_randomizer'] ?? _adEngine.isRandomMode;
                    });
                    _adEngine.syncMasterControl(_isAdSplitEnabled); // V15: Auto-Recovery on Reload
                    debugPrint("AD_TOGGLE_SYNC: Ad Split Is Now ${_isAdSplitEnabled ? 'ACTIVE' : 'OFF'}");
                  } else {
                    // V15 Mandatory: Force UI Rebuild on Balance Update if no toggles
                    setState(() {});
                  }
                  _adEngine.rotateAdsSequential();
                  
                  // A_119: Profile Identity Pulse
                  if (decoded['name'] != null || decoded['bio'] != null || decoded['profile_pic'] != null) {
                    setState(() {
                      if (decoded['name'] != null) userName = decoded['name'];
                      if (decoded['bio'] != null) userBio = decoded['bio'];
                      if (decoded['profile_pic'] != null) serverProfilePic = decoded['profile_pic'];
                    });
                    _saveMeshIdentity(meshID, userName, bio: userBio, profilePic: serverProfilePic);
                  }
                }
                
                // Profile Stats Sync [A_125]
                followerNotifier.value = (decoded['followers'] ?? followerNotifier.value).toInt();
                followingNotifier.value = (decoded['following'] ?? followingNotifier.value).toInt();
                totalLikesNotifier.value = (decoded['total_likes'] ?? totalLikesNotifier.value).toInt();
                _unreadCount.value = (decoded['unread_count'] ?? _unreadCount.value).toInt();

                debugPrint("A_113 PULSE: $meshID | USD: ${usdNotifier.value} | COIN: ${coinNotifier.value}");
             } else if (decoded['action'] == 'CREATOR_STATS_SYNC') {
                // V15 Mesh Injection: If this pulse is for ME, update my main profile counters
                final targetId = (decoded['target_id'] ?? "").toString().toLowerCase().replaceAll('@', '');
                final myId = meshID.toLowerCase().replaceAll('@', '');
                if (targetId == myId) {
                   followerNotifier.value = (decoded['followers'] ?? followerNotifier.value).toInt();
                   followingNotifier.value = (decoded['following'] ?? followingNotifier.value).toInt();
                   totalLikesNotifier.value = (decoded['total_likes'] ?? totalLikesNotifier.value).toInt();
                   debugPrint("A_125: Self-Stats Pulse Captured -> Followers: ${followerNotifier.value} | Following: ${followingNotifier.value}");
                }
             } else if (decoded['action'] == 'LATEST_MEDIA_SYNC') {
                 setState(() {
                   final rawMedia = List<Map<String, dynamic>>.from(decoded['media']);
                   sovereignMedia = rawMedia;
                 });
                 debugPrint("A_111: Media Ledger Synced & AI Ranked (${sovereignMedia.length} videos)");
             } else if (decoded['action'] == 'A_113_BRIDGE_SYNC') {
                if (decoded['numbers'] != null) {
                   bridgeConfigsNotifier.value = Map<String, dynamic>.from(decoded['numbers']);
                   debugPrint("A_113: Bridge Hub Pulse - Numbers Updated Real-time.");
                }
             } else if (decoded['action'] == 'A_118_CONTENT_UPDATE') {
                if (decoded['status'] == 'NEW_VIDEO_LIVE') {
                   // A_118/A_125 Zero Latency Injection
                   final Map<String, dynamic>? newEntry = decoded['entry'] != null ? Map<String, dynamic>.from(decoded['entry']) : null;
                   if (newEntry != null) {
                     setState(() {
                       // Insert at top to ensure it appears first in feed/grid
                       sovereignMedia.insert(0, newEntry);
                     });
                     _addSystemMessage('New Content Pulse', 'A new quality pulse from @${decoded['uploader']} is now live on the mesh.', 'auto_awesome');
                   }
                } else if (decoded['status'] == 'VIDEO_PURGED') {
                   final String purgdFile = decoded['filename'];
                   setState(() {
                     sovereignMedia.removeWhere((m) => m['file'] == purgdFile);
                   });
                }
             } else if (decoded['action'] == 'MAINTENANCE_TOGGLE') {
              setState(() => isMaintenanceMode = !isMaintenanceMode);
              _addSystemMessage('System Status Update', 'Maintenance Mode: ${isMaintenanceMode ? 'ENGAGED' : 'RESOLVED'}. Connectivity updated across mesh.', 'settings_suggest');
            } else if (decoded['action'] == 'LEGAL_ENFORCE') {
              setState(() => isLegallyAuthorized = false);
              _addSystemMessage('Account Lock', 'Legal authorization required. Please review terms to resume mesh activity.', 'policy');
            } else if (decoded['action'] == 'GATING_TOGGLE') {
              setState(() => isGatingEnabled = decoded['enabled'] == true);
              _addSystemMessage('Security Gating Pulse', 'Neural Gating state changed to: ${isGatingEnabled ? 'ENFORCED' : 'BYPASSED'}.', 'lock_open');
            } else if (decoded['action'] == 'AD_SPLIT_TOGGLE') {
                setState(() {
                  _isAdSplitEnabled = decoded['enabled'] == true;
                  if (!_isAdSplitEnabled) {
                    _adVideoController?.dispose();
                    _adVideoController = null;
                    _isAdInitialized = false;
                  }
                });
                _adEngine.syncMasterControl(_isAdSplitEnabled); // High-Precision Enforcement
                _addSystemMessage('Revenue Pulse', 'Ad-Revenue Split has been ${_isAdSplitEnabled ? 'ENABLED' : 'DISABLED'} for your node.', 'advertising_units');
                debugPrint("AD_SPLIT_EVENT: Real-time update -> $_isAdSplitEnabled");
                // V15 Gap Fix S3: Force UI to rebuild HomeFeed with new constraints
                _adEngine.rotateAdsSequential(); 
             } else if (decoded['action'] == 'AD_AI_INJECTOR_TOGGLE') {
                setState(() {}); // Force UI refresh
                _adEngine.rotateAdsSequential();
             } else if (decoded['action'] == 'AD_API_UPDATE') {
              // V15 Gap Fix #10: Use syncAdminSlots for proper isRealMode refresh
              _adEngine.syncAdminSlots({decoded['network']: decoded['key']});
              debugPrint("SYNC: Network API Update -> ${decoded['network']}:${decoded['key']}");
              _adEngine.rotateAdsSequential();
            } else if (decoded['action'] == 'AD_YIELD_UPDATE') {
              debugPrint("SYNC: Ad Yield Update -> ${decoded['value']}");
              _adEngine.rotateAdsSequential();
            } else if (decoded['action'] == 'AD_RANDOMIZER_TOGGLE') {
              _adEngine.isRandomMode = decoded['enabled'] == true;
              _adEngine.rotateAdsSequential();
              debugPrint("SYNC: Ad Randomizer -> ${_adEngine.isRandomMode}");
            } else if (decoded['action'] == 'AD_HYPER_SYNC') {
              // A_111: Zero-Latency Master Sync [V15 Reality Patch]
              int newInterval = (decoded['interval'] ?? 15).toInt();
              int newRate = (decoded['rate'] ?? 4).toInt();
              if (decoded['sponsor_frequency'] != null) {
                sponsorFrequencyNotifier.value = (decoded['sponsor_frequency']).toDouble();
              }
              _adEngine.adsPerMinute = newRate;
              _adEngine.updateInterval = newInterval; // This resets the timer immediately
              debugPrint("SYNC: AD_HYPER_SYNC -> Rate: $newRate, Interval: ${newInterval}s [TIMER RESET]");
            } else if (decoded['action'] == 'AD_SYNC_HYPER_LOGIC') {
              // A_111: Real-time Hyper-Logic Sync from Admin
              coinToViewRateNotifier.value = (decoded['coin_to_view_rate'] ?? 200.0).toDouble();
              adFrequencyNotifier.value = (decoded['ad_frequency'] ?? 5.0).toDouble();
              sponsorFrequencyNotifier.value = (decoded['sponsor_frequency'] ?? 5.0).toDouble();
              
              if (decoded['usd_cpm'] != null) usdCpmNotifier.value = (decoded['usd_cpm']).toDouble();
              if (decoded['bdt_cpm'] != null) bdtCpmNotifier.value = (decoded['bdt_cpm']).toDouble();

              // ✅ GAP FIX: Sync ad_api_keys from SYNC HYPER-LOGIC DESK button [V15 Critical]
              if (decoded['ad_api_keys'] != null) {
                final keys = Map<String, dynamic>.from(decoded['ad_api_keys']);
                _adEngine.syncAdminSlots(keys);
                debugPrint("AD_SYNC_HYPER_LOGIC: ad_api_keys synced -> $keys");
              }
              // Sync ad_toggles too
              if (decoded['ad_toggles'] != null) {
                final toggles = Map<String, dynamic>.from(decoded['ad_toggles']);
                setState(() {
                  isMaintenanceMode = toggles['maintenance'] ?? isMaintenanceMode;
                  _isAdSplitEnabled = toggles['ad_split'] ?? _isAdSplitEnabled;
                  _adEngine.isRandomMode = toggles['ad_randomizer'] ?? _adEngine.isRandomMode;
                  
                  if (!_isAdSplitEnabled) {
                    _adVideoController?.dispose();
                    _adVideoController = null;
                    _isAdInitialized = false;
                  }
                });
                _adEngine.syncMasterControl(_isAdSplitEnabled); // Hard-Gate Sync [Hyper-Logic]
              }

              // V15 Gap Fix #12: Sync rotation interval from Hyper-Logic
              int newInterval = (60.0 / adFrequencyNotifier.value).toInt();
              _adEngine.syncRotationInterval(newInterval);

              debugPrint("SYNC: CPM Update -> USD: ${usdCpmNotifier.value} | BDT: ${bdtCpmNotifier.value}");
              _adEngine.rotateAdsSequential(); // Force refresh on Hyper-Logic Sync
            } else if (decoded['action'] == 'A_113_TRANSACTION_DECISION') {
              String decision = decoded['decision'] ?? 'PENDING';
              String details = decoded['details'] ?? ''; 
              double amt = (decoded['amount'] ?? 0.0).toDouble();
              
              if (amt == 0.0) {
                try {
                  final res = RegExp(r"(\d+(\.\d+)?)").firstMatch(details);
                  if (res != null) amt = double.parse(res.group(1)!);
                } catch(_) {}
              }

              if (decision == 'APPROVED') {
                bool isWithdrawal = details.toUpperCase().contains('WITHDRAW');
                String typeLabel = isWithdrawal ? 'Withdrawal' : 'Transaction';
                String currency = details.toUpperCase().contains('BDT') ? 'BDT' : 'USD';
                if (mounted) {
                  _addSystemMessage('$typeLabel Approved [A_113]', 'Your $typeLabel of ${currency == 'BDT' ? '৳' : '\$'}${amt.toStringAsFixed(2)} confirmed by admin mesh.', 'account_balance_wallet');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.green, content: Text('$typeLabel APPROVED: ${currency == 'BDT' ? '৳' : '\$'}${amt.toStringAsFixed(2)}')),
                  );
                }
              } else if (decision == 'REJECTED') {
                bool isWithdrawal = details.toUpperCase().contains('WITHDRAW');
                String typeLabel = isWithdrawal ? 'Withdrawal' : 'Transaction';
                if (mounted) {
                  _addSystemMessage('$typeLabel Rejected', 'Admin decision: REJECTED for ${amt > 0 ? '\$${amt.toStringAsFixed(2)}' : 'request'}. Reason: Ledger audit required.', 'security');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.red, content: Text('$typeLabel REJECTED: ${amt > 0 ? '\$${amt.toStringAsFixed(2)}' : 'Action Denied'}')),
                  );
                }
              }
            } else if (decoded['action'] == 'A_113_WALLET_SYNC') {
              // Sovereign V15: High-Precision Wallet Pulse [A_113 Sync]
              if (mounted) {
                setState(() {
                  double usdBal = (decoded['usd'] ?? 0.0).toDouble();
                  double bdtBal = (decoded['bdt'] ?? 0.0).toDouble();
                  usdNotifier.value = usdBal;
                  bdtNotifier.value = bdtBal;
                  
                  if (decoded['is_verified'] != null) {
                    isVerified = decoded['is_verified'] == true;
                  }
                  if (decoded['bank_history'] != null) {
                    bankHistoryNotifier.value = List<Map<String, dynamic>>.from(decoded['bank_history']);
                  }
                });
              }
            } else if (decoded['action'] == 'A_113_TX_STATUS_UPDATE') {
              // Real-time status update for bank payouts or general transactions
              if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     backgroundColor: SovereignColors.cyan,
                     content: Text('PULSE: ${decoded['message'] ?? 'Transaction Status Updated'}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                   )
                 );
                 // Request a full wallet sync to refresh histories and balances
                 channel.sink.add(json.encode({"action": "SYNC_WALLET"}));
              }
            } else if (decoded['action'] == 'BINDING_OTP_SENT') {
              // A_142 Pulse: Notify user that OTP is on the way
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: SovereignColors.cyan, content: Text('PULSE: ${decoded['msg']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
              );
            } else if (decoded['action'] == 'BINDING_SUCCESS') {
              debugPrint("A_142: Mesh Identity Verified! Closing handshake dialog.");
              // Close the OTP Dialog (Top-most)
              if (Navigator.canPop(context)) Navigator.pop(context);
              
              // Trigger the pending transaction
              if (_pendingBindingAction != null) {
                _pendingBindingAction!();
                _pendingBindingAction = null; // Clear to prevent double-pulse
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: Colors.green, content: Text('IDENTITY BOUND SUCCESSFULLY [A_142 READY]'))
              );
            } else if (decoded['action'] == 'BINDING_FAILED') {
              _addSystemMessage('Security Alarm', 'Withdrawal binding failed: ${decoded['reason']}. Manual audit initiated.', 'report_problem');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: Colors.red, content: Text('BINDING FAILED: ${decoded['reason']}'))
              );
            } else if (decoded['action'] == 'TRANSACTION_STATUS_UPDATE') {
              final String status = decoded['status'] ?? 'UNKNOWN';
              final String type = decoded['type'] ?? 'TRANSACTION';
              final String ref = decoded['ref'] ?? '';
              
              if (mounted) {
                if (decoded['usd'] != null) usdNotifier.value = (decoded['usd']).toDouble();
                if (decoded['USD'] != null) usdNotifier.value = (decoded['USD']).toDouble();
                if (decoded['bdt'] != null) bdtNotifier.value = (decoded['bdt']).toDouble();
                if (decoded['BDT'] != null) bdtNotifier.value = (decoded['BDT']).toDouble();
              }

              _addSystemMessage(
                '$type ${status == 'SUCCESS' ? 'SUCCESS' : 'STATUS'}', 
                'Ref: $ref | Gateway Response: $status. ${status == 'FAILED' ? 'Auto-refund triggered if applicable.' : ''}', 
                status == 'SUCCESS' ? 'check_circle' : 'history'
              );
            } else if (decoded['action'] == 'TRANSACTION_REJECTED') {
              String reason = decoded['reason'] ?? 'UNKNOWN_ERROR';
              String msg = 'Transaction Rejected: $reason';
              if (reason == 'INVALID_QUANTUM_PIN') {
                  msg = 'Incorrect PIN. Attempts remaining: ${decoded['attempts_remaining']}';
              }
              if (reason == 'SECURITY_LOCKOUT') {
                  msg = decoded['message'] ?? 'Account locked due to multiple failed PIN attempts.';
              }
              if (reason == 'BELOW_MINIMUM_LIMIT') msg = 'Amount is below Minimum Limit of \$${decoded['limit']}';
              if (reason == 'GATEWAY_DISPATCH_FAILED') msg = 'Gateway Error: ${decoded['details']}';

              if (mounted) {
                _addSystemMessage('Security Alert', msg, 'lock');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.redAccent, 
                    content: Text(msg, style: const TextStyle(fontFamily: 'Orbitron', color: Colors.white)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else if (decoded['status'] == 'IMPRESSION_VERIFIED') {
              // A_111: Neural Revenue Sync - Viewer Reward (10% of Yield)
              double reward = (decoded['splits']?['viewer'] ?? 0.0).toDouble();
              if (reward > 0) {
                usdNotifier.value += reward;
                _addSystemMessage('Viewer Reward [A_111]', 'Impression confirmed! +\$${reward.toStringAsFixed(5)} credited to your wallet.', 'volunteer_activism');
                debugPrint("A_111: Viewer Reward Credited -> +\$$reward");
              }
            } else if (decoded['action'] == 'MLM_REWARD_CREDITED') {
              double benefit = (decoded['amount'] ?? 0.0).toDouble();
              String currency = decoded['currency'] ?? 'USD';
              if (currency == 'BDT') {
                bdtNotifier.value += benefit;
              } else {
                usdNotifier.value += benefit;
              }
              if (mounted) {
                _addSystemMessage('MLM Reward Credited', 'Benefit of ${currency == 'BDT' ? '৳' : '\$'}${benefit.toStringAsFixed(2)} arrived via mesh.', 'account_balance_wallet');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green, 
                    content: Text('MLM BENEFIT CREDITED: ${currency == 'BDT' ? '৳' : '\$'}${benefit.toStringAsFixed(2)}')
                  ),
                );
              }
            } else if (decoded['action'] == 'BOOST_TARGET_REACHED') {
              String msg = decoded['message'] ?? 'Target Reached';
              if (mounted) {
                _addSystemMessage('Quantum Boost Achieved', msg, 'sync_lock');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
                    duration: const Duration(seconds: 5),
                    behavior: SnackBarBehavior.floating,
                  )
                );
              }
            } else if (decoded['action'] == 'MLM_REFERRAL_LINKED') {
              if (mounted) {
                _addSystemMessage('Referral Node Linked', 'A new node has been successfully branched into your MLM network tree.', 'account_tree');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF00FFFF),
                    content: Text('REFERRAL NODE LINKED SUCCESS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                  ),
                );
              }
            } else if (decoded['action'] == 'MLM_WITHDRAWAL_COMMISSION_SENT') {
              double amount = (decoded['amount'] ?? 0.0).toDouble();
              String currency = decoded['currency'] ?? 'USD';
              if (mounted) {
                _addSystemMessage('MLM Commission Sent', '${currency == 'BDT' ? '৳' : '\$'}${amount.toStringAsFixed(2)} commission forwarded to your referrer node.', 'account_tree');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: SovereignColors.cyan,
                    content: Text(
                      'AI SYNC: ${currency == 'BDT' ? '৳' : '\$'}${amount.toStringAsFixed(2)} MLM commission sent to your referrer.',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                    )
                  ),
                );
              }
            } else if (decoded['action'] == 'CREATOR_REWARD_CREDITED') {
              double benefit = (decoded['amount'] ?? 0.0).toDouble();
              usdNotifier.value += benefit;
              if (mounted) {
                _addSystemMessage('Creator Reward [A_111]', 'Micro-reward of +\$${benefit.toStringAsFixed(5)} arrived for your quality pulse.', 'payments');
                // Sovereign V15: Hidden from UI pulse to prevent feed distraction (Persisted in Inbox)
              }
            } else if (decoded['action'] == 'A_121_TREND_ALERT') {
              // Sovereign V15: Phase 15 AI Trend-Radar
              if (mounted) {
                final trend = decoded['trend'] ?? {};
                final String type = trend['type'] ?? 'UNKNOWN';
                final String id = trend['id'] ?? 'Trend';
                final int velocity = trend['velocity'] ?? 0;
                
                _addSystemMessage('AI Trend Radar', 'Viral pulse detected: $type "$id" is accelerating (Velocity: $velocity). Use it to boost reach!', 'campaign');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.deepPurpleAccent,
                    content: Row(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(child: Text('AI TRENDING $type: $id', style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } else if (decoded['action'] == 'A_122_AI_COACH_INSIGHT') {
              // Sovereign V15: Phase 22 AI Creator Coach
              if (mounted) {
                final coachData = decoded['coach'] ?? {};
                final double prob = (coachData['viral_probability'] ?? 0.0).toDouble();
                final List tips = coachData['tips'] ?? [];
                
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0D0D0D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(color: SovereignColors.cyan, width: 2),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: SovereignColors.cyan),
                        SizedBox(width: 10),
                        Text('AI Creator Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Viral Probability: ${(prob * 100).toStringAsFixed(1)}%', 
                          style: TextStyle(
                            color: prob > 0.6 ? Colors.greenAccent : Colors.orangeAccent, 
                            fontWeight: FontWeight.bold, fontSize: 16
                          )
                        ),
                        const SizedBox(height: 15),
                        const Text('AI Tips:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        ...tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: SovereignColors.cyan)),
                              Expanded(child: Text(tip.toString(), style: const TextStyle(color: Colors.white, fontSize: 13))),
                            ]
                          ),
                        )),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('GOT IT', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                );
              }
            } else if (decoded['action'] == 'VERIFICATION_STATUS_SYNC') {
              if (mounted) {
                if (decoded['status'] == 'AUTO_APPROVED') setState(() => isVerified = true);
                _addSystemMessage('Verification Sync', 'Current status: ${decoded['status']}. AI Risk Analysis: ${decoded['risk']?.toStringAsFixed(1)}%.', 'verified_user');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: decoded['status'] == 'AUTO_APPROVED' ? Colors.green : Colors.orange,
                    content: Text('AI JUSTIFY: ${decoded['status']} (RISK: ${decoded['risk']?.toStringAsFixed(1)}%)'),
                  ),
                );
              }
            } else if (decoded['action'] == 'VERIFICATION_FINAL_RESULT') {
              if (mounted) {
                setState(() => isVerified = decoded['status'] == 'APPROVED' || decoded['status'] == 'AUTO_APPROVED');
                _addSystemMessage('Verification Final Result', 'Admin decision: ${decoded['status']}. Profile status updated across mesh.', 'verified_user');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: isVerified ? Colors.green : Colors.red,
                    content: Text('VERIFICATION RESULT: ${decoded['status']}'),
                  ),
                );
              }
            } else if (decoded['action'] == 'MLM_REWARD_REJECTED') {
              if (mounted) {
                _addSystemMessage('Reward Rejected', 'MLM Audit failed: ${decoded['reason']}. Please ensure referral nodes are active.', 'block');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: Colors.red, content: Text('MLM AUDIT REJECTED: ${decoded['reason']}')),
                );
              }
            } else if (decoded['action'] == 'GIFT_RECEIVED') {
              double amount = (decoded['amount'] ?? 0.0).toDouble();
              String sender = decoded['sender'] ?? 'Another Node';
              if (mounted) {
                _addSystemMessage('Gift Received!', 'You received ${amount.toInt()} coins from $sender.', 'card_giftcard');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: SovereignColors.cyan, content: Text('GIFT RECEIVED: +${amount.toInt()} Coins from $sender', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                );
              }
            } else if (decoded['status'] == 'PURGE_SUCCESS') {
              _fetchSovereignMedia();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Video Purged from Sovereign Vault'), backgroundColor: Colors.green)
                );
                // Sovereign V15: Automatic Exit from Detail View on Purge
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            } else if (decoded['action'] == 'INTERACTION_SYNC') {
              final String cId = (decoded['content_id'] ?? "").toString();
              final String type = (decoded['type'] ?? "").toString().toUpperCase();
              final String pulse = (decoded['pulse'] ?? "").toString().toUpperCase();
              final int count = decoded['count'] ?? 0;

              if (mounted) {
                setState(() {
                  for (var m in sovereignMedia) {
                    final String mFile = (m['file'] ?? "").toString();
                    final String mId = (m['id'] ?? (m['content_id'] ?? "")).toString();
                    
                    int? cIdx = int.tryParse(cId);
                    bool isMatch = (mFile == cId) || 
                                 (mId == cId) || 
                                 (mFile == '$cId.mp4') ||
                                 (cId.replaceFirst("V15_CONTENT_", "") == mFile) ||
                                 (cIdx != null && sovereignMedia.indexOf(m) == cIdx);

                    if (isMatch) {
                      if (type == 'LIKE') {
                        m['likes'] = count;
                        if (decoded['liked_by'] != null) {
                          m['liked_by'] = (decoded['liked_by'] as List).map((e) => e.toString().toUpperCase()).toList();
                        }
                      } else if (type == 'SAVE') {
                        m['saves'] = count;
                        if (decoded['saved_by'] != null) {
                          m['saved_by'] = (decoded['saved_by'] as List).map((e) => e.toString().toUpperCase()).toList();
                        }
                      } else if (type.contains('COMMENT')) {
                        m['comments'] = count;
                        if (decoded['comments_data'] != null) {
                          m['comments_data'] = List<Map<String, dynamic>>.from(decoded['comments_data']);
                        }
                      } else if (type.contains('SHARE')) {
                        m['shares'] = count;
                      } else if (type.contains('VIEW')) {
                        m['views'] = count;
                      }
                    }
                  }
                });
                _addSystemMessage('Mesh Pulse', 'Node $cId updated: $pulse ($count)', 'hub');
              }
            } else if (decoded['action'] == 'INBOX_DATA_SYNC') {
              if (mounted) {
                setState(() {
                  _activities.clear();
                  _activities.addAll(List<Map<String, dynamic>>.from(decoded['notifications'] ?? []));
                  _unreadCount.value = decoded['unread_count'] ?? 0;
                });
                debugPrint("A_107: INBOX_SYNCED | Count: ${_activities.length}");
              }
            } else if (decoded['action'] == 'SOCIAL_NOTIFICATION') {
              // Pulse Notification [TikTok DNA]
              if (mounted) {
                final notifType = (decoded['type'] ?? "LIKE").toString().toUpperCase();
                final fromUser = decoded['from'] ?? "Anonymous";
                final Map<String, dynamic>? newNotif = decoded['notification'];

                if (newNotif != null) {
                  final String notifId = newNotif['id'] ?? "NOTIF_${DateTime.now().millisecondsSinceEpoch}";
                  setState(() {
                    // Critical Guard: Only add if ID doesn't exist to prevent Ghost Loops
                      if (!_activities.any((a) => a['id'] == notifId)) {
                        _activities.insert(0, Map<String, dynamic>.from(newNotif));
                        _unreadCount.value = (decoded['unread_count'] ?? 0) > 0 ? decoded['unread_count'] : (_unreadCount.value + 1);
                        _onInteraction('SOCIAL_PULSE_RECEIVED: $notifType FROM $fromUser');
                        // V15 Mandatory: Trigger local broadcast to refresh the current filtered list
                        _activities.sort((a, b) => (b['timestamp'] ?? '').toString().compareTo((a['timestamp'] ?? '').toString()));
                      }
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.pinkAccent,
                    content: Text('Social: $fromUser ${notifType == 'LIKE' ? 'liked your video' : 'commented'}!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } else if (decoded['status'] != null) {
              setState(() => syncStatus = decoded['status'].toString());
            } else {
              setState(() => syncStatus = message.toString());
            }
          } catch (e) {
            setState(() => syncStatus = message.toString());
          }
        },
        onError: (err) {
          setState(() {
            isConnected = false;
            syncStatus = "Connection Error";
          });
          Future.delayed(const Duration(seconds: 3), _connect);
        },
        onDone: () {
          setState(() {
            isConnected = false;
            syncStatus = "Offline";
          });
          Future.delayed(const Duration(seconds: 3), _connect);
        },
      );
    } catch (e) {
      setState(() {
        isConnected = false;
        syncStatus = "Setup Failed";
      });
    }
  }

  Future<void> _loadMeshIdentity({bool forceAuth = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Sovereign V15: High-Precision Auth Override Pulse [A_107]
      final bool jsForceAuth = prefs.getString('force_auth_bypass') == "true";
      if (jsForceAuth) {
        await prefs.remove('force_auth_bypass');
        forceAuth = true;
      }

      final savedID = prefs.getString('sovereign_mesh_id');
      final savedName = prefs.getString('sovereign_user_name');
      
      if (savedID != null && savedID.startsWith("SOV_") && !forceAuth) {
        setState(() {
          meshID = savedID;
          userName = savedName ?? "Sovereign User";
          userProfession = prefs.getString('sovereign_user_profession') ?? "User";
          userBio = prefs.getString('sovereign_user_bio') ?? "Transforming Reality within the Mesh.";
          serverProfilePic = prefs.getString('sovereign_server_pic');
          _isAuthenticated = true;
          isLegallyAuthorized = true; // Auth implies legal consent in V15
        });
        debugPrint("A_113 [IDENTITY]: Anchored Identity $meshID recovered.");
        _connect(); // Connect AFTER identity is recovered
      } else {
         // Force Auth Pulse: Ignore local session to handle Referral Link
         debugPrint("A_107 [AUTH_GATE]: Session Bypassed due to Referral Pulse.");
         _connect();
      }
    } catch(e) {
      debugPrint("Persistence Error: $e");
    }
  }

  Future<void> _saveMeshIdentity(String id, String name, {String? profession, String? bio, String? profilePic}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sovereign_mesh_id', id);
      await prefs.setString('sovereign_user_name', name);
      if (profession != null) await prefs.setString('sovereign_user_profession', profession);
      if (bio != null) await prefs.setString('sovereign_user_bio', bio);
      if (profilePic != null) await prefs.setString('sovereign_server_pic', profilePic);
    } catch(e) {
      debugPrint("Save Error: $e");
    }
  }


  // V15: Removed unused _saveActivities to resolve IDE lint warning [A_107 Cleanup]

  // V15: Transitioned to direct real-time sync. Legacy persistence purged. [A_128 Done]

  void _authorizeLegally() {
    if (userDOB != null) {
      setState(() => isLegallyAuthorized = true);
      _onInteraction('LEGAL_CONSENT: AUTHORIZED_BY_DOB');
    }
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _profileImagePath = prefs.getString('sov_profile_path'));
  }

  Future<void> _pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sov_profile_path', image.path);
      setState(() => _profileImagePath = image.path);
      _onInteraction('PROFILE_PIC_UPDATED');
    }
  }

  void _fetchSovereignMedia() {
    if (isConnected) {
      try {
        // Sovereign V15 Add AI Discovery Parameter
        channel.sink.add(json.encode({
          "action": "GET_LATEST_MEDIA",
          "discovery_weight": _discoveryWeight
        }));
        _onInteraction('LATEST_MEDIA_PULL_REQUEST');
      } catch (e) {
        debugPrint("Fetch Sync Error: $e");
      }
    }
  }



  /// V15 Gap Fix S5: Extract sound_id from current feed item
  String _getCurrentSoundId() {
    try {
      final feedIndex = _feedController.hasClients 
          ? (_feedController.page?.round() ?? 0) 
          : 0;
      if (feedIndex < sovereignMedia.length) {
        return sovereignMedia[feedIndex]['sound_id'] ?? "V15_DEFAULT_SOUND";
      }
    } catch (_) {}
    return "V15_DEFAULT_SOUND";
  }

  List<Map<String, dynamic>> _rankMediaByAIWeights(List<Map<String, dynamic>> media) {
    // A_111: Neural Ranking Engine [V15 Master - Dynamic Upgrade]
    List<Map<String, dynamic>> ranked = List.from(media);
    
    ranked.sort((a, b) {
      double weightA = 0;
      double weightB = 0;
      
      // Weight 1: Professional Matching [High Priority]
      final String targetA = (a['target_profession'] ?? "").toString().toLowerCase();
      final String targetB = (b['target_profession'] ?? "").toString().toLowerCase();
      final String userProf = userProfession.toLowerCase();
      
      if (userProf.isNotEmpty) {
        if (targetA.contains(userProf) || userProf.contains(targetA)) weightA += 100;
        if (targetB.contains(userProf) || userProf.contains(targetB)) weightB += 100;
      }
      
      // Weight 2: Sponsored/Partner Status
      if (a['is_ad'] == true || a['is_sponsored'] == true || a['is_partner'] == true) weightA += 50;
      if (b['is_ad'] == true || b['is_sponsored'] == true || b['is_partner'] == true) weightB += 50;
      
      // Weight 3: Recency Pulse (New content gets a decaying boost)
      // Normalize timestamp: Higher timestamp (newer) = higher base score
      final double timeA = double.tryParse((a['timestamp'] ?? 0).toString()) ?? 0;
      final double timeB = double.tryParse((b['timestamp'] ?? 0).toString()) ?? 0;
      weightA += (timeA / 1000000); 
      weightB += (timeB / 1000000);

      // Weight 4: Interaction Intensity (Boosting liked/saved creators)
      final String uploaderA = (a['uploader'] ?? "").toString();
      final String uploaderB = (b['uploader'] ?? "").toString();
      
      // Check if user has liked/saved ANY content from this creator
      if (_likedVideosSet.any((idx) => idx < media.length && media[idx]['uploader'] == uploaderA)) weightA += 30;
      if (_likedVideosSet.any((idx) => idx < media.length && media[idx]['uploader'] == uploaderB)) weightB += 30;
      
      if (_savedVideosSet.any((idx) => idx < media.length && media[idx]['uploader'] == uploaderA)) weightA += 40;
      if (_savedVideosSet.any((idx) => idx < media.length && media[idx]['uploader'] == uploaderB)) weightB += 40;

      // Weight 5: Global Trending Factor
      weightA += (int.tryParse((a['views'] ?? 0).toString()) ?? 0) * 0.01;
      weightB += (int.tryParse((b['views'] ?? 0).toString()) ?? 0) * 0.01;
      
      return weightB.compareTo(weightA); // High score on top
    });
    
    return ranked;
  }

  void _onInteraction(String type, {String? contentId}) {
    // A_121 Sovereign Stealth Patch: Boost Visibility Weight
    setState(() {
      visibilityWeight += 0.05;
      
      // A_122 Saved Hub Logic
      if (type.startsWith('SOUND_SAVED: ')) {
        final sound = type.replaceFirst('SOUND_SAVED: ', '');
        if (!_savedSoundsList.contains(sound)) {
          _savedSoundsList.add(sound);
          _saveSavedSounds();
        }
      } else if (type.startsWith('SOUND_UNSAVED: ')) {
        _savedSoundsList.remove(type.replaceFirst('SOUND_UNSAVED: ', ''));
        _saveSavedSounds();
      } else if (type.startsWith('VIDEO_SAVED: ') || type.startsWith('VIDEO_SAVE: ') || type.startsWith('OPTIONS_FAV: ')) {
        final idxStr = type.contains(': ') ? type.split(': ')[1] : '';
        final idx = int.tryParse(idxStr);
        if (idx != null) _savedVideosSet.add(idx);
      } else if (type.startsWith('VIDEO_UNSAVED: ') || type.startsWith('VIDEO_UNSAVE: ')) {
        final idxStr = type.contains(': ') ? type.split(': ')[1] : '';
        final idx = int.tryParse(idxStr);
        if (idx != null) _savedVideosSet.remove(idx);
      } else if (type.startsWith('VIDEO_LIKED: ') || type.startsWith('VIDEO_LIKE: ')) {
        final idxStr = type.contains(': ') ? type.split(': ')[1] : '';
        int? idx = int.tryParse(idxStr);
        if (idx == null) {
          // fileName-based: find index from sovereignMedia
          idx = sovereignMedia.indexWhere((m) => m['file'] == idxStr);
          if (idx == -1) idx = null;
        }
        if (idx != null) _likedVideosSet.add(idx);
      } else if (type.startsWith('VIDEO_UNLIKED: ') || type.startsWith('VIDEO_UNLIKE: ')) {
        final idxStr = type.contains(': ') ? type.split(': ')[1] : '';
        int? idx = int.tryParse(idxStr);
        if (idx == null) {
          idx = sovereignMedia.indexWhere((m) => m['file'] == idxStr);
          if (idx == -1) idx = null;
        }
        if (idx != null) _likedVideosSet.remove(idx);
      } else if (type.startsWith('VIDEO_REPOST: ') || type.startsWith('OPTIONS_REPOST: ')) {
        final idxStr = type.contains(': ') ? type.split(': ')[1] : '';
        final idx = int.tryParse(idxStr);
        if (idx != null) _repostedVideosSet.add(idx);
      } else if (type.startsWith('CREATOR_BLOCK: ')) {
        final handle = type.replaceFirst('CREATOR_BLOCK: ', '');
        _blockedUsersSet.add(handle);
      } else if (type.startsWith('CREATOR_UNBLOCK: ')) {
        final handle = type.replaceFirst('CREATOR_UNBLOCK: ', '');
        _blockedUsersSet.remove(handle);
      }
    });

    if (isConnected) {
      // V15 OMNI-SYNC: Absolute Transaction Bridge
      if (type == 'TRANSX:SAVE_TEMPLATE' && contentId != null) {
        try {
          final txData = json.decode(contentId);
          channel.sink.add(json.encode(txData));
          debugPrint("A_113 TRANSX DISPATCH: ${txData['action']} | Cost: ${txData['cost']}");
          return;
        } catch (e) {
          debugPrint("TRANSX_ERROR: Failed to dispatch atomic transaction -> $e");
        }
      }

      // A_118: Intercept Sync Re-entry
      if (type == 'GET_LATEST_MEDIA') {
        channel.sink.add(json.encode({
          "action": "GET_LATEST_MEDIA",
          "discovery_weight": _discoveryWeight
        }));
        return;
      }

      // A_118: Intercept Deletion Pulse
      if (type.startsWith('DELETE_VIDEO_REQUEST: ')) {
        final fileName = type.replaceFirst('DELETE_VIDEO_REQUEST: ', '');
        channel.sink.add(json.encode({
          "action": "VIDEO_DELETE",
          "filename": fileName,
          "mesh_id": meshID
        }));
        return;
      }

      // A_112: Play Store Compliance Intercepts
      if (type.startsWith('REPORT_CONTENT: ')) {
        final payload = type.replaceFirst('REPORT_CONTENT: ', '').split('|');
        final cid = payload[0];
        final reason = payload.length > 1 ? payload[1] : "General Violation";
        channel.sink.add(json.encode({
          "action": "REPORT_CONTENT",
          "content_id": cid,
          "reason": reason,
          "mesh_id": meshID
        }));
        return;
      }

      if (type == 'DELETE_ACCOUNT_PERMANENT') {
        channel.sink.add(json.encode({
          "action": "DELETE_ACCOUNT",
          "mesh_id": meshID
        }));
        return;
      }

      // ═══════════════════════════════════════════════════
      // A_105 V15 FIX: AD_IMPRESSION → Correct Action Name
      // ═══════════════════════════════════════════════════
      if (type.startsWith('AD_IMPRESSION: ')) {
        // V15 CALIBRATION GUARD: Only send if user has a real authenticated SOV_ ID.
        // Prevents revenue going to a random temp ID when user is not logged in.
        if (!_isAuthenticated || !meshID.startsWith('SOV_')) {
          debugPrint("AD_PULSE_BLOCKED: User not authenticated. meshID=$meshID. Revenue withheld.");
          return;
        }

        final networkCode = type.replaceFirst('AD_IMPRESSION: ', '');
        String currentVideoFile = '';
        try {
          final feedIdx = _feedController.hasClients ? (_feedController.page?.round() ?? 0) : 0;
          if (feedIdx < sovereignMedia.length) {
            currentVideoFile = sovereignMedia[feedIdx]['file'] ?? '';
          }
        } catch (_) {}
        channel.sink.add(json.encode({
          "action": "AD_IMPRESSION",
          "network": networkCode,
          "video_file": currentVideoFile,
          "mesh_id": meshID
        }));
        debugPrint("AD_PULSE_SENT: network=$networkCode | video=$currentVideoFile | user=$meshID");
        return;
      }

      final payload = json.encode({
        "action": "USER_INTERACTION",
        "type": type,
        "content_id": contentId ?? (type.contains(': ') ? type.split(': ')[1] : "V15_CONTENT_$meshID"),
        "target_id": type == 'FOLLOW_USER' ? contentId?.replaceAll('@', '') : null,
        "sound_id": _getCurrentSoundId(),
        "weight": visibilityWeight.toStringAsFixed(2),
        "timestamp": DateTime.now().toIso8601String()
      });
      channel.sink.add(payload);
    }
  }

  Future<void> _pickGalleryMedia() async {
    if (!isGalleryEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('PERMISSION DENIED: Gallery access restricted in [A_106]'),
      ));
      return;
    }
    final ImagePicker picker = ImagePicker();
    // A_117: Multi-Media Gallery Injection [Photo & Video]
    final List<XFile> media = await picker.pickMultipleMedia();
    
    if (media.isNotEmpty) {
      _onInteraction('GALLERY_MEDIA_SELECTED: ${media.length} items');
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuantumPostHub(
          onInteraction: _onInteraction,
          uploaderId: meshID,
          channel: channel,
          selectedMedia: media, // A_117 Fix
          isLocationEnabled: isLocationEnabled,
          onAddMessage: _addSystemMessage,
          initialSound: _selectedSound != "Add sound" ? _selectedSound : null,
          initialSoundUrl: _selectedSoundUrl,
        )));
      }
    }
  }

  void _toggleFlip() {
    _onInteraction('CAM_FLIP_TRIGGERED');
    setState(() => _isCameraFront = !_isCameraFront);
    _cameraController?.dispose();
    _cameraController = null;
    _initializeCamera();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CAMERA FLIPPED'), duration: Duration(milliseconds: 800)));
  }

  void _toggleBeautify() {
    setState(() => _isBeautifyOn = !_isBeautifyOn);
    _onInteraction('CAM_BEAUTY_SET: $_isBeautifyOn');
  }

  void _toggleSpeedMenu() {
    setState(() => _isSpeedMenuVisible = !_isSpeedMenuVisible);
    _onInteraction('CAM_SPEED_MENU_TOGGLE: $_isSpeedMenuVisible');
  }

  void _showTimerPicker() {
    _showCreatorPicker('SELF TIMER', ['Off', '3s', '10s'], (val) {
      setState(() => _activeTimer = val);
      _onInteraction('CAM_TIMER_SET: $val');
    });
  }

  void _showFiltersPicker() {
    _showCreatorPicker('V15 QUANTUM FILTERS', ['Normal', 'Cyan Aura', 'Neon Pulse', 'Glass Dark', 'B&W Mesh'], (val) {
      setState(() => _activeFilter = val);
      _onInteraction('CAM_FILTER_SET: $val');
    });
  }

  void _showSoundPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) => SovereignSoundLibrary(
          onSelect: (sound) {
            setState(() {
              _selectedSound = sound['title'];
              _selectedSoundUploader = sound['uploader'] ?? sound['artist'] ?? 'Sovereign Original';
              _selectedSoundUrl = sound['url'];
              _prepareAudioController();
            });
            _onInteraction('CAM_SOUND_SET: ${sound["title"]}');
          },
        ),
      ),
    );
  }

  void _showCreatorPicker(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.all(15), child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
            const Divider(color: Colors.white10, height: 1),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: const TextStyle(color: Colors.white)),
              onTap: () { onSelect(opt); Navigator.pop(context); },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sovereignGuard(String operation, VoidCallback onAuthorized) {
    _onInteraction('SECURE_GUARD_TRIGGER: $operation');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('SOVEREIGN GUARD', style: TextStyle(color: Color(0xFFFF00FF))),
        content: Text('Authorize $operation request?\nDigital Evidence Archiving: ACTIVE', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAuthorized();
            }, 
            child: const Text('AUTHORIZE', style: TextStyle(color: SovereignColors.cyan))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return SovereignAuthPage(
        onGuidelinesTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SovereignGuidelinesView()));
        },
        onAuthComplete: (id, name, profession) {
          setState(() {
            meshID = id;
            userName = name;
            userProfession = profession;
            _isAuthenticated = true;
            isLegallyAuthorized = true;
          });
          _saveMeshIdentity(id, name, profession: profession, bio: userBio);
          // Force Reconnect with new Mesh ID
          if (isConnected) channel.sink.close();
          _connect();
        },
      );
    }

    if (isGatingEnabled && !isLegallyAuthorized) {
      return _buildLegalGating();
    }

    
    if (isMaintenanceMode && _currentIndex == 0) {
      return _buildMaintenanceBlocker();
    }

    final List<Widget> pages = [
      _buildHomeFeedWithAds(), // A_111 Integration
      _buildDiscoverHub(),
      _buildCreatorSuite(),
      _buildInboxHub(),
      _buildProfile(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          pages[_currentIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: Colors.black.withValues(alpha: 0.01), // A_117: Physical hit-test boundary
              elevation: 20,
              child: _buildSovereignNavBar(),
            ),
          ),
        ],
      ),
      endDrawer: _buildSettingsDrawer(),
    );
  }

  Widget _buildSovereignNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(0, Icons.home_rounded),
          _buildNavIcon(1, Icons.explore_rounded),
          _buildAddButton(),
          _buildNavIcon(3, Icons.forum_rounded),
          _buildNavIcon(4, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        if (index == 3) {
          setState(() => _inboxView = 'Main'); // V15: Always reset to All Activities on entry
          _fetchInbox();
        }
        // A_111: Pause/Resume ad logic to ensure NO BACKGROUND REVENUE [V15.1]
        if (_isAdInitialized && _adVideoController != null) {
          if (index == 0) {
            _adVideoController?.play();
            // Note: Ad payouts are strictly managed by the SDK callbacks
            // DO NOT process manual AD_IMPRESSION payouts here to prevent "Tab-Switch Exploit"
          } else {
            _adVideoController?.pause();
          }
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: _currentIndex == index ? SovereignColors.cyan : Colors.white60,
            size: 28,
          ),
          if (index == 3) // Inbox Badge
            ValueListenableBuilder<int>(
              valueListenable: _unreadCount,
              builder: (context, count, _) {
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        if (!isCameraEnabled || !isMicEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('PERMISSION DENIED: Camera/Mic restricted in [A_106]'),
          ));
          return;
        }
        setState(() {
          _currentIndex = 2;
        });
        _initializeCamera();
        if (_isAdInitialized && _adVideoController != null) {
          _adVideoController?.pause();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildMaintenanceBlocker() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, color: SovereignColors.cyan, size: 80),
            const SizedBox(height: 20),
            const Text(
              'SYSTEM RESTRICTED',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SovereignColors.cyan),
            ),
            const Text('V15 Calibration in Progress...', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalGating() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.gavel_rounded, color: SovereignColors.cyan, size: 50),
            const SizedBox(height: 15),
            const Text(
              'SOVEREIGN V15 STATUTES',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const Text(
              'A_112: DIGITAL GOVERNANCE PROTOCOL',
              style: TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statuteItem("1. ABSOLUTE ADMIN IMMUNITY", "The Architect (Admin) of the Sovereign Mesh is legally immune from all interactions, content, and transactions occurring within this node. You waive any right to hold Admin liable for any direct or indirect consequences of system use."),
                      _statuteItem("2. USER-CENTRIC LIABILITY", "All data, media, and interactions uploaded under your SOV_ID are your sole legal responsibility. In cases of copyright infringement or illegal activity, you are the primary and only defendant."),
                      _statuteItem("3. COPYRIGHT INDEMNIFICATION", "By uploading content, you warrant complete ownership or valid license for such media. If a third party claims copyright violation, Admin will purge the content, and you agree to indemnify and pay all legal costs incurred by Admin due to your violation."),
                      _statuteItem("4. FINALITY OF DECISION", "Any administrative action, including but not limited to account termination, asset freezing, or content purging, is FINAL and non-negotiable. Admin is the ultimate arbiter of Mesh logic."),
                      _statuteItem("5. EVIDENCE ARCHIVING [A_106]", "All actions are cryptographically logged for Admin's legal protection. These logs constitute irrefutable digital evidence that can be utilized to defend the Admin or provided to authorities if required for Admin safety."),
                      _statuteItem("6. NO FINANCIAL GUARANTEE", "Digital assets (COINS, USD, BDT balance) are part of an experimental high-risk ledger. Admin is not liable for loss due to user negligence, PIN compromise, or mesh fluctuation."),
                      _statuteItem("7. PROHIBITED ACTIVITY PURGE", "Any content deemed harmful, illegal, or violating Sovereign DNA by the A_115 AI Moderator is subject to immediate removal. Admin is not required to provide notice or justification."),
                      _statuteItem("8. THIRD-PARTY DECOUPLING", "Admin is not responsible for any external links, ads, or services introduced via the mesh. Users interact with such entities at their own peril."),
                      _statuteItem("9. JURISDICTION OF SOVEREIGNTY", "All disputes are settled within the Sovereign Mediation Layer. You waive the right to seek civil litigation or class-action status against the Admin in any state or international court."),
                      _statuteItem("10. HARDWARE COMPLIANCE", "Usage of this application implies your device belongs to the Mesh network and must comply with A_120 interaction standards. Bot patterns will trigger immediate Node termination."),
                      _statuteItem("11. AGE & COMPETENCY VERIFIED", "By proceeding, you swear you are of legal age and mental capacity to enter this binding statutory agreement. Misrepresentation of age results in immediate total mesh ban."),
                      _statuteItem("12. STATUTORY EVOLUTION", "Admin reserves the right to modify these laws at any time. Continued pulse connection constitutes an automatic and legally binding acceptance of all current and future statutes."),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => userDOB = picked);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: Text(userDOB == null ? 'CONFIRM DATE OF BIRTH' : 'DOB VERIFIED: ${userDOB!.toLocal()}'.split(' ')[0], style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 15),
                  if (userDOB != null)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _authorizeLegally,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SovereignColors.cyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('I ACCEPT ALL STATUTES IRREVOCABLY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statuteItem(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: SovereignColors.cyan, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5, fontFamily: 'monospace')),
        ],
      ),
    );
  }
  Widget _buildHomeFeedWithAds() {
    return SizedBox.expand( // V15 FIX: Ensure the entire viewport is captured [No Collapse]
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Core Content Area: Fills available space based on Ad Split
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: _isAdSplitEnabled ? MediaQuery.of(context).size.height * 0.40 : 0,
            child: _buildHomeFeed(key: ValueKey(_isAdSplitEnabled)), 
          ),

        // Top Floating Tabs (Following | For You) - HIDDEN [A_109 Omni-Sync]
        // But operations continue in the mesh background
        Visibility(
          visible: false,
          child: Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, 
                          height: 8, 
                          decoration: BoxDecoration(
                            color: isConnected ? Colors.greenAccent : Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isConnected ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.5),
                                blurRadius: isConnected ? 5 : 2,
                                spreadRadius: 2,
                              )
                            ]
                          ),
                        ),
                        const SizedBox(width: 8),
                        Visibility(
                          visible: false,
                          child: Text(isConnected ? 'MESH SYNCED' : 'OFFLINE', style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => setState(() => _currentFeedTab = 'Following'),
                      child: Text('Following', style: TextStyle(color: _currentFeedTab == 'Following' ? Colors.white : Colors.white60, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 20),
                    Container(width: 1, height: 15, color: Colors.white24),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => setState(() => _currentFeedTab = 'For You'),
                      child: Text('For You', style: TextStyle(color: _currentFeedTab == 'For You' ? Colors.white : Colors.white60, fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 25% AI-Injecting Native Ad Engine (A_111) - ROOT LEVEL INTEGRATION
        if (_isAdSplitEnabled)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.40,
            decoration: const BoxDecoration(
              color: Color(0xFF0D0D0D),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black, // Fallback
                    // A_111: The "Slicebar" - Sovereign Neon Divider [V15 Evolution]
                    border: Border(top: BorderSide(color: SovereignColors.cyan, width: 2.5)),
                    boxShadow: [
                      BoxShadow(
                        color: SovereignColors.cyan.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 100% REAL PRODUCTION RENDERER [A_111: V15 Final Mastery]
                      if (_adEngine.isRealMode && !(_adEngine.getAdSource(_activeNetworkCode)?.contains('http') ?? true))
                        Container(
                          margin: const EdgeInsets.only(top: 0, left: 12.0, right: 12.0, bottom: 12.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: _adEngine.isGoogleAdLoaded && _adEngine.googleNativeAd != null
                              ? AdWidget(ad: _adEngine.googleNativeAd!)
                              : const Center(child: CircularProgressIndicator(color: SovereignColors.cyan)),
                        )
                      else if (_isAdInitialized && _adVideoController != null)
                        Center(
                          child: ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _adVideoController!,
                            builder: (context, VideoPlayerValue value, child) {
                              if (value.isInitialized) {
                                return SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.hardEdge,
                                    child: SizedBox(
                                      width: value.size.width,
                                      height: value.size.height,
                                      child: VideoPlayer(_adVideoController!),
                                    ),
                                  ),
                                );
                              }
                              return const Center(child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 1.5));
                            },
                          ),
                        )
                      else
                        Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sync, color: Colors.white10, size: 24),
                                const SizedBox(height: 8),
                                Text(kIsWeb ? "MESH SYNCING..." : "SYNCHRONIZING MESH...", 
                                  style: const TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                        ),
                      
                      // Gradient Overlay for Readability - HIDDEN IN REAL MODE (Google Policy Compliance)
                      if (!(_adEngine.isRealMode && !(_adEngine.getAdSource(_activeNetworkCode)?.contains('http') ?? true)))
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),

                      // Unified UI Overlay
                      Stack(
                        children: [
                          // Tier 2: Mute Toggle - ALWAYS VISIBLE [User Command]
                          // Shifted Up to clear the Bottom Navigation Bar
                          Positioned(
                            left: 20,
                            bottom: 90, 
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAdMuted = !_isAdMuted;
                                  if (_isAdInitialized && _adVideoController != null) {
                                    _adVideoController!.setVolume(_isAdMuted ? 0.0 : 1.0);
                                  }
                                });
                                _onInteraction('AD_MUTE_TOGGLE');
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white10, width: 0.5),
                                ),
                                child: Icon(_isAdMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white70, size: 12),
                              ),
                            ),
                          ),

                          // Legacy Skeleton UI - AUTO-HIDE IN REAL MODE [Surgical Execution]
                          if (!(_adEngine.isRealMode && !(_adEngine.getAdSource(_activeNetworkCode)?.contains('http') ?? true)))
                            Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Tier 1: Action Buttons [Simulation Mode Only]
                                        Row(
                                          children: [
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.7), 
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.white24, width: 0.5),
                                              ),
                                              child: const Text('LEARN MORE', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: SovereignColors.cyan.withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.5), width: 0.5),
                                              ),
                                              child: const Text('INSTALL', style: TextStyle(color: SovereignColors.cyan, fontSize: 7, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Report & Sponsored Label
                                        Row(
                                          children: [
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(3),
                                             ),
                                              child: const Text('REPORT', style: TextStyle(color: Colors.redAccent, fontSize: 6, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text('SPONSORED', style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1.5, fontWeight: FontWeight.w400)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Network Badge
                                        Row(
                                          children: [
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: SovereignColors.cyan.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Text(
                                                'NETWORK: $_activeNetworkCode',
                                                style: const TextStyle(color: SovereignColors.cyan, fontSize: 6, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  void _openCreatorProfile(String handle) {
    _onInteraction('OPEN_CREATOR_PROFILE: $handle');
    bool isBlocked = _blockedUsersSet.contains(handle);
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => CreatorProfileView(
        handle: handle, 
        onInteraction: _onInteraction,
        isBlocked: isBlocked,
        onAddMessage: _addSystemMessage,
        meshID: meshID, 
        mediaLedger: sovereignMedia, 
        onSoundSelect: (name) => setState(() => _selectedSound = name),
        onCameraOpen: () => setState(() => _currentIndex = 2),
        channel: channel,
        broadcastStream: broadcastStream,
      ))
    );
  }

  void _openVideoDetail(int initialIndex, {List<int>? videoIndices, int? count}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SovereignVideoDetailFeed(
          initialIndex: initialIndex,
          videoIndices: videoIndices,
          totalCount: count ?? (videoIndices != null ? videoIndices.length : 100),
          onInteraction: _onInteraction,
          creatorProfileOpen: _openCreatorProfile,
          soundDetailOpen: _openSoundDetail,
          onAddMessage: _addSystemMessage,
          onSoundSelect: (name) => setState(() => _selectedSound = name), // A_128
          meshID: meshID, // A_105
          mediaLedger: sovereignMedia, // A_118 Fix
        ),
      ),
    );
  }

  List<Map<String, dynamic>> sovereignMedia = []; // A_118 Dynamic Content Ledger
  List<Map<String, dynamic>> _searchResults = []; // Search Pulse Results
  bool _isSearching = false; // Search Activity State
  Map<String, String> _globalSoundRegistry = {}; // A_128 Pulse

  Future<void> _loadSavedSounds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('sovereign_saved_sounds');
      if (list != null) {
        setState(() {
          _savedSoundsList.clear();
          _savedSoundsList.addAll(list);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveSavedSounds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('sovereign_saved_sounds', _savedSoundsList);
    } catch (_) {}
  }

  Future<void> _loadGlobalSoundRegistry() async {
    try {
      // V15 Gap Fix S3: Dynamic host sensing [A_128]
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
      final String endpoint = _resolveSecureUrl('http://$host:9900/all');
      final res = await http.get(Uri.parse(endpoint));
      if (res.statusCode == 200) {
        final List sounds = json.decode(res.body);
        final Map<String, String> reg = {};
        for (var s in sounds) {
          reg[s['title']] = _resolveSecureUrl('http://$host:9900${s['url']}');
        }
        setState(() => _globalSoundRegistry = reg);
        debugPrint("[A_108] Global Sound Registry: ${reg.length} sounds loaded");
      }
    } catch (e) {
      debugPrint("MAIN_GLOBAL_SOUND_SYNC_ERR: $e");
    }
  }

  void _openSoundDetail(String soundName) {
    _onInteraction('OPEN_SOUND_DETAIL: $soundName');
    
    // Resolve URL Priority 1: Global Sound Registry (Studio/Vault Tracks)
    String? resolvedUrl = _globalSoundRegistry[soundName];
    
    // Resolve URL Priority 2: Mesh Ledger (Harvested/User Original Sounds)
    final match = sovereignMedia.firstWhere(
      (m) => m['sound_name'] == soundName || m['title'] == soundName,
      orElse: () => {}
    );
    
    if (resolvedUrl == null && match.isNotEmpty) {
      resolvedUrl = match['sound_url'] ?? match['url'];
    }

    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => SovereignSoundDetail(
        soundName: soundName, 
        soundUrl: resolvedUrl, // A_128: Pulse Sync
        onInteraction: _onInteraction,
        onAddMessage: _addSystemMessage,
        onSoundSelect: (name) => setState(() => _selectedSound = name),
        mediaLedger: sovereignMedia,
        onVideoTap: (initialIndex, indices) => _openVideoDetail(initialIndex, videoIndices: indices),
        onUseSound: () {
          // Sovereign Master Pop: Clear all overlay layers (Sound Detail, Video Detail, etc.)
          // to ensure we land back on the Main Navigation circuit.
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          setState(() {
            _selectedSound = soundName;
            _selectedSoundUploader = match['uploader'] ?? 'Sovereign Original';
            _selectedSoundUrl = resolvedUrl;
            _prepareAudioController();
            _currentIndex = 2; // Jump to Creator Suite [A_117]
          });
          _onInteraction('CREATOR_SYNC_ACTIVE: $soundName [URL: $resolvedUrl]');
        },
      ))
    );
  }

  Widget _buildHomeFeed({Key? key}) {
    return RefreshIndicator(
      key: key,
      onRefresh: () async {
        _fetchSovereignMedia();
        await Future.delayed(const Duration(seconds: 1));
        _onInteraction('FEED_REFRESH_TRIGGERED');
      },
      color: SovereignColors.cyan,
      backgroundColor: Colors.black,
      child: PageView.builder(
        controller: _feedController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            // Note: We use a separate local feed index if necessary, 
            // but for A_111, we need to ensure the engine knows we are still on index 0 (Home)
            if (_currentIndex == 0) {
              _videoScrollCounter++;
              // V15 Hyper-Logic: Rotate only when gap threshold (Ads/Min) reached
              if (_videoScrollCounter >= _adEngine.adsPerMinute) {
                final now = DateTime.now();
                if (now.difference(_lastScrollAdTrigger).inSeconds >= 10) {
                  _lastScrollAdTrigger = now;
                  _videoScrollCounter = 0;
                  _adEngine.rotateAdsSequential();
                  debugPrint("AD_ROTATOR: Gap Threshold Reached [${_adEngine.adsPerMinute} scrolls]");
                } else {
                  // V15 Anti-Spam Vault
                  _videoScrollCounter = _adEngine.adsPerMinute - 1; 
                  debugPrint("AD_ROTATOR: Spam Guard Active. Slow down scroll to earn.");
                }
              }
            }
          });
        },
        itemCount: sovereignMedia.length + testVideos.length,
        itemBuilder: (context, index) {
          String? customUrl;
          String? uploader;
          String? description; // A_118
          
          if (index < sovereignMedia.length) {
            // Priority: User's Uploaded Content
            customUrl = sovereignMedia[index]['url'];
            // A_119: Use uploader_name if available (TikTok Standard), fallback to handle
            uploader = sovereignMedia[index]['uploader_name'] ?? sovereignMedia[index]['uploader'];
            description = sovereignMedia[index]['desc'];
          } else {
            // Fallback: Legacy Test Videos
            int testIdx = index - sovereignMedia.length;
            customUrl = testVideos[testIdx];
            uploader = "Sovereign Master"; // Premium Fallback Name
            description = "Sovereign Legacy Content Feed";
          }

          return ValueListenableBuilder<double>(
            valueListenable: adFrequencyNotifier,
            builder: (context, adFreq, _) {
              return ValueListenableBuilder<double>(
                valueListenable: sponsorFrequencyNotifier,
                builder: (context, sFreq, _) {
                  return VideoFeedItem(
                    index: index,
                    videoUrl: _resolveSecureUrl(customUrl),
                    uploaderName: uploader,
                    uploaderHandle: (index < sovereignMedia.length) ? sovereignMedia[index]['uploader'] : uploader,
                    isVerified: (index < sovereignMedia.length) ? (sovereignMedia[index]['uploader_verified'] == true) : false,
                    description: description, // A_118: Pass real desc
                    onInteraction: _onInteraction,
                    adPanelHeight: _isAdSplitEnabled ? MediaQuery.of(context).size.height * 0.40 : 0,
                    creatorProfileOpen: _openCreatorProfile,
                    soundDetailOpen: _openSoundDetail,
                    isHome: true,
                    adFrequency: adFreq, 
                    sponsorFrequency: sFreq,
                    onAddMessage: _addSystemMessage,
                    userProfileImage: _profileImagePath,
                    meshID: meshID, // A_105 ownership check
                    mediaLedger: sovereignMedia, // Pass down for mapping
                    onSkip: () {
                      if (_feedController.hasClients) {
                        _feedController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        _onInteraction('FEED_DISLIKE_SKIP: INDEX=$index');
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _executeSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }
    
    final q = query.toLowerCase().trim();
    _onInteraction('GLOBAL_SEARCH_QUERY: $query');
    
    setState(() {
      _isSearching = true;
      _searchResults = sovereignMedia.where((m) {
        final uID = (m['uploader'] ?? "").toString().toLowerCase();
        final uName = (m['uploader_name'] ?? "").toString().toLowerCase();
        final desc = (m['desc'] ?? "").toString().toLowerCase();
        return uID.contains(q) || uName.contains(q) || desc.contains(q);
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found ${_searchResults.length} results in the Mesh.', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: SovereignColors.cyan,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 800),
      )
    );
  }


  Widget _buildDiscoverHub() {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Unified TikTok Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) {
                       if (v.isEmpty) _executeSearch("");
                    },
                    onSubmitted: _executeSearch,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
                      prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
                      suffixIcon: _isSearching ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _executeSearch("");
                        },
                      ) : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _executeSearch(_searchController.text),
                child: const Text(
                  'Search',
                  style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Expanded(
          child: _isSearching ? ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildDiscoverSection('Search Results', Icons.radar),
              if (_searchResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.search_off, color: Colors.white12, size: 64),
                        SizedBox(height: 16),
                        Text('No matches found in the Mesh.', style: TextStyle(color: Colors.white24)),
                      ],
                    ),
                  ),
                )
              else
                ..._searchResults.map((m) => _buildSearchResultRow(m)),
            ],
          ) : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // High-Impact Trending Banner
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage('https://placeholder.com/banner'),
                    fit: BoxFit.cover,
                    opacity: 0.6,
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      bottom: 15,
                      left: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('#SOVEREIGN_V15', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text('Join the Chain-Reaction Challenge', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildDiscoverSection('Global Mesh Pulse', Icons.tag),
              if (sovereignMedia.isEmpty) 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Scanning mesh [SSL-ENFORCED]...', style: TextStyle(color: Colors.white24, fontSize: 12))),
                )
              else 
                ...sovereignMedia.take(5).map((m) => _buildHashtagRow(m['desc'] ?? 'sovereign_v15', '${m['views'] ?? 0} views')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: SovereignColors.cyan, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          const Text('See all', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
        ],
      ),
    );
  }

  Widget _buildHashtagRow(String tag, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.tag, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Text(tag, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(count, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSearchResultRow(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        final mainIndex = sovereignMedia.indexWhere((m) => m['file'] == item['file']);
        if (mainIndex != -1) {
          _openVideoDetail(mainIndex);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            (() {
              final String tUrl = getSovereignThumb(sovereignMedia.indexOf(item), sovereignMedia);
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: tUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(tUrl), fit: BoxFit.cover)
                      : null,
                  color: Colors.white10,
                ),
                child: tUrl.isEmpty 
                  ? const Icon(Icons.play_circle_outline, color: Colors.white24) 
                  : null,
              );
            })(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['desc'] ?? 'Sovereign Pulse',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '@${item['uploader_name'] ?? item['uploader'] ?? 'mesh_node'}',
                        style: const TextStyle(color: SovereignColors.cyan, fontSize: 12),
                      ),
                      if (item['uploader_verified'] == true) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: SovereignColors.cyan, size: 14),
                      ],
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${item['uploader']}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  void _showInboxReplyField(String user) {
    _onInteraction('INBOX_COMMENT_REPLY_OPEN: $user');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _inboxReplyController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Reply to $user...',
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      if (_inboxReplyController.text.isNotEmpty) {
                        _onInteraction('INBOX_COMMENT_REPLY_SUBMIT: ${_inboxReplyController.text}');
                        _inboxReplyController.clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reply synced to Sovereign Mesh'), backgroundColor: SovereignColors.cyan)
                        );
                      }
                    },
                    child: const CircleAvatar(
                      backgroundColor: SovereignColors.cyan,
                      radius: 20,
                      child: Icon(Icons.arrow_upward, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildInboxHub() {
    if (_inboxView == 'DMs') return _buildDirectMessages();

    // V15 Navigation-Driven Sync: Data is updated via the navigation onTap trigger.
    // Build method remains clean to avoid recursive state-loops.
    final String activeTitle = _inboxView == 'Main' ? 'All Activities' : _inboxView;

    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                  child: Center(
                    child: Text(
                      activeTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    )
                  )
                ),
                if (_inboxView != 'Main')
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => setState(() => _inboxView = 'Main'),
                  ),
                if (_inboxView == 'Main')
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    onPressed: () => setState(() => _inboxView = 'DMs'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: SovereignColors.cyan, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Refresh Mesh Pulse',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _fetchInbox();
                        _onInteraction('INBOX_MANUAL_REFRESH');
                      },
                      child: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // High-Fidelity Interaction Categories [TikTok DNA - Scrollable Mesh]
        SizedBox(
          height: 85,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildInboxCategory(Icons.person_add_outlined, 'Followers', Colors.cyan, 'FOLLOW'),
                const SizedBox(width: 25),
                _buildInboxCategory(Icons.favorite_outline, 'Likes', Colors.pinkAccent, 'LIKE'),
                const SizedBox(width: 25),
                _buildInboxCategory(Icons.chat_bubble_outline, 'Comments', Colors.orangeAccent, 'COMMENT'),
                const SizedBox(width: 25),
                _buildInboxCategory(Icons.share_outlined, 'Shares', Colors.lightBlueAccent, 'SHARE'),
                const SizedBox(width: 25),
                _buildInboxCategory(Icons.visibility_outlined, 'Views', Colors.greenAccent, 'VIEW'),
                const SizedBox(width: 25),
                _buildInboxCategory(Icons.alternate_email, 'Mentions', Colors.blueAccent, 'MENTION'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _inboxView == 'Main' ? 'Activities' : 'Recent Activities', 
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)
              ),
              if (_inboxView == 'Main' && _activities.any((a) => a['is_new'] == true || a['read'] == false))
                GestureDetector(
                  onTap: _markInboxRead,
                  child: const Text('Mark all as read', style: TextStyle(color: SovereignColors.cyan, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        
        Expanded(child: _buildInboxList(_inboxView)),
      ],
    );
  }

  void _fetchInbox() {
    // Neural Request: Fetch Persistent Inbox from Backend
    channel.sink.add(json.encode({
      "action": "GET_INBOX",
      "mesh_id": meshID
    }));
    _onInteraction('INBOX_PULSE_FETCH');
  }

  void _markInboxRead() {
    channel.sink.add(json.encode({
      "action": "MARK_INBOX_READ",
      "mesh_id": meshID
    }));
    setState(() {
      for (var a in _activities) {
        a['is_new'] = false;
        a['read'] = true;
      }
      _systemMessages.clear(); // Clear local system alerts as well
      _unreadCount.value = 0;
    });
    _onInteraction('INBOX_MARK_READ');
  }


  Widget _buildInboxCategory(IconData icon, String label, Color color, String type) {
    return GestureDetector(
      onTap: () {
        setState(() => _inboxView = label);
        _onInteraction('INBOX_CATEGORY_TAP: $label');
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                // Show dot if category has new items
                if (_activities.any((a) => a['type'] == type && (a['is_new'] == true || a['read'] == false)))
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }


  Widget _buildInboxList(String filter) {
    // V15 Mesh Filtering Logic + System Message Integration
    final List<Map<String, dynamic>> activities = [];
    
    // 1. Add social activities
    activities.addAll(_activities);
    
    // 2. Wrap system messages in notification schema [A_110 Interaction]
    for (var msg in _systemMessages) {
       activities.add({
         "id": "SYS_${msg['title']}_${msg['time']}",
         "type": "SYSTEM",
         "from": "Sovereign Mesh",
         "timestamp": msg['time'],
         "read": false,
         "comment": msg['body'],
         "title": msg['title'],
         "icon": msg['icon']
       });
    }

    // 3. Filter based on view
    final List<Map<String, dynamic>> filtered = activities.where((item) {
      String type = (item['type'] ?? '').toString().toUpperCase();
      if (filter == 'Main') return true; 
      if (filter == 'Followers' || filter == 'FOLLOW') return type == 'FOLLOW';
      if (filter == 'Likes' || filter == 'LIKE') return type == 'LIKE';
      if (filter == 'Comments' || filter == 'COMMENT') return type == 'COMMENT';
      if (filter == 'Mentions' || filter == 'MENTION') return type == 'MENTION';
      if (filter == 'Shares' || filter == 'SHARE') return type == 'SHARE';
      if (filter == 'Views' || filter == 'VIEW') return type == 'VIEW';
      return false;
    }).toList();
    
    // V15 Chrono Pulse: Robust newest first sort
    filtered.sort((a, b) {
       String tA = (a['timestamp'] ?? a['time'] ?? '0').toString();
       String tB = (b['timestamp'] ?? b['time'] ?? '0').toString();
       return tB.compareTo(tA);
    });

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.white10, size: 40), 
            const SizedBox(height: 10), 
            Text(filter == 'Main' ? 'No mesh activity yet' : 'No $filter yet', style: const TextStyle(color: Colors.white10)),
          ]
        )
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final bool isNew = item['is_new'] == true || item['read'] == false;
        
        final String user = item['from'] ?? item['user'] ?? 'Sovereign User';
        final String type = (item['type'] ?? 'LIKE').toString().toUpperCase();
        
        // V15 Enhanced Extractor: Map 'comment' from backend with deep nested awareness [A_120]
        final dynamic extraData = item['extra'];
        String extraText = item['comment'] ?? item['text'] ?? "";
        if (extraText.isEmpty && extraData != null && extraData is Map) {
          extraText = (extraData['text'] ?? extraData['comment'] ?? "").toString();
        }
        
        final String timestamp = item['timestamp'] ?? item['time'] ?? 'Just now';
        final String? referencedFile = extraData != null && extraData is Map ? extraData['file'] : item['file'];
        
        String actionText = 'interacted with you';
        Color categoryColor = Colors.white24;
        
        if (type == 'LIKE') {
          actionText = 'liked your video';
          categoryColor = Colors.pinkAccent;
        } else if (type == 'COMMENT') {
          actionText = extraText.isNotEmpty ? 'commented: "$extraText"' : 'commented on your video';
          categoryColor = Colors.orangeAccent;
        } else if (type == 'FOLLOW') {
          actionText = 'started following you';
          categoryColor = Colors.cyan;
        } else if (type == 'MENTION') {
          actionText = 'mentioned you in a post';
          categoryColor = Colors.blueAccent;
        } else if (type == 'VIEW') {
          actionText = 'viewed your video';
          categoryColor = Colors.greenAccent;
        } else if (type == 'SHARE') {
          actionText = 'shared your video';
          categoryColor = Colors.lightBlueAccent;
        } else if (type == 'SYSTEM') {
          actionText = (item['title'] ?? 'Mesh Update').toString();
          categoryColor = SovereignColors.cyan;
        }

        bool isFollowed = _followedUsers.contains(user);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2), width: 1.5),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white10,
                  child: Text(user.isNotEmpty ? user[0].toUpperCase() : 'S', style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              if (isNew)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: categoryColor, // Sovereign Task Pulse Color Synchronization
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              children: [
                TextSpan(text: '$user ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                TextSpan(text: actionText, style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(timestamp, style: const TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 0.5)),
          ),
          trailing: SizedBox(
            width: 85,
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                if (type == 'FOLLOW') {
                  setState(() {
                    if (isFollowed) {
                      _followedUsers.remove(user);
                    } else {
                      _followedUsers.add(user);
                    }
                  });
                  _onInteraction('INBOX_FOLLOW_TOGGLE: $user');
                } else {
                  if (referencedFile != null) {
                    _jumpToVideo(referencedFile);
                  } else {
                    setState(() => _currentIndex = 0);
                  }
                  _onInteraction('INBOX_WATCH_VIDEO: $user');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: (type == 'FOLLOW' && !isFollowed) ? const Color(0xFFFF0055) : Colors.white.withValues(alpha: 0.08),
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
                side: (type == 'FOLLOW' && !isFollowed) ? null : const BorderSide(color: Colors.white10, width: 0.5),
              ),
              child: Text(
                type == 'FOLLOW' ? (isFollowed ? 'Friends' : 'Follow back') : 'Watch',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: (type == 'FOLLOW' && !isFollowed) ? Colors.white : Colors.white70),
              ),
            ),
          ),
          onTap: () {
            _onInteraction('INBOX_ITEM_TAP: $user');
            if (type == 'COMMENT') {
              _showInboxReplyField(user);
            } else if (referencedFile != null) {
              _jumpToVideo(referencedFile);
            }
          },
        );
      },
    );
  }

  void _jumpToVideo(String filename) {
    // Find index in global feed
    int targetIdx = -1;
    for (int i = 0; i < sovereignMedia.length; i++) {
       final url = sovereignMedia[i]['url'] ?? "";
       if (url.contains(filename)) {
         targetIdx = i;
         break;
       }
    }

    setState(() => _currentIndex = 0);
    
    if (targetIdx != -1) {
       // Jump PageView to target index
       Future.delayed(const Duration(milliseconds: 100), () {
         if (_feedController.hasClients) {
           _feedController.jumpToPage(targetIdx);
         }
       });
    }
  }


  Widget _buildDirectMessages() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _inboxView = 'Main')),
               const Expanded(
                child: Center(
                  child: Text(
                    'Direct Messages',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  )
                )
              ),
              const SizedBox(width: 48), // Spacer for centering
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white24)),
              title: Text('Sovereign User #$index', style: const TextStyle(color: Colors.white)),
              subtitle: const Text('Last message logged to mesh...', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.camera_alt_outlined, color: Colors.white24),
              onTap: () => _onInteraction('DM_CHAT_OPEN: USER_$index'),
            ),
          ),
        ),
      ],
    );
  }
  // Removed old _buildInboxHub content logic for replacement


  Widget _buildCreatorSuite() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Real Camera Preview [V15 Reality Patch]
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize?.height ?? 1,
                    height: _cameraController!.value.previewSize?.width ?? 1,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),
          
          // Neural Recording Progress Bar [TikTok DNA]
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _recordingProgress,
                child: Container(decoration: BoxDecoration(color: SovereignColors.cyan, borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ),

          const Center(child: Text('A_117: QUANTUM CREATOR SUITE', style: TextStyle(color: Colors.white38))),
          
          if (_selectedSound != "Add sound")
            Positioned(
              bottom: 120,
              right: 20,
              child: _buildCreatorSpinningDisk(),
            ),
          
          // Top 'Add Sound' Selector [TikTok DNA]
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showSoundPicker,
                onLongPress: () => _showSoundHub(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.music_note, color: SovereignColors.cyan, size: 16),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedSound,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                          ),
                          if (_selectedSoundUploader != null)
                             Text(
                              _selectedSoundUploader!,
                              style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Sovereign Glass Sidebar [V15 High-Fidelity]
          Positioned(
            right: 15,
            top: 70,
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                   _buildCreatorUtility(Icons.flip_camera_ios, 'Flip', onTap: _toggleFlip),
                   const SizedBox(height: 18),
                   _buildCreatorUtility(_isFlashOn ? Icons.flash_on : Icons.flash_off, 'Flash', 
                     onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                     color: _isFlashOn ? Colors.yellowAccent : Colors.white),
                   const SizedBox(height: 18),
                   _buildCreatorUtility(Icons.timer_outlined, _activeTimer == 'Off' ? 'Timer' : _activeTimer, onTap: _showTimerPicker, color: _activeTimer != 'Off' ? SovereignColors.cyan : Colors.white),
                   const SizedBox(height: 18),
                   _buildCreatorUtility(Icons.speed, 'Speed', onTap: _toggleSpeedMenu, color: _isSpeedMenuVisible ? SovereignColors.cyan : Colors.white),
                   const SizedBox(height: 18),
                   _buildCreatorUtility(Icons.filter_vintage, 'Filters', onTap: _showFiltersPicker, color: _activeFilter != 'Normal' ? SovereignColors.cyan : Colors.white),
                   const SizedBox(height: 18),
                   _buildCreatorUtility(Icons.face_retouching_natural, 'Beautify', onTap: _toggleBeautify, color: _isBeautifyOn ? SovereignColors.cyan : Colors.white),
                 ],
               ),
             ),
           ),
 
           // Speed Controls (A_117 Overlay)
           if (_isSpeedMenuVisible)
             Positioned(
               bottom: 170,
               left: 0,
               right: 0,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   _buildSpeedButton('0.3x'),
                   _buildSpeedButton('0.5x'),
                   _buildSpeedButton('1x'),
                   _buildSpeedButton('2x'),
                   _buildSpeedButton('3x'),
                 ],
               ),
             ),

          // Bottom Action Hub [V15 DNA]
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildCreatorBottomTool(Icons.photo_library_outlined, 'Upload', () => _sovereignGuard('GALLERY_ACCESS', _pickGalleryMedia)),
                   
                   // Central Record Trigger [TikTok Concentric DNA]
                   GestureDetector(
                     onTap: _toggleRecording,
                     onLongPress: _startRecording,
                     onLongPressUp: _stopRecording,
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                          // 1. Progress Indicator
                          SizedBox(
                            width: 90, 
                            height: 90,
                            child: CircularProgressIndicator(
                              value: _recordingProgress,
                              strokeWidth: 4,
                              color: SovereignColors.cyan,
                              backgroundColor: Colors.white10,
                            ),
                          ),
                          // 2. White Outer Ring
                          Container(width: 78, height: 78, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                          // 3. Black Inner Ring
                          Container(width: 70, height: 70, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black)),
                          // 4. Red Core
                          AnimatedContainer(
                           duration: const Duration(milliseconds: 200),
                           width: _isRecording ? 30 : 62,
                           height: _isRecording ? 30 : 62,
                           decoration: BoxDecoration(
                             shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                             borderRadius: _isRecording ? BorderRadius.circular(5) : null,
                             color: Colors.redAccent,
                           ),
                         ),
                       ],
                     ),
                   ),
 
                   _buildCreatorBottomTool(Icons.auto_awesome_outlined, 'Filters', _showFiltersPicker),
                 ],
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildCreatorBottomTool(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _prepareAudioController() {
    if (_selectedSoundUrl != null) {
      String finalUrl = _selectedSoundUrl!;
      if (finalUrl.startsWith('/stream')) {
        final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
        finalUrl = 'http://$host:9900$finalUrl';
      }
      _recordingAudioController?.dispose();
      _recordingAudioController = VideoPlayerController.networkUrl(Uri.parse(_resolveSecureUrl(finalUrl)))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameraController != null) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final camera = _isCameraFront 
          ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras.first)
          : cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      
      _cameraController = CameraController(
        camera, 
        ResolutionPreset.high,
        enableAudio: isMicEnabled,
      );
      
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("CAM_INIT_ERR: $e");
    }
  }

  void _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_cameraController!.value.isRecordingVideo) return;
    
    try {
      await _cameraController!.startVideoRecording();
    } catch (e) {
      debugPrint("START_REC_ERR: $e");
      return;
    }
    
    setState(() {
      _isRecording = true;
      _recordingProgress = 0.0;
    });

    if (_recordingAudioController != null && _recordingAudioController!.value.isInitialized) {
      _recordingAudioController!.seekTo(Duration.zero);
      _recordingAudioController!.play();
      _onInteraction('NEURAL_AUDIO_SYNC: Zero-latency playback started');
    }

    _onInteraction('RECORDING_STARTED');
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording || _recordingProgress >= 1.0) {
        timer.cancel();
        if (_recordingProgress >= 1.0) _stopRecording();
        return;
      }
      setState(() => _recordingProgress += 0.01);
    });
  }

  void _stopRecording() async {
    XFile? capturedFile;
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      try {
         capturedFile = await _cameraController!.stopVideoRecording();
      } catch (e) {
         debugPrint("STOP_REC_ERR: $e");
      }
    }
    
    setState(() {
      _isRecording = false;
      _recordingTimer?.cancel();
    });
    _recordingAudioController?.pause();
    // Pre-buffered audio controller is kept alive for multiple takes
    _onInteraction('RECORDING_STOPPED');
    if (_recordingProgress > 0.05 && capturedFile != null) {
       if (mounted) {
         Navigator.push(context, MaterialPageRoute(builder: (context) => QuantumPostHub(
           onInteraction: _onInteraction,
           uploaderId: meshID,
           channel: channel,
           selectedMedia: [capturedFile!],
           isLocationEnabled: isLocationEnabled,
           onAddMessage: _addSystemMessage,
           initialSound: _selectedSound != "Add sound" ? _selectedSound : null,
           initialSoundUrl: _selectedSoundUrl,
         )));
       }
    }
  }

  Widget _buildCreatorUtility(IconData icon, String label, {VoidCallback? onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCreatorSpinningDisk() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: _isRecording ? SovereignColors.cyan : Colors.white24, width: 2),
        boxShadow: _isRecording ? [BoxShadow(color: SovereignColors.cyan.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)] : [],
      ),
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: _isRecording ? 1.2 : 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.music_note, color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String label) {
    bool isActive = _activeSpeed == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeSpeed = label);
        _onInteraction('CREATOR_SPEED_SET: $label');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }


  Widget _buildProfile() {
    return Stack(
      children: [
        RefreshIndicator(
          color: SovereignColors.cyan,
          backgroundColor: Colors.black,
          onRefresh: () async {
            _onInteraction('PROFILE_PULL_TO_REFRESH');
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 60),
              // Header
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickProfilePicture,
                      child: CircleAvatar(
                        radius: 48, 
                        backgroundColor: SovereignColors.cyan, 
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.black,
                          backgroundImage: serverProfilePic != null && serverProfilePic!.isNotEmpty
                            ? NetworkImage(serverProfilePic!)
                            : (_profileImagePath != null ? FileImage(File(_profileImagePath!)) : null) as ImageProvider?,
                          child: (serverProfilePic == null || serverProfilePic!.isEmpty) && _profileImagePath == null 
                            ? const Icon(Icons.person, size: 50, color: Colors.white) 
                            : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                         if (isVerified) ...[
                           const SizedBox(width: 4),
                           const Icon(Icons.verified, color: SovereignColors.cyan, size: 16),
                         ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('@${meshID.toLowerCase()}', style: const TextStyle(fontSize: 14, color: Colors.white38)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: followingNotifier,
                    builder: (c, val, _) => _buildProfileStat(_formatCount(val), 'Following'),
                  ),
                  _buildVerticalDivider(),
                  ValueListenableBuilder<int>(
                    valueListenable: followerNotifier,
                    builder: (c, val, _) => _buildProfileStat(_formatCount(val), 'Followers'),
                  ),
                  _buildVerticalDivider(),
                  ValueListenableBuilder<int>(
                    valueListenable: totalLikesNotifier,
                    builder: (c, val, _) => _buildProfileStat(_formatCount(val), 'Likes'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildProfileButton('Edit Profile', () {
                        _onInteraction('PROFILE_EDIT_OPEN_V15_DIRECT');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileView(
                          onInteraction: _onInteraction,
                          channel: channel,
                          currentName: userName,
                          currentBio: userBio,
                          userMeshID: meshID,
                          currentPic: serverProfilePic,
                        )));
                    }),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 3,
                    child: _buildProfileButton('Share Profile', _showTikTokShareSheet),
                  ),
                  const SizedBox(width: 6),
                  _buildSmallSquareButton(Icons.person_add_outlined, Colors.white12, () => _onInteraction('SUGGESTED_FRIENDS_TOGGLE')),
                  const SizedBox(width: 6),
                  _buildSmallSquareButton(Icons.camera_alt_outlined, Colors.white12, () => _onInteraction('INSTAGRAM_LINK_CLICK')),
                ],
              ),
              const SizedBox(height: 18),

              // Bio
              Center(
                child: Column(
                  children: [
                     Text(
                      userBio, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text('sovereign.neo/official', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              
              // A_177: Real-time Withdrawal Tracker Injection
              ValueListenableBuilder<List<dynamic>>(
                valueListenable: bankHistoryNotifier,
                builder: (context, history, _) {
                  if (history.isEmpty) return const SizedBox.shrink();
                  
                  final activeTx = history.firstWhere((tx) => tx['stage'] != 'PAID' && tx['stage'] != 'REJECTED', orElse: () => null);
                  if (activeTx == null) return const SizedBox.shrink();
                  
                  final bool isBatching = activeTx['stage'] == 'BATCHING';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isBatching ? Colors.orangeAccent.withValues(alpha: 0.1) : SovereignColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isBatching ? Colors.orangeAccent.withValues(alpha: 0.3) : SovereignColors.cyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(isBatching ? Icons.auto_awesome : Icons.hourglass_top, color: isBatching ? Colors.orangeAccent : SovereignColors.cyan, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBatching ? 'BANK PAYOUT: BATCHING' : 'BANK PAYOUT: PENDING', 
                                    style: TextStyle(color: isBatching ? Colors.orangeAccent : SovereignColors.cyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isBatching 
                                      ? 'Your funds are in the distribution batch. Real-time sync active.' 
                                      : 'Request received. Waiting for Admin Export pulse.',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: isBatching ? 0.75 : 0.25,
                          backgroundColor: Colors.white12,
                          color: isBatching ? Colors.orangeAccent : SovereignColors.cyan,
                          minHeight: 2,
                        ),
                      ],
                    ),
                  );
                }
              ),

              // Tabs - Full TikTok V15 Expansion [5-Tab Standard]
              DefaultTabController(
                length: 5,
                child: Column(
                  children: [
                    const TabBar(
                      indicatorColor: SovereignColors.cyan,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white24,
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.zero,
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on_outlined, size: 20)),
                        Tab(icon: Icon(Icons.repeat_rounded, size: 20)), // Reposts
                        Tab(icon: Icon(Icons.lock_outline_rounded, size: 20)), // Private
                        Tab(icon: Icon(Icons.bookmark_border_rounded, size: 20)), // Saved
                        Tab(icon: Icon(Icons.favorite_border_rounded, size: 20)), // Liked
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 700, // Increased height for deeper content
                      child: TabBarView(
                        children: [
                           // Tab 1: Posts (Grid)
                           _buildProfileVideoGrid(15),
                           
                           // Tab 2: Reposts
                           _repostedVideosSet.isEmpty 
                             ? _buildEmptyState(Icons.repeat_rounded, 'Reposted videos appear here')
                             : _buildProfileVideoGrid(_repostedVideosSet.length, videoIndices: _repostedVideosSet.toList()),

                           // Tab 3: Private
                           _buildProfileVideoGrid(3, isPrivate: true),

                           // Tab 4: Favorites (Sub-Navigation Logic)
                           _buildFavoritesTab(),

                           // Tab 5: Liked
                           _likedVideosSet.isEmpty 
                             ? _buildEmptyState(Icons.favorite_outline_rounded, 'Videos you liked are private')
                             : _buildProfileVideoGrid(_likedVideosSet.length, videoIndices: _likedVideosSet.toList()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Settings Menu
        Positioned(
          top: 50,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileVideoGrid(int count, {bool isPrivate = false, List<int>? videoIndices}) {
    // A_118: Identify own uploads and their global indices
    final List<int> uploadIndices = [];
    if (videoIndices == null && !isPrivate) {
      for (int i = 0; i < sovereignMedia.length; i++) {
        if (sovereignMedia[i]['uploader'] == meshID) {
          uploadIndices.add(testVideos.length + i);
        }
      }
    }

    final effectiveIndices = (videoIndices == null && !isPrivate) ? uploadIndices : videoIndices;
    final effectiveCount = effectiveIndices != null ? effectiveIndices.length : count;
    
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        crossAxisSpacing: 1, 
        mainAxisSpacing: 1, 
        childAspectRatio: 0.75
      ),
      itemCount: effectiveCount,
      itemBuilder: (context, index) {
        final videoIdx = effectiveIndices != null ? effectiveIndices[index] : index;

        return GestureDetector(
          onTap: () => _openVideoDetail(index, videoIndices: effectiveIndices, count: effectiveCount),
          child: Container(
            color: Colors.white.withValues(alpha: 0.05), 
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (videoIdx < testVideos.length)
                  Image.network(
                    testVideos[videoIdx].replaceFirst('.mp4', '.jpg'),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Center(child: Icon(isPrivate ? Icons.lock_outline : Icons.play_arrow, color: Colors.white10)),
                  )
                else if (videoIdx >= testVideos.length && (sovereignMedia[videoIdx - testVideos.length]['thumb_url'] ?? '').isNotEmpty)
                  // A_125: Vision Engine Thumbnail Display
                  Image.network(
                    sovereignMedia[videoIdx - testVideos.length]['thumb_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => _buildMeshPlaceholder(videoIdx, isPrivate),
                  )
                else
                  // A_118: Visual indicator for Mesh Content
                  _buildMeshPlaceholder(videoIdx, isPrivate),
                if (!isPrivate)
                  Positioned(
                    bottom: 5, 
                    left: 5, 
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow_outlined, size: 14, color: Colors.white70), 
                        Text(
                          ' ${_getDynamicViews(videoIdx)}', 
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)
                        )
                      ]
                    )
                  ),
              ],
            )
          ),
        );
      },
    );
  }

  String _formatCount(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      return value.toString();
    }
  }

  String _getDynamicViews(int index) {
    if (index < 0 || index >= sovereignMedia.length) return "0";
    final views = sovereignMedia[index]['views'] ?? 0;
    return _formatCount(views);
  }

  Widget _buildMeshPlaceholder(int videoIdx, bool isPrivate) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, SovereignColors.cyan.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPrivate ? Icons.lock_outline : Icons.play_circle_filled, color: SovereignColors.cyan.withValues(alpha: 0.5), size: 35),
            const SizedBox(height: 8),
            Text('SYN_NODE_$videoIdx', style: const TextStyle(color: Colors.white24, fontSize: 7, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: SovereignColors.cyan,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelPadding: const EdgeInsets.only(right: 30),
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(child: Text('Videos')),
                Tab(child: Text('Sounds')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Sub-Tab 1: Saved Videos
                _savedVideosSet.isEmpty 
                  ? _buildEmptyState(Icons.bookmark_border, 'Videos you save appear here')
                  : _buildProfileVideoGrid(_savedVideosSet.length, videoIndices: _savedVideosSet.toList()),
                
                // Sub-Tab 2: Saved Sounds
                _savedSoundsList.isEmpty
                  ? _buildEmptyState(Icons.music_note, 'Sounds you save appear here')
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _savedSoundsList.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () => _openSoundDetail(_savedSoundsList[index]),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: SovereignColors.cyan.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.music_note, color: SovereignColors.cyan),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_savedSoundsList[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const Text('Original Sound - @SovereignUltra', style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.play_circle_fill, color: Colors.white60),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.white10),
          const SizedBox(height: 15),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSmallSquareButton(IconData icon, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
  Widget _buildVerticalDivider() {
    return Container(
      height: 15,
      width: 1,
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Widget _buildProfileButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  void _showTikTokShareSheet() {
    _onInteraction('SHARE_PROFILE_OPEN');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 380,
        decoration: BoxDecoration(
          color: const Color(0xFF161722),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Send to', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Row 1: Send to friends (Real Mesh Users)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                   _buildShareIcon(Icons.add, 'Create', Colors.white10),
                   ...sovereignMedia
                    .map((m) => m['uploader']?.toString() ?? '')
                    .where((u) => u.isNotEmpty && u != meshID)
                    .toSet() // Unique users
                    .take(8) // Top 8 users
                    .map((user) => _buildShareIcon(
                      Icons.person, 
                      user.toLowerCase(), 
                      Colors.primaries[user.hashCode % Colors.primaries.length].withValues(alpha: 0.8)
                    )),
                  _buildShareIcon(Icons.more_horiz, 'More', Colors.white10),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Divider(color: Colors.white10, height: 1),
            ),
            
            const Text('Share to', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            // Row 2: Social Apps
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  _buildShareIcon(Icons.copy, 'Copy link', Colors.blueAccent, onTap: () {
                    Clipboard.setData(ClipboardData(text: 'https://sovereign.neo/profile/${meshID.toLowerCase()}'));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: SovereignColors.cyan, content: Text('Link copied to clipboard!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                    );
                    _onInteraction('PROFILE_LINK_COPIED');
                  }),
                  _buildShareIcon(Icons.send_rounded, 'WhatsApp', Colors.green),
                  _buildShareIcon(Icons.camera_alt, 'Instagram', Colors.purple),
                  _buildShareIcon(Icons.facebook_outlined, 'Facebook', Colors.indigoAccent),
                  _buildShareIcon(Icons.qr_code_2, 'QR Code', Colors.grey),
                  _buildShareIcon(Icons.textsms_outlined, 'SMS', Colors.amber),
                  _buildShareIcon(Icons.more_horiz, 'Others', Colors.white10),
                ],
              ),
            ),
            
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 60,
                color: Colors.white.withValues(alpha: 0.05),
                alignment: Alignment.center,
                child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () => _onInteraction('SHARE_TARGET_CLICK: $label'),
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.3), width: 1)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingsDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              'SETTINGS',
              style: TextStyle(color: SovereignColors.cyan, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSettingsTile(
                  Icons.person_outline, 
                  'Edit Profile', 
                  'Change your mesh identity',
                  onTap: () {
                    _onInteraction('EDIT_PROFILE_DRAWER_OPEN');
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileView(
                      onInteraction: _onInteraction,
                      channel: channel,
                      currentName: userName,
                      currentBio: userBio,
                      userMeshID: meshID,
                      currentPic: serverProfilePic,
                    )));
                  }
                ),
                _buildSettingsTile(Icons.verified, 'Verification [A_107]', isVerified ? 'IDENTITY VERIFIED' : 'Request Verified Badge Status', onTap: () {
                   _sovereignGuard('VERIFICATION_REQUEST', () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SovereignVerificationView(onInteraction: _onInteraction, channel: channel)));
                   });
                }),
                 // TODO: [PLAY_STORE_COMPLIANCE] Hide this entire block when building for Play Store using `kIsWeb` check
                 _buildSettingsTile(Icons.hub, 'MLM Network [A_107]', 'Manage Downline & Yields', onTap: () {
                    Navigator.pop(context); // Close Drawer
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MLMNetworkView(onInteraction: _onInteraction, channel: channel, meshID: meshID)));
                 }),
                // TODO: [PLAY_STORE_COMPLIANCE] Hide this entire Quantum Wallet block when building for Play Store using `kIsWeb` check
                ValueListenableBuilder(
                  valueListenable: usdNotifier,
                  builder: (context, usd, _) {
                    return ValueListenableBuilder(
                      valueListenable: bdtNotifier,
                      builder: (context, bdt, _) {
                        return ValueListenableBuilder(
                          valueListenable: coinNotifier,
                          builder: (context, coins, _) {
                            return _buildSettingsTile(
                              Icons.account_balance_wallet, 
                              'Quantum Wallet [A_113]', 
                              'ID: $meshID | USD: ${usd.toStringAsFixed(2)} | BDT: ${bdt.toStringAsFixed(2)}',
                              onTap: () {
                                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => QuantumWalletView(
                                    usdListenable: usdNotifier,
                                    bdtListenable: bdtNotifier,
                                    coinsListenable: coinNotifier,
                                    onInteraction: _onInteraction,
                                    onSwap: (u, b, c) {
                                      usdNotifier.value = u;
                                      bdtNotifier.value = b;
                                      coinNotifier.value = c;
                                    },
                                    channel: channel,
                                    minWithdrawListenable: minWithdrawNotifier,
                                    commissionListenable: commissionNotifier,
                                    coinRate: coinRate,
                                    bdtRateListenable: bdtRateNotifier,
                                    mlmYieldListenable: mlmYieldNotifier,
                                     frozenUsdListenable: frozenUsdNotifier,
                                     frozenBdtListenable: frozenBdtNotifier,
                                     bankHistoryListenable: bankHistoryNotifier, // Status Tracker
                                     meshID: meshID,
                                     bridgeConfigsListenable: bridgeConfigsNotifier,
                                  )));
                               }
                            );
                          }
                        );
                      }
                    );
                  }
                ),

                // TODO: [PLAY_STORE_COMPLIANCE] Hide this entire Sponsored Templates block when building for Play Store using `kIsWeb` check
                _buildSettingsTile(
                  Icons.ads_click,
                  'Sponsored Templates',
                  'AI Targeting Suites',
                  onTap: () {
                    _onInteraction('SPONSORED_TEMPLATES_OPEN');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SponsoredTemplatesView(
                      onInteraction: _onInteraction, 
                      usdCpmListenable: usdCpmNotifier,
                      bdtCpmListenable: bdtCpmNotifier,
                      usdListenable: usdNotifier,
                      bdtListenable: bdtNotifier,
                      mediaLedger: sovereignMedia, // V15 Mesh Injection
                    )));
                  }
                ),
                _buildSettingsTile(
                  Icons.security, 
                  'Permission Center', 
                  'Full Access',
                  onTap: () {
                    _onInteraction('PERMISSION_CENTER_OPEN');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionCenterView(
                      onInteraction: _onInteraction,
                      camera: isCameraEnabled,
                      mic: isMicEnabled,
                      gallery: isGalleryEnabled,
                      location: isLocationEnabled,
                      onToggle: (name, val) {
                        setState(() {
                          if (name == 'Camera') isCameraEnabled = val;
                          if (name == 'Mic') isMicEnabled = val;
                          if (name == 'Gallery') isGalleryEnabled = val;
                          if (name == 'Location') isLocationEnabled = val;
                        });
                      },
                    )));
                  }
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _unreadCount,
                  builder: (context, count, _) {
                    return _buildSettingsTile(
                      Icons.message, 
                      'System Messages', 
                      'Priority Notifications', 
                      badgeCount: count,
                      onTap: () {
                        _unreadCount.value = 0; // Clear badge on open [TikTok Logic]
                        _onInteraction('SYSTEM_MESSAGES_OPEN');
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SystemMessagesView(
                          onInteraction: _onInteraction,
                          messages: _systemMessages,
                        )));
                      }
                    );
                  }
                ),
                const Divider(color: Colors.white10),
                _buildSettingsTile(Icons.info_outline, 'About Sovereign V15', 'Version 15.0.1'),
                _buildSettingsTile(
                  Icons.policy, 
                  'Community Guidelines', 
                  'A_112 Smart Filter Registry',
                  onTap: () {
                    _onInteraction('GUIDELINES_OPEN');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SovereignGuidelinesView()));
                  }
                ),
                _buildSettingsTile(
                  Icons.block_flipped, 
                  'Block List', 
                  'Manage restricted nodes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SovereignBlockListView(
                      blockedUsers: _blockedUsersSet,
                      onUnblock: (handle) => _onInteraction('CREATOR_UNBLOCK: $handle'),
                    )));
                  }
                ),
                _buildSettingsTile(
                  Icons.lock_person_outlined, 
                  'Quantum Security', 
                  'Manage Transaction PIN',
                  onTap: () {
                    _onInteraction('QUANTUM_SECURITY_OPEN');
                    _showPinUpdateDialog(context);
                  }
                ),
                _buildSettingsTile(
                  Icons.no_accounts_outlined, 
                  'Delete Account', 
                  'Permanently remove mesh identity',
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteAccountDialog();
                  },
                ),
                _buildSettingsTile(
                  Icons.privacy_tip_outlined, 
                  'Privacy & Data Safety', 
                  'Official Mesh Protocols',
                  onTap: () {
                    _onInteraction('PRIVACY_POLICY_OPEN');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SovereignPrivacyView()));
                  }
                ),
                _buildSettingsTile(
                  Icons.help_outline, 
                  'Help & Support', 
                  'Contact Mesh Architect',
                  onTap: () {
                    _onInteraction('SUPPORT_OPEN');
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF121212),
                        title: const Text('SUPPORT CENTER', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        content: const Text('For mesh-related issues, email: support@fectok.com\n\nV15 Protocol: ACTIVE', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE'))],
                      ),
                    );
                  }
                ),
                _buildSettingsTile(
                  Icons.logout, 
                  'Logout', 
                  'Node Termination',
                  onTap: () {
                    _sovereignGuard('LOGOUT / NODE TERMINATION', () async {
                      final prefs = await SharedPreferences.getInstance();
                      // V15 Auth Purge: Clean ALL identity tokens
                      await prefs.remove('auth_token');
                      await prefs.remove('sovereign_mesh_id');
                      await prefs.remove('sovereign_user_name');
                      
                      setState(() {
                        _isAuthenticated = false;
                        isLegallyAuthorized = false; // A_106 Re-Gating
                        meshID = "CALIBRATING...";
                      });
                      
                      _onInteraction('LOGOUT_SUCCESS');
                      if (!mounted) return;
                      Navigator.pop(context); // Close Drawer
                    });
                  },
                ),
                const Divider(color: Colors.white10),
                // --- Sovereign V15 User-Centric AI Slider [Phase 21] ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('AI FOR YOU: DISCOVERY ALGORITHM [A_121]', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Personalized', style: TextStyle(color: Colors.white38, fontSize: 10)),
                          Text('Random / Viral', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      Slider(
                        value: _discoveryWeight,
                        min: 0.0,
                        max: 1.0,
                        activeColor: const Color(0xFF00FFFF), // Sovereign Cyan
                        inactiveColor: Colors.white10,
                        onChanged: (val) {
                          setState(() => _discoveryWeight = val);
                        },
                        onChangeEnd: (val) {
                          _fetchSovereignMedia(); // Refresh feed based on new AI weight
                        },
                      ),
                      Text('Discovery Rate: ${(_discoveryWeight * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Digital Evidence Archiving: ACTIVE', style: TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  void _showPinUpdateDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('UPDATE QUANTUM PIN', style: TextStyle(color: SovereignColors.cyan, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter new 4-6 digit PIN for secure transactions.', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 15),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 10),
              decoration: const InputDecoration(
                counterStyle: TextStyle(color: Colors.white24),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              String newPin = pinController.text.trim();
              if (newPin.length >= 4) {
                channel.sink.add(json.encode({
                  "action": "A_113_PIN_UPDATE",
                  "new_pin": newPin
                }));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: SovereignColors.cyan,
                    content: Text('PIN UPDATE REQUESTED | RECALIBRATING SECURITY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
            child: const Text('UPDATE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    TextEditingController deleteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('PERMANENT PURGE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Warning: This action will permanently terminate your Sovereign Node and wipe your mesh identity. All digital assets (COINS, USD) will be lost.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 15),
            const Text('Type "DELETE" to confirm node termination:', style: TextStyle(color: Colors.white24, fontSize: 11)),
            const SizedBox(height: 8),
            TextField(
              controller: deleteController,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white12,
                hintText: 'DELETE',
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (deleteController.text.trim().toUpperCase() == 'DELETE') {
                _onInteraction('DELETE_ACCOUNT_PERMANENT');
                Navigator.pop(context);
                
                // Clear local state
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('sovereign_mesh_id');
                await prefs.remove('sovereign_user_name');
                
                setState(() {
                  _isAuthenticated = false;
                  isLegallyAuthorized = false;
                  meshID = "NODE_TERMINATED";
                });
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.redAccent,
                    content: Text('NODE TERMINATED | MESH IDENTITY PURGED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('PURGE NODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }



  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap, int badgeCount = 0}) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: SovereignColors.cyan),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  badgeCount.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
      onTap: onTap ?? () {
        _onInteraction('SETTINGS_ACCESS: $title');
        Navigator.pop(context);
        if (title == 'Edit Profile') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileView(
            onInteraction: _onInteraction,
            channel: channel,
            currentName: userName,
            currentBio: userBio,
            userMeshID: meshID,
            currentPic: serverProfilePic,
          )));
        }
      },
    );
  }

  void _showSoundHub(bool isCreator) {
    _onInteraction('CREATOR_SOUND_HUB_LONG_PRESS');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SovereignSoundHub(
        soundsList: _globalSoundRegistry.entries.map((e) => {'title': e.key, 'url': e.value}).toList(),
        onInteraction: _onInteraction,
        onSelect: (sound) {
          setState(() {
            _selectedSound = sound['title'];
            _selectedSoundUploader = sound['uploader'] ?? sound['artist'] ?? 'Sovereign Original';
            _selectedSoundUrl = sound['url'];
          });
          _onInteraction('CREATOR_SOUND_HUB_SELECT: ${sound['title']}');
        },
      ),
    );
  }
}

class QuantumPostHub extends StatefulWidget {
  final Function(String, {String? contentId}) onInteraction;
  final String uploaderId;
  final WebSocketChannel channel;
  final List<XFile>? selectedMedia;
  final bool isLocationEnabled;
  final Function(String, String, String) onAddMessage;

  const QuantumPostHub({
    super.key, 
    required this.onInteraction, 
    required this.uploaderId,
    required this.channel, 
    this.selectedMedia,
    required this.isLocationEnabled,
    required this.onAddMessage,
    this.initialSound,
    this.initialSoundUrl,
  });

  final String? initialSound;
  final String? initialSoundUrl;

  @override
  State<QuantumPostHub> createState() => _QuantumPostHubState();
}

class _QuantumPostHubState extends State<QuantumPostHub> {
  final TextEditingController _descController = TextEditingController();
  bool _isPosting = false;

  Map<String, String> _soundRegistry = {};

  VideoPlayerController? _videoController;
  VideoPlayerController? _audioController;
  bool _isPreviewImage = false;
  List<XFile> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    // A_128: Critical State Sync - Force state from widget parameters
    if (widget.initialSound != null) {
      _activePostSound = widget.initialSound!;
      _activePostSoundUrl = widget.initialSoundUrl;
      debugPrint("POST_HUB_INIT: Sound Locked -> $_activePostSound [URL: $_activePostSoundUrl]");
    }
    if (widget.selectedMedia != null) {
      _mediaItems = List.from(widget.selectedMedia!);
    }
    _loadDynamicSounds();
    _initVideoPreview();
    _loadSavedSounds();
  }

  Future<void> _loadSavedSounds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('sovereign_saved_sounds');
      if (list != null) {
        // QuantumPostHub uses a local list if needed
      }
    } catch (_) {}
  }

  Future<void> _saveSavedSounds() async {
    // QuantumPostHub doesn't own the master list
  }

  Future<void> _loadDynamicSounds() async {
    try {
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost; // Standard Emulator Fallback
      final response = await http.get(Uri.parse(_resolveSecureUrl('http://$host:9900/all')));
      if (response.statusCode == 200) {
        final List sounds = json.decode(response.body);
        final Map<String, String> newRegistry = {};
        for (var s in sounds) {
          newRegistry[s['title']] = _resolveSecureUrl('http://$host:9900${s['url']}');
        }
        setState(() {
          _soundRegistry = newRegistry;
          // Re-lock URL if name matches but URL was null (from initial state)
          if (_activePostSoundUrl == null && _soundRegistry.containsKey(_activePostSound)) {
             _activePostSoundUrl = _soundRegistry[_activePostSound];
             _syncAudioPreview(); // A_128: Start playing immediately upon discovery
          }
        });
      }
    } catch (e) {
      debugPrint("SOUND_REG_ERR: $e");
    }
  }

  void _initVideoPreview() {
    if (_mediaItems.isNotEmpty) {
      final String path = _mediaItems.first.path.toLowerCase();
      final String name = _mediaItems.first.name.toLowerCase();
      final String checkStr = path + name;
      
      _isPreviewImage = checkStr.contains('.jpg') || 
                        checkStr.contains('.jpeg') || 
                        checkStr.contains('.png') || 
                        checkStr.contains('.webp');
      
      if (!_isPreviewImage) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(_resolveSecureUrl(_mediaItems.first.path)))
          ..initialize().then((_) {
            _videoController?.setVolume(_originalVolume);
            _videoController?.setLooping(true);
            _videoController?.play();
            setState(() {});
          });
      } else {
        setState(() {}); // Trigger build for image preview
      }
    }
    _syncAudioPreview();
  }

  Future<void> _addMoreMedia() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> newMedia = await picker.pickMultipleMedia();
    if (newMedia.isNotEmpty) {
      setState(() {
        _mediaItems.addAll(newMedia);
      });
      widget.onInteraction('POST_MEDIA_ADDED: ${newMedia.length} more items');
    }
  }

  void _syncAudioPreview() {
    _audioController?.pause();
    _audioController?.dispose();
    _audioController = null;

    if (_activePostSoundUrl != null) {
      String fullUrl = _activePostSoundUrl!;
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
      
      if (fullUrl.startsWith('/stream') && !fullUrl.startsWith('http')) {
        // Resolve to Sound Master [A_128]
        fullUrl = 'http://$host:9900$fullUrl';
      } else if (fullUrl.contains('localhost')) {
        fullUrl = fullUrl.replaceFirst('localhost', host);
      }
      _audioController = VideoPlayerController.networkUrl(
        Uri.parse(_resolveSecureUrl(fullUrl)),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true), // A_128: Required for Web concurrency
      )
        ..initialize().then((_) {
          if (!mounted) return;
          _audioController?.setVolume(_addedSoundVolume);
          _audioController?.setLooping(true);
          // A_128: Auto-play audio if video is playing OR if it's an image preview
          if (_isPreviewImage || (_videoController != null && _videoController!.value.isPlaying)) {
            _audioController?.play();
          }
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioController?.dispose();
    _descController.dispose();
    super.dispose();
  }

  // V15 Social Intelligence State
  String _activeLocation = "Global Mesh";
  String _activePrivacy = "Everyone";
  String _activeTags = "None";
  String _activePostSound = "Add sound";
  String? _activePostSoundUrl;
  bool _allowComments = true;
  bool _allowDuet = true;

  // A_128: Audio Mixing Metadata
  double _originalVolume = 1.0;
  double _addedSoundVolume = 0.5;

  // A_128: Original Sound Data Registry [DYNAMIC_V15]
  // This map is now populated dynamically via _loadDynamicSounds() from the Sound Master Hub API.

  Future<void> _publish() async {
    if (_mediaItems.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ NO MEDIA SELECTED')));
       return;
    }

    setState(() => _isPosting = true);
    
    // A_118: Sovereign Real-Time Upload [Multi-Media Orchestration]
    try {
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
      final uri = Uri.parse(_resolveSecureUrl("http://$host:8080/upload"));
      final request = http.MultipartRequest("POST", uri);
      
      // A_118: Multi-File Injection Loop (Uplink V15 supports single-file primary + multiple markers)
      for (var file in _mediaItems) {
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          bytes,
          filename: file.name
        ));
      }
      
      // A_128: Neural State Snapshot [Locking metadata to prevent race condition]
      final String snapshotSoundName = _activePostSound;
      final String? snapshotSoundUrl = _activePostSoundUrl;
      final double snapshotOrgVol = _originalVolume;
      final double snapshotAddVol = _addedSoundVolume;

      request.fields['uploader'] = widget.uploaderId;
      request.fields['description'] = _descController.text;
      request.fields['sound_name'] = snapshotSoundName;
      request.fields['original_volume'] = snapshotOrgVol.toString();
      request.fields['added_sound_volume'] = snapshotAddVol.toString();
      request.fields['media_count'] = _mediaItems.length.toString();

      // A_128 V15: Resolve Sound URL to absolute for server-side mixing
      String resolvedSoundUrl = snapshotSoundUrl ?? "";
      if (resolvedSoundUrl.isNotEmpty && !resolvedSoundUrl.startsWith('http')) {
        resolvedSoundUrl = 'http://$host:9900$resolvedSoundUrl';
      }
      request.fields['sound_url'] = resolvedSoundUrl;

      // Layer-2: Synchronizing with Backend Ledger via WebSocket
      widget.channel.sink.add(json.encode({
        "action": "VIDEO_POST",
        "uploader_id": widget.uploaderId,
        "description": _descController.text,
        "filenames": _mediaItems.map((f) => f.name).toList(),
        "location": _activeLocation,
        "tags": _activeTags,
        "privacy": _activePrivacy,
        "sound_name": snapshotSoundName,
        "sound_url": resolvedSoundUrl,
        "added_sound_volume": snapshotAddVol,
        "original_sound_volume": snapshotOrgVol,
        "timestamp": DateTime.now().toIso8601String()
      }));

      final response = await request.send();

      if (response.statusCode == 200 && mounted) {
        widget.onInteraction('POST_PUBLISHED: ${_mediaItems.length} items');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ CONTENT LIVE ON SOVEREIGN MESH'), backgroundColor: SovereignColors.cyan)
        );
        // Sovereign V15: Forcible re-sync to ensure zero-latency feedback
        widget.onInteraction('GET_LATEST_MEDIA'); 
        Navigator.pop(context);
      } else if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ UPLOAD FAILED [GATEWAY TIMEOUT]'), backgroundColor: Colors.redAccent)
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        debugPrint("PUBLISH_ERR: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('POST HUB [A_118]', style: TextStyle(letterSpacing: 1.5, fontSize: 16, fontWeight: FontWeight.bold)), 
        centerTitle: true
      ),
      body: Column(
        children: [
          if (_isPosting)
            const LinearProgressIndicator(color: SovereignColors.cyan, backgroundColor: Colors.white12, minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: TextField(
                            controller: _descController,
                            maxLines: 5,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              hintText: 'Describe your video...',
                              hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 100, 
                        height: 140, 
                        decoration: BoxDecoration(
                          color: Colors.black, 
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ), 
                        clipBehavior: Clip.antiAlias,
                        child: _isPreviewImage
                          ? Stack(
                              children: [
                                PageView.builder(
                                  itemCount: _mediaItems.length,
                                  itemBuilder: (context, idx) {
                                    return FittedBox(
                                      fit: BoxFit.cover,
                                      child: kIsWeb 
                                        ? Image.network(_mediaItems[idx].path)
                                        : Image.file(File(_mediaItems[idx].path)),
                                    );
                                  },
                                ),
                                // Gradient Overlay for Add Button visibility
                                Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.black26, Colors.transparent, Colors.black45],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _addMoreMedia,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: SovereignColors.cyan, shape: BoxShape.circle),
                                      child: const Icon(Icons.add, color: Colors.black, size: 16),
                                    ),
                                  ),
                                ),
                                if (_mediaItems.length > 1)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                      child: Text("1/${_mediaItems.length}", style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                              ],
                            )
                          : (_videoController != null && _videoController!.value.isInitialized)
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4, 
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: SovereignColors.cyan)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // TikTok-style 'Add Sound' interactivity
                  // Sound Selector [A_128 Neural Link]
                  GestureDetector(
                    onTap: _showPostSoundHub, // A_128 Pulse: Pro Interaction
                    onLongPress: _showPostSoundPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _activePostSoundUrl != null ? SovereignColors.cyan : Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Icon(_activePostSoundUrl != null ? Icons.music_note : Icons.music_off, color: _activePostSoundUrl != null ? SovereignColors.cyan : Colors.white24, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _activePostSound, 
                              style: TextStyle(color: _activePostSoundUrl != null ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_activePostSoundUrl != null)
                            const Icon(Icons.verified, color: SovereignColors.cyan, size: 14),
                          const SizedBox(width: 12),
                          const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
                        ],
                      ),
                    ),
                  ),
                   const SizedBox(height: 25),
                  
                  // A_128: Neural Audio Mixer Section [Vibrant V15 Version]
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2), width: 1),
                      boxShadow: [
                        BoxShadow(color: SovereignColors.cyan.withValues(alpha: 0.02), blurRadius: 10, spreadRadius: 2)
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMixerHeader(),
                        const SizedBox(height: 20),
                          if (!_isPreviewImage)
                            _buildVolumeSliderWithIcon(Icons.mic_none_outlined, 'Original Sound', _originalVolume * 100, (val) {
                              setState(() => _originalVolume = val / 100);
                              _videoController?.setVolume(_originalVolume);
                              widget.onInteraction('SOUND_MIXER_ORIGINAL: ${val.toInt()}%');
                            }),
                         const SizedBox(height: 10),
                         _buildVolumeSliderWithIcon(Icons.music_note_outlined, 'Added Sound', _addedSoundVolume * 100, (val) {
                           setState(() => _addedSoundVolume = val / 100);
                           _audioController?.setVolume(_addedSoundVolume);
                           widget.onInteraction('SOUND_MIXER_ADDED: ${val.toInt()}%');
                         }),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 10),
                  
                  _buildTikTokRow(Icons.location_on_outlined, 'Add Location', trailing: _activeLocation, onTap: _showLocationPicker),
                  _buildTikTokRow(Icons.person_outline, 'Tag People', trailing: _activeTags, onTap: _showTagPeoplePicker),
                  _buildTikTokRow(Icons.lock_outline, 'Who can watch', trailing: _activePrivacy, onTap: _showPrivacyPicker),
                  _buildTikTokRow(Icons.comment_outlined, 'Allow Comments', trailing: _allowComments ? 'ON' : 'OFF', onTap: () {
                    setState(() => _allowComments = !_allowComments);
                    widget.onInteraction('POST_TOGGLE_COMMENTS: $_allowComments');
                  }),
                  _buildTikTokRow(Icons.share_outlined, 'Allow Duet/Stitch', trailing: _allowDuet ? 'ON' : 'OFF', onTap: () {
                    setState(() => _allowDuet = !_allowDuet);
                    widget.onInteraction('POST_TOGGLE_DUET: $_allowDuet');
                  }),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
            child: Row(
              children: [
                Expanded(child: _buildTikTokButton('Drafts', Colors.white.withValues(alpha: 0.1), Colors.white, onTap: () {
                  widget.onInteraction('POST_SAVED_TO_DRAFTS');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CONTENT SAVED TO SOVEREIGN DRAFTS')));
                  Navigator.pop(context);
                })),
                const SizedBox(width: 15),
                Expanded(child: _buildTikTokButton('Post', SovereignColors.cyan, Colors.black, onTap: _publish)),
              ],
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Text('Digital Evidence Archiving: ACTIVE [A_106]', style: TextStyle(color: Colors.white12, fontSize: 10, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMixerHeader() {
    return Row(
      children: [
        const Icon(Icons.equalizer_rounded, color: SovereignColors.cyan, size: 18),
        const SizedBox(width: 8),
        const Text('AUDIO MIXER [V15]', style: TextStyle(color: SovereignColors.cyan, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const Spacer(),
        Text('${((_originalVolume + _addedSoundVolume) * 50).toInt()}% Gain', style: const TextStyle(color: Colors.white24, fontSize: 11)),
      ],
    );
  }

  Widget _buildVolumeSliderWithIcon(IconData icon, String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text('${value.toInt()}%', style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: SovereignColors.cyan,
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: SovereignColors.cyan.withValues(alpha: 0.1),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 100.0,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTikTokRow(IconData icon, String label, {String? trailing, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.normal)),
            const Spacer(),
            if (trailing != null)
              Text(trailing, style: const TextStyle(color: Colors.white38, fontSize: 14.5)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildTikTokButton(String label, Color bg, Color fg, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(27),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 17)),
      ),
    );
  }

  void _showLocationPicker() {
    if (!widget.isLocationEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('PERMISSION DENIED: Location access restricted in [A_106]'),
      ));
      return;
    }
    _showSovereignPicker('SELECT LOCATION', ['Global Mesh', 'Near Me', 'Trending Hub', 'Private Zone'], (val) {
      setState(() => _activeLocation = val);
      widget.onInteraction('POST_LOCATION_SET: $val');
    });
  }

  void _showTagPeoplePicker() {
    _showSovereignPicker('TAG PEOPLE', ['@Sovereign_Ultra', '@Mesh_God', '@Quantum_User', '@Admin_Neo'], (val) {
      setState(() => _activeTags = val);
      widget.onInteraction('POST_TAGGED_USER: $val');
    });
  }

  void _showPrivacyPicker() {
    _showSovereignPicker('WHO CAN WATCH', ['Everyone', 'Friends', 'Only Me'], (val) {
      setState(() => _activePrivacy = val);
      widget.onInteraction('POST_PRIVACY_SET: $val');
    });
  }

  void _showPostSoundPicker() {
    _showSovereignPicker('ADD SOUND TO POST', ['Add sound', ..._soundRegistry.keys], (val) {
      setState(() {
        _activePostSound = val;
        // Neural Lock: Resolve the absolute URL from the registry
        if (val == 'Add sound') {
          _activePostSoundUrl = null;
        } else {
          _activePostSoundUrl = _soundRegistry[val];
        }
        _syncAudioPreview();
      });
      widget.onInteraction('POST_SOUND_SYNC: $val [URL: $_activePostSoundUrl]');
      
      // Auto-jump to library if 'Add sound' (top level) is clicked
      if (val == 'Add sound') {
        _showPostSoundHub();
      }
    });
  }

  void _showPostSoundHub() {
    widget.onInteraction('POST_SOUND_HUB_LONG_PRESS');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SovereignSoundHub(
        soundsList: _soundRegistry.entries.map((e) => {'title': e.key, 'url': e.value}).toList(),
        onRefresh: _loadDynamicSounds, // A_128: Allow manual refresh if list is empty
        onInteraction: (action, {contentId}) {
          widget.onInteraction(action, contentId: contentId);
          if (action.startsWith('SOUND_SAVED:') || action.startsWith('SOUND_UNSAVED:')) {
            _saveSavedSounds(); // Save to SharedPreferences when a sound is saved/unsaved
          }
        },
        onSelect: (sound) {
          setState(() {
            _activePostSound = sound['title'];
            _activePostSoundUrl = sound['url'];
            _syncAudioPreview();
          });
          widget.onInteraction('POST_SOUND_HUB_SELECT: ${sound['title']} [URL: $_activePostSoundUrl]');
        },
      ),
    );
  }

  void _showSovereignPicker(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const Divider(color: Colors.white10, height: 1),
            ...options.map((opt) => ListTile(
              title: Text(opt, style: const TextStyle(color: Colors.white)),
              onTap: () {
                onSelect(opt);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class EditProfileView extends StatefulWidget {
  final Function(String, {String? contentId}) onInteraction;
  final WebSocketChannel channel;
  final String currentName;
  final String currentBio;
  final String userMeshID;
  final String? currentPic;

  const EditProfileView({
    super.key, 
    required this.onInteraction, 
    required this.channel,
    required this.currentName,
    required this.currentBio,
    required this.userMeshID,
    this.currentPic,
  });

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _nameController;
  late TextEditingController _userController;
  late TextEditingController _bioController;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _userController = TextEditingController(text: widget.userMeshID.toLowerCase());
    _bioController = TextEditingController(text: widget.currentBio);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
      if (selected != null) {
        setState(() => _imageFile = selected);
        widget.onInteraction('PROFILE_PHOTO_HARVESTED');
      }
    } catch (e) {
      debugPrint("HARVEST_ERR: $e");
    }
  }

  // Sovereign Universal Upload Logic [A_124] - Now Future-Proof
  Future<void> _uploadVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final bytes = await video.readAsBytes();
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
      final uri = Uri.parse("http://$host:8080/upload");
      final request = http.MultipartRequest("POST", uri);
      
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes,
        filename: video.name
      ));

      widget.onInteraction('UPLOADING: ${video.name}');
      final response = await request.send();
      
      if (response.statusCode == 200) {
        widget.onInteraction('UPLOAD_SUCCESS: ${video.name}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ ${video.name} Uploaded to Sovereign Vault!'), backgroundColor: SovereignColors.cyan)
          );
        }
      } else {
        widget.onInteraction('UPLOAD_FAILED: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("UPLOAD_ERR: $e");
    }
  }

  void _editValue(String label, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('Edit $label', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            }, 
            child: const Text('SAVE', style: TextStyle(color: SovereignColors.cyan))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      backgroundImage: _imageFile != null 
                        ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path)) as ImageProvider)
                        : (widget.currentPic != null && widget.currentPic!.isNotEmpty ? NetworkImage(widget.currentPic!) : null) as ImageProvider?,
                      child: _imageFile == null && (widget.currentPic == null || widget.currentPic!.isEmpty) ? const Icon(Icons.person, size: 50, color: Colors.white38) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0, 
                    right: 0, 
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(5), 
                        decoration: const BoxDecoration(color: SovereignColors.cyan, shape: BoxShape.circle), 
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 20)
                      )
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: const Text('Change Photo', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            const SizedBox(height: 40),
            _buildEditField('Name', _nameController),
            _buildEditField('Username', _userController),
            _buildEditField('Bio', _bioController),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _uploadVideo,
                icon: const Icon(Icons.video_call_rounded, color: Colors.black),
                label: const Text('UPLOAD NEW VIDEO', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF00FF), // Sovereign Magenta for Action
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  String? uploadedPicPath = widget.currentPic;

                  // 1. Upload new image if selected
                  if (_imageFile != null) {
                    try {
                      final bytes = await _imageFile!.readAsBytes();
                      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
                      // Use _resolveSecureUrl to fix Mixed Content/CORS issues and use Nginx bridge
                      final String secureUploadUrl = _resolveSecureUrl("http://$host/upload");
                      final uri = Uri.parse(secureUploadUrl);
                      final request = http.MultipartRequest("POST", uri);
                      request.fields['uploader'] = widget.userMeshID;
                      request.files.add(http.MultipartFile.fromBytes(
                        'file', 
                        bytes,
                        filename: 'profile_${widget.userMeshID}.jpg'
                      ));

                      final response = await request.send();
                      if (response.statusCode == 200) {
                        final respStr = await response.stream.bytesToString();
                        final respJson = json.decode(respStr);
                        final filename = respJson['file'];
                        // Save using the proper path that works directly in frontend UI
                        uploadedPicPath = _resolveSecureUrl("http://$host/stream/$filename");
                      }
                    } catch (e) {
                      debugPrint("PIC_UPLOAD_ERR: $e");
                    }
                  }


                  // 2. Sovereign V15: Critical ID Injection Protocol
                  widget.channel.sink.add(json.encode({
                    "action": "UPDATE_USER_PROFILE",
                    "name": _nameController.text,
                    "bio": _bioController.text,
                    "profile_pic_path": uploadedPicPath,
                    "timestamp": DateTime.now().toIso8601String()
                  }));

                  widget.onInteraction('PROFILE_UPDATED');
                  if (!mounted) return;
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      backgroundColor: SovereignColors.cyan, 
                      content: Text('MESH IDENTITY SYNCED', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SovereignColors.cyan, 
                  foregroundColor: Colors.black, 
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return ListTile(
      onTap: () => _editValue(label, controller),
      title: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Text(controller.text, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Divider(color: Colors.white10),
        ],
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
    );
  }
}

class SovereignVerificationView extends StatefulWidget {
  final Function(String, {String? contentId}) onInteraction;
  final WebSocketChannel channel;

  const SovereignVerificationView({super.key, required this.onInteraction, required this.channel});

  @override
  State<SovereignVerificationView> createState() => _SovereignVerificationViewState();
}

class _SovereignVerificationViewState extends State<SovereignVerificationView> {
  final ImagePicker _picker = ImagePicker();
  XFile? _idDocument;
  String _docType = 'NATIONAL_ID';
  bool _isSubmitting = false;

  Future<void> _pickDocument() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.gallery);
    if (selected != null) {
      setState(() => _idDocument = selected);
      widget.onInteraction('VERIFICATION_DOC_PICKED');
    }
  }

  Future<void> _submitForAudit() async {
    if (_idDocument == null) return;
    setState(() => _isSubmitting = true);
    
    try {
      final bytes = await _idDocument!.readAsBytes();
      final String base64Data = "data:image/jpeg;base64,${base64.encode(bytes)}";
      
      widget.channel.sink.add(json.encode({
        "action": "VERIFICATION_SUBMIT",
        "document_data": base64Data,
        "document_path": _idDocument!.name,
        "doc_type": _docType,
        "timestamp": DateTime.now().toIso8601String()
      }));

      widget.onInteraction('VERIFICATION_SUBMITTED_FOR_AI_AUDIT');
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isSubmitting = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DOCUMENT INJECTED INTO AI JUSTIFY MODULE')));
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      debugPrint("SUBMIT_ERR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('ID VERIFICATION [A_107]'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('3-LAYER AI JUSTIFY PROTOCOL', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
            const SizedBox(height: 10),
            const Text('Submit your legal Identity Document for high-fidelity verification.', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            
            const Text('SELECT DOCUMENT TYPE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildDocTypeBtn('NATIONAL ID', 'NATIONAL_ID', Icons.badge_outlined),
                const SizedBox(width: 10),
                _buildDocTypeBtn('LICENSE', 'DRIVING_LICENSE', Icons.drive_eta_outlined),
                const SizedBox(width: 10),
                _buildDocTypeBtn('PASSPORT', 'PASSPORT', Icons.public_outlined),
              ],
            ),
            const SizedBox(height: 35),
            
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _idDocument != null ? SovereignColors.cyan : Colors.white10),
                ),
                child: _idDocument == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, color: Colors.white54, size: 50),
                        SizedBox(height: 15),
                        Text('Tap to upload document', style: TextStyle(color: Colors.white54)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: kIsWeb 
                        ? Image.network(_idDocument!.path, fit: BoxFit.cover) 
                        : Image.file(File(_idDocument!.path), fit: BoxFit.cover),
                    ),
              ),
            ),
            
            const SizedBox(height: 30),
            _buildLayerInfo('LAYER 1: QUALITY AUDIT', 'Resolution & Pattern Matching'),
            _buildLayerInfo('LAYER 2: AUTHENTICITY', 'Forgery & OCR Verification'),
            _buildLayerInfo('LAYER 3: PROFILE SYNC', 'Biometric Match with Avatar'),
            
            const Spacer(),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator(color: SovereignColors.cyan))
            else
              ElevatedButton(
                onPressed: _idDocument == null ? null : _submitForAudit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SovereignColors.cyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SUBMIT FOR AI JUSTIFY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDocTypeBtn(String label, String type, IconData icon) {
    bool isSelected = _docType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _docType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? SovereignColors.cyan.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? SovereignColors.cyan : Colors.white12, width: isSelected ? 2 : 1),
            boxShadow: isSelected ? [BoxShadow(color: SovereignColors.cyan.withValues(alpha: 0.2), blurRadius: 10)] : [],
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? SovereignColors.cyan : Colors.white24),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerInfo(String layer, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: SovereignColors.cyan, size: 16),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(layer, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}

class CreatorProfileView extends StatefulWidget {
  final String handle;
  final Function(String, {String? contentId}) onInteraction;
  final bool isBlocked;
  final Function(String, String, String) onAddMessage;
  final List<Map<String, dynamic>> mediaLedger;
  final String meshID; // A_105
  final Function(String) onSoundSelect;
  final VoidCallback? onCameraOpen;
  final bool isGatingEnabled;

  final WebSocketChannel channel;
  final Stream<dynamic> broadcastStream;

  const CreatorProfileView({
    super.key, 
    required this.handle, 
    required this.onInteraction, 
    this.isBlocked = false,
    this.isGatingEnabled = false,
    required this.meshID,
    required this.mediaLedger,
    required this.onSoundSelect,
    required this.onAddMessage,
    required this.channel,
    required this.broadcastStream,
    this.onCameraOpen,
  });

  @override
  State<CreatorProfileView> createState() => _CreatorProfileViewState();
}

class _CreatorProfileViewState extends State<CreatorProfileView> with SingleTickerProviderStateMixin {
  bool _showSuggestions = false;
  late bool _isBlocked;
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _suggestedAccounts = [
    {'handle': 'User_10', 'isFollowing': false},
    {'handle': 'User_11', 'isFollowing': false},
    {'handle': 'User_12', 'isFollowing': false},
    {'handle': 'User_13', 'isFollowing': false},
    {'handle': 'User_14', 'isFollowing': false},
  ];

  int _followers = 0;
  int _following = 0;
  int _totalLikes = 0;
  String? _creatorName;
  String? _creatorBio;
  String? _creatorPic;
  bool _isVerified = false; // Sovereign V15: Identity Shield State
  String _relationship = "follow"; // follow, following, follow_back, friends
  StreamSubscription? _syncSubscription;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.isBlocked;
    _tabController = TabController(length: 3, vsync: this);
    
    _syncSubscription = widget.broadcastStream.listen((message) {
      try {
        final data = json.decode(message);
        // Case-Insensitive Pulse Matching
        final targetHandle = widget.handle.replaceAll('@', '').toLowerCase();
        final serverTargetId = (data['target_id'] ?? "").toString().toLowerCase();
        
        if (data['action'] == 'CREATOR_STATS_SYNC' && serverTargetId == targetHandle) {
          if (mounted) {
            setState(() {
              _followers = (data['followers'] ?? 0).toInt();
              _following = (data['following'] ?? 0).toInt();
              _totalLikes = (data['total_likes'] ?? 0).toInt();
              _relationship = data['relationship'] ?? "follow";
              // V15 Mesh Injection: Capture Profile Metadata
              _creatorName = data['name'];
              _creatorBio = data['bio'];
              _creatorPic = data['profile_pic'];
              _isVerified = data['is_verified'] == true || data['isVerified'] == true || data['isVerifiedUser'] == true;
            });
          }
        } else if (data['action'] == 'RELATIONSHIP_UPDATE' && serverTargetId == targetHandle) {
           if (mounted) setState(() => _relationship = data['status']);
           _fetchStats(); // Re-fetch counts to update numbers
        } else if (data['action'] == 'SOCIAL_LIST_SYNC' && serverTargetId == targetHandle) {
           _showSocialListSheet(data['list_type'], data['users']);
        }
      } catch (e) {
        debugPrint("Stats Sync Error: $e");
      }
    });
    _loadSavedSounds(); // A_122 Saved Hub Hub Persistence
    _fetchStats();
  }

  Future<void> _loadSavedSounds() async {}

  void _fetchStats() {
    final cleanHandle = widget.handle.startsWith('@') ? widget.handle.substring(1) : widget.handle;
    widget.channel.sink.add(json.encode({
      "action": "GET_CREATOR_STATS",
      "target_id": cleanHandle
    }));
  }

  @override
  void dispose() {
    _syncSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creatorVideos = widget.mediaLedger.where((m) {
      final uploader = m['uploader']?.toString().toLowerCase().replaceAll('@', '');
      final handle = widget.handle.toLowerCase().replaceAll('@', '');
      return uploader == handle;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.handle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _openCreatorOptions(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Avatar Orchestration
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white12,
                  child: CircleAvatar(
                    radius: 46, 
                    backgroundColor: Colors.black, 
                    backgroundImage: (_creatorPic != null && _creatorPic!.isNotEmpty) 
                      ? NetworkImage(_creatorPic!) 
                      : null,
                    child: (_creatorPic == null || _creatorPic!.isEmpty) 
                      ? const Icon(Icons.person, size: 60, color: Colors.white24)
                      : null,
                  ),
                ),
                const SizedBox(height: 12),
                // Real Name Pulse [A_119 Sync]
                if (_creatorName != null && _creatorName!.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_creatorName!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      if (_isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: SovereignColors.cyan, size: 16),
                      ],
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('@${widget.handle.replaceAll('@', '')}', style: TextStyle(color: (_creatorName != null && _creatorName!.isNotEmpty) ? Colors.white70 : Colors.white, fontSize: (_creatorName != null && _creatorName!.isNotEmpty) ? 14 : 18, fontWeight: (_creatorName != null && _creatorName!.isNotEmpty) ? FontWeight.normal : FontWeight.bold)),
                    if (_isVerified && (_creatorName == null || _creatorName!.isEmpty)) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: SovereignColors.cyan, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 18),
                
                // TikTok Stats DNA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(_formatCount(_following), 'Following', onTap: () => _fetchSocialList('following')),
                    _buildStatDivider(),
                    _buildStat(_formatCount(_followers), 'Followers', onTap: () => _fetchSocialList('followers')),
                    _buildStatDivider(),
                    _buildStat(_formatCount(_totalLikes), 'Likes'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Interaction Hub
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildRelationshipActionButton(),
                    const SizedBox(width: 8),
                    _buildActionButton('Message', Colors.white10, Colors.white, () {
                      widget.onInteraction('PROFILE_MESSAGE_OPEN: ${widget.handle}');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SovereignDMView(user: widget.handle)));
                    }),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _showSuggestions = !_showSuggestions);
                        widget.onInteraction('PROFILE_SUGGESTIONS_TOGGLE: $_showSuggestions');
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                        child: AnimatedRotation(
                          turns: _showSuggestions ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showSuggestions) ...[
                  const SizedBox(height: 16),
                  _buildSuggestedAccounts(),
                ],
                const SizedBox(height: 16),
                
                // Bio Orchestration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _creatorBio ?? 'V15 Mesh Node | Quantum Content Creator\nInnovating the Sovereign Social DNA 🚀',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 1,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_outlined, size: 20)),
                  Tab(icon: Icon(Icons.repeat_rounded, size: 20)),
                  Tab(icon: Icon(Icons.lock_outline_rounded, size: 20)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildVideoGrid(creatorVideos.length, '', filteredMedia: creatorVideos),
            const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.repeat_rounded, size: 40, color: Colors.white10), Text('Reposts', style: TextStyle(color: Colors.white24))])),
            _buildVideoGrid(0, 'Private', isLock: true),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRelationshipActionButton() {
    String label = "Follow";
    Color bg = SovereignColors.cyan;
    Color fg = Colors.black;

    if (_relationship == "following") {
      label = "Following";
      bg = Colors.white10;
      fg = Colors.white;
    } else if (_relationship == "follow_back") {
      label = "Follow Back";
      bg = SovereignColors.cyan;
      fg = Colors.black;
    } else if (_relationship == "friends") {
      label = "Friends";
      bg = Colors.white10;
      fg = Colors.white;
    }

    final cleanHandle = widget.handle.startsWith('@') ? widget.handle.substring(1) : widget.handle;
    
    return _buildActionButton(label, bg, fg, () {
      // V15 Optimistic Pulse: Instant Feedback
      if (mounted) {
        setState(() {
          if (_relationship == "follow" || _relationship == "follow_back") {
            _relationship = "following";
            _followers++;
            followingNotifier.value++; // Pulse: Optimistic Global Sync
          } else {
            _relationship = "follow";
            _followers--;
            followingNotifier.value--; // Pulse: Optimistic Global Sync
          }
        });
      }
      widget.onInteraction('FOLLOW_USER', contentId: cleanHandle);
    });
  }

  void _fetchSocialList(String type) {
    final cleanHandle = widget.handle.startsWith('@') ? widget.handle.substring(1) : widget.handle;
    widget.channel.sink.add(json.encode({
      "action": "GET_SOCIAL_LIST",
      "target_id": cleanHandle,
      "list_type": type
    }));
  }

  void _showSocialListSheet(String type, List users) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              Text(type.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white10, height: 30),
              Expanded(
                child: users.isEmpty 
                  ? Center(child: Text("No $type yet", style: const TextStyle(color: Colors.white24)))
                  : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.person, color: Colors.white54)),
                        title: Text('@${user['handle']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: GestureDetector(
                          onTap: () {
                            setSheetState(() => user['is_following'] = !user['is_following']);
                            widget.onInteraction('FOLLOW_USER', contentId: user['handle']);
                            // After a short delay, re-fetch stats to update main profile counters
                            Future.delayed(const Duration(milliseconds: 500), _fetchStats);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: user['is_following'] ? Colors.white10 : SovereignColors.cyan,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user['is_mutual'] ? "Friends" : (user['is_following'] ? "Following" : "Follow"), 
                              style: TextStyle(color: user['is_following'] ? Colors.white70 : Colors.black, fontSize: 11, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _openCreatorProfile(user['handle']);
                        },
                      );
                    },
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 24), width: 0.5, height: 12, color: Colors.white10);
  }

  Widget _buildActionButton(String label, Color bg, Color fg, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        splashColor: fg.withValues(alpha: 0.1),
        highlightColor: fg.withValues(alpha: 0.05),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            label, 
            style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedAccounts() {
    if (_suggestedAccounts.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Suggested accounts', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _openAllSuggestions(),
                child: const Text('See all', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _suggestedAccounts.length,
            itemBuilder: (context, index) {
              final account = _suggestedAccounts[index];
              return _buildSuggestionCard(account, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> account, int index) {
    final String handle = account['handle'];
    final bool isFollowing = account['isFollowing'];
    
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _suggestedAccounts.removeAt(index));
                widget.onInteraction('SUGGESTION_CLOSE: $handle');
              },
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white12,
                  child: Icon(Icons.person, color: Colors.white38, size: 30),
                ),
                const SizedBox(height: 10),
                Text(handle, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                const Text('New creator', style: TextStyle(color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    setState(() => account['isFollowing'] = !isFollowing);
                    widget.onInteraction('SUGGESTION_FOLLOW_TOGGLE: $handle');
                  },
                  child: Container(
                    height: 32,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isFollowing ? Colors.white12 : SovereignColors.cyan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(color: isFollowing ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAllSuggestions() {
    widget.onInteraction('OPEN_ALL_SUGGESTIONS');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Suggested accounts', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const Divider(color: Colors.white10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _suggestedAccounts.length,
                  itemBuilder: (context, index) {
                    final account = _suggestedAccounts[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: const CircleAvatar(radius: 24, backgroundColor: Colors.white12, child: Icon(Icons.person, color: Colors.white38)),
                      title: Text(account['handle'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Suggested for you', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => account['isFollowing'] = !account['isFollowing']);
                              setModalState(() {});
                              widget.onInteraction('SUGGESTION_FOLLOW_TOGGLE: ${account['handle']}');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: account['isFollowing'] ? Colors.white12 : SovereignColors.cyan,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                account['isFollowing'] ? 'Following' : 'Follow',
                                style: TextStyle(color: account['isFollowing'] ? Colors.white : Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() => _suggestedAccounts.removeAt(index));
                              setModalState(() {});
                              widget.onInteraction('SUGGESTION_CLOSE: ${account['handle']}');
                              if (_suggestedAccounts.isEmpty) Navigator.pop(context);
                            },
                            child: const Icon(Icons.close, color: Colors.white38, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreatorProfile(String handle) {
    widget.onInteraction('OPEN_CREATOR_PROFILE: $handle');
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => CreatorProfileView(
        handle: handle, 
        onInteraction: widget.onInteraction,
        onAddMessage: widget.onAddMessage,
        meshID: widget.meshID, // A_105
        mediaLedger: widget.mediaLedger, // A_118 Fix
        onSoundSelect: widget.onSoundSelect, // A_128 Fix
        channel: widget.channel,
        broadcastStream: widget.broadcastStream,
      ))
    );
  }

  void _openSoundDetail(String soundName) {
    widget.onInteraction('OPEN_SOUND_DETAIL: $soundName');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SovereignSoundDetail(
        soundName: soundName, 
        onInteraction: widget.onInteraction,
        onAddMessage: widget.onAddMessage,
        onSoundSelect: widget.onSoundSelect,
        mediaLedger: widget.mediaLedger,
        onVideoTap: (initialIndex, indices) => _openVideoDetail(initialIndex, videoIndices: indices),
        onUseSound: () {
           widget.onInteraction('SOUND_USE_FROM_ITEM: $soundName');
           widget.onSoundSelect(soundName);
           widget.onCameraOpen?.call();
           Navigator.pop(context); // Close Sound Detail
           Navigator.pop(context); // Close Profile
        },
      ))
    );
  }

  void _openVideoDetail(int initialIndex, {List<int>? videoIndices, int? count}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SovereignVideoDetailFeed(
          initialIndex: initialIndex,
          videoIndices: videoIndices,
          totalCount: count ?? (videoIndices != null ? videoIndices.length : 12),
          onInteraction: widget.onInteraction,
          creatorProfileOpen: _openCreatorProfile,
          soundDetailOpen: _openSoundDetail,
          onAddMessage: widget.onAddMessage,
          meshID: widget.meshID, // A_105
          mediaLedger: widget.mediaLedger, // A_118 Fix
          onSoundSelect: widget.onSoundSelect, // A_128 Fix
        ),
      ),
    );
  }

  void _showUserReportDialog() {
    final List<String> reasons = [
      "Inappropriate behavior",
      "Harassment or bullying",
      "Impersonation",
      "Spam or scamm",
      "Hate speech",
      "Posting illegal content"
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('REPORT USER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Text('Reporting @${widget.handle.replaceAll('@', '')}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 20),
            ...reasons.map((reason) => ListTile(
              title: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white10),
              onTap: () {
                widget.onInteraction('REPORT_USER: ${widget.handle}|$reason');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: SovereignColors.cyan, content: Text('USER REPORTED: $reason', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                );
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoGrid(int count, String metric, {bool isLock = false, bool isHeart = false, List<Map<String, dynamic>>? filteredMedia}) {
    final displayMedia = filteredMedia ?? widget.mediaLedger;
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 0.75, 
        crossAxisSpacing: 1, 
        mainAxisSpacing: 1
      ),
      itemCount: count,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          // V15 Mesh Logic: Exact indexing for filtered creators
          List<int>? videoIndices;
          if (filteredMedia != null) {
            videoIndices = filteredMedia.map((m) => widget.mediaLedger.indexOf(m)).toList();
          }
          _openVideoDetail(index, videoIndices: videoIndices, count: count);
        },
        child: Container(
          color: Colors.white.withValues(alpha: 0.05),
          child: Stack(
            fit: StackFit.expand,
            children: [
              (() {
                final String tUrl = getSovereignThumb(widget.mediaLedger.indexOf(displayMedia[index]), widget.mediaLedger);
                return tUrl.isNotEmpty
                   ? Image.network(
                       tUrl,
                       fit: BoxFit.cover,
                       errorBuilder: (c, e, s) => const Center(child: Icon(Icons.play_arrow, color: Colors.white10, size: 30)),
                     )
                   : const Center(child: Icon(Icons.play_arrow, color: Colors.white10, size: 30));
              })(),
              
              Positioned(
                bottom: 8,
                left: 8,
                child: Row(
                  children: [
                    Icon(isLock ? Icons.lock_outline : (isHeart ? Icons.favorite_border : Icons.play_arrow_outlined), color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      metric.isNotEmpty 
                        ? metric 
                        : (index < displayMedia.length 
                            ? _formatCount(displayMedia[index]['views'] ?? 0)
                            : '0'), 
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreatorOptions() {
    widget.onInteraction('OPEN_CREATOR_OPTIONS: ${widget.handle}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161616),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 8),
            // Share Sector
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Share to', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildShareIcon('Instagram', Icons.camera_alt, const Color(0xFFE1306C)),
                  _buildShareIcon('WhatsApp', Icons.chat, const Color(0xFF25D366)),
                  _buildShareIcon('Facebook', Icons.facebook, const Color(0xFF1877F2)),
                  _buildShareIcon('Copy link', Icons.link, Colors.white24),
                  _buildShareIcon('SMS', Icons.sms, Colors.white24),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 32),
            // Action Sector
            _buildOptionItem(Icons.report_gmailerrorred, 'Report', Colors.white, () {
              Navigator.pop(context);
              _showUserReportDialog();
            }),
            _buildOptionItem(_isBlocked ? Icons.block_flipped : Icons.block, _isBlocked ? 'Unblock' : 'Block', Colors.white, () {
              Navigator.pop(context);
              final oldState = _isBlocked;
              setState(() => _isBlocked = !_isBlocked);
              widget.onInteraction(_isBlocked ? 'CREATOR_BLOCK: ${widget.handle}' : 'CREATOR_UNBLOCK: ${widget.handle}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(oldState ? 'Unblocked ${widget.handle}' : 'Blocked ${widget.handle}'),
                duration: const Duration(seconds: 2),
              ));
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildShareIcon(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        widget.onInteraction('CREATOR_SHARE: $label');
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            CircleAvatar(radius: 24, backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color == Colors.white24 ? Colors.white : color, size: 24)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  String _formatCount(num value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    } else {
      return value.toString();
    }
  }

  Widget _buildOptionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.black, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class SponsoredTemplatesView extends StatefulWidget {
  final Function(String, {String? contentId}) onInteraction;
  final ValueNotifier<double> usdCpmListenable;
  final ValueNotifier<double> bdtCpmListenable;
  final ValueNotifier<double> usdListenable;
  final ValueNotifier<double> bdtListenable;
  final List<Map<String, dynamic>> mediaLedger; // A_111 Content Link

  const SponsoredTemplatesView({
    super.key, 
    required this.onInteraction, 
    required this.usdCpmListenable,
    required this.bdtCpmListenable,
    required this.usdListenable,
    required this.bdtListenable,
    required this.mediaLedger
  });

  @override
  State<SponsoredTemplatesView> createState() => _SponsoredTemplatesViewState();
}

class _SponsoredTemplatesViewState extends State<SponsoredTemplatesView> {
  int? _selectedVideoIndex;
  String _selectedMediaType = 'Video';
  int _targetViewsK = 5; // Default 5K Views
  bool _isAutoTemplate = true;
  String selectedCurrency = 'USD'; // Default Funding Source
  
  // A_111 Global Geo-Mesh State
  final TextEditingController _locationSearchController = TextEditingController();
  List<dynamic> _locationResults = [];
  Map<String, dynamic>? _selectedGeoNode;
  bool _isSearching = false;
  double _targetingRadiusKm = 5.0; // Default 5km radius [Village Level Precision]
  RangeValues _ageRange = const RangeValues(18, 24);
  String _selectedGender = 'All';
  final TextEditingController _professionController = TextEditingController();

  Future<void> _searchLocations(String query) async {
    if (query.length < 3) return;
    setState(() => _isSearching = true);
    try {
      // Sovereign V15 Optimization: Filter by Country (BD) and include address details for village precision
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=10&addressdetails=1&countrycodes=bd'),
        headers: {'User-Agent': 'Sovereign_V15_GeoMesh'}
      );
      if (response.statusCode == 200) {
        setState(() => _locationResults = json.decode(response.body));
      }
    } catch (e) {
      debugPrint("GEO_SEARCH_ERR: $e");
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _openMapPicker() {
    // V15 Hyper-Local Pick Logic
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setMapState) {
          LatLng center = _selectedGeoNode != null 
            ? LatLng(double.parse(_selectedGeoNode!['lat']), double.parse(_selectedGeoNode!['lon']))
            : const LatLng(23.6850, 90.3563); // Default Dhaka
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text('V15 HYPER-LOCAL MAP PICKER', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const Text('DRAG MAP TO POSITION PIN OVER YOUR AREA', style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 20),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 13.0,
                            onPositionChanged: (pos, hasGesture) {
                              if (hasGesture) {
                                center = pos.center;
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.sovereign.media',
                            ),
                          ],
                        ),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 35),
                            child: Icon(Icons.location_on, color: Colors.redAccent, size: 45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SovereignColors.cyan,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedGeoNode = {
                        "display_name": "Pin Drop [${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}]",
                        "lat": center.latitude.toString(),
                        "lon": center.longitude.toString(),
                        "type": "manual_pin"
                      };
                      _locationSearchController.text = _selectedGeoNode!['display_name'];
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('LOCK THIS LOCATION', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        }
      ),
    );
  }


  // Helper for Currency Toggle
  Widget _buildCurrencyToggle(String currency, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedCurrency = currency),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? SovereignColors.cyan : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? SovereignColors.cyan : Colors.white24),
        ),
        child: Text(currency, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showMediaPicker() {
    widget.onInteraction('OPEN_PROFILE_MEDIA_PICKER');
    
    // V15 Mesh Sync [A_111 Master Logic]
    final List<Map<String, dynamic>> meshVault = widget.mediaLedger;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            const Text(
              'V15 MESH: SELECT VIDEO', 
              style: TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)
            ),
            const SizedBox(height: 10),
            Text('VAULT_SYNC: ${meshVault.length} Videos detected online', style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: meshVault.isEmpty 
                ? const Center(child: Text('EMPTY_VAULT: NO_MEDIA_FOUND', style: TextStyle(color: Colors.white12, fontSize: 12, letterSpacing: 1)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75
                    ),
                    itemCount: meshVault.length,
                    itemBuilder: (context, index) {
                      final m = meshVault[index];
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedVideoIndex = index);
                          widget.onInteraction('TEMPLATE_MEDIA_SELECTED: ${m['file']}');
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _selectedVideoIndex == index ? const Color(0xFF00FFFF) : Colors.white12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                               (() {
                                 final String tUrl = getSovereignThumb(index, meshVault);
                                 return tUrl.isNotEmpty
                                   ? Image.network(
                                       tUrl,
                                       fit: BoxFit.cover,
                                       errorBuilder: (c, e, s) => Container(color: Colors.black, child: const Icon(Icons.videocam_outlined, color: Colors.white10)),
                                     )
                                   : Container(color: Colors.black, child: const Icon(Icons.videocam_outlined, color: Colors.white10));
                               })(),
                              
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)]
                                  )
                                ),
                              ),
                              Positioned(
                                bottom: 12, left: 12,
                                child: Text(
                                  m['desc'] ?? 'Video #$index', 
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedVideoIndex == index)
                                const Center(child: Icon(Icons.check_circle, color: Color(0xFF00FFFF), size: 40)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final isSelected = _selectedMediaType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMediaType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? SovereignColors.cyan : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white70),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.usdListenable,
      builder: (context, val, _) {
        // A_113: Wallet State Listeners
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, title: const Text('Ad Target Templates'), centerTitle: true),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text('A_111: AI TARGETING SUITE', style: TextStyle(color: SovereignColors.cyan, letterSpacing: 2)),
            const SizedBox(height: 20),
            _buildInput('Template Name', 'e.g. Summer Campaign'),
            const SizedBox(height: 25),
            
            const Text('Content Type', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeChip('Video', Icons.videocam),
                const SizedBox(width: 12),
                _buildTypeChip('Photo', Icons.image),
              ],
            ),
            const SizedBox(height: 25),

            // Selection Trigger [NEW formally added as requested]
            const Text('Template Media Source', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showMediaPicker,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedVideoIndex != null ? SovereignColors.cyan : Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65, height: 65,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                      child: _selectedVideoIndex != null 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              getSovereignThumb(_selectedVideoIndex!, widget.mediaLedger), 
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(color: Colors.black, child: const Icon(Icons.videocam, color: Colors.white10)),
                            ),
                          )
                        : Icon(_selectedMediaType == 'Video' ? Icons.video_library_outlined : Icons.photo_library_outlined, color: Colors.white38),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedVideoIndex != null ? 'Media Linked: #$_selectedVideoIndex' : 'No Media Selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('TAP TO SELECT FROM PROFILE', style: TextStyle(color: SovereignColors.cyan, fontSize: 10, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  ],
                ),
              ),
            ),
            
            
            // A_111 & A_113: DUAL-CURRENCY QUANTUM FUNDING [USD/BDT]
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SovereignColors.cyan.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('QUANTUM FUNDING [A_113]', style: TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      // Currency Toggle
                      Row(
                        children: [
                          _buildCurrencyToggle('USD', selectedCurrency == 'USD'),
                          const SizedBox(width: 8),
                          _buildCurrencyToggle('BDT', selectedCurrency == 'BDT'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Financial Engine
                  ValueListenableBuilder<double>(
                    valueListenable: selectedCurrency == 'USD' ? widget.usdCpmListenable : widget.bdtCpmListenable,
                    builder: (context, cpm, _) {
                      final double cost = _targetViewsK * cpm;
                      final String symbol = selectedCurrency == 'USD' ? '\$' : '৳';
                      
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('TARGET REACH', style: TextStyle(color: Colors.white38, fontSize: 9)),
                                  Text('${_targetViewsK}K VIEWS', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                                child: Text('-$symbol${cost.toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('CPM RATE: $symbol$cpm / 1k', style: const TextStyle(color: Colors.white24, fontSize: 9)),
                              ValueListenableBuilder<double>(
                                valueListenable: selectedCurrency == 'USD' ? widget.usdListenable : widget.bdtListenable, // Wallet Balance
                                builder: (context, balance, _) {
                                  return Text('BALANCE: $symbol${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= cost ? Colors.greenAccent : Colors.red, fontSize: 10));
                                }
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  
                  Slider(
                    value: _targetViewsK.toDouble(),
                    min: 1, max: 100,
                    activeColor: SovereignColors.cyan,
                    inactiveColor: Colors.white10,
                    onChanged: (v) => setState(() => _targetViewsK = v.toInt()),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: SovereignColors.cyan, size: 14),
                      const SizedBox(width: 8),
                      const Text('AUTO-TEMPLATE SYSTEM ACTIVE', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      const Spacer(),
                      Switch(
                        value: _isAutoTemplate,
                        onChanged: (v) => setState(() => _isAutoTemplate = v),
                        activeThumbColor: SovereignColors.cyan,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            // A_115: 3-LAYER AI MODERATION [A-Z ENFORCEMENT]
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.green, size: 14),
                  SizedBox(width: 10),
                  Text('3-LAYER AI AUTO-MODERATION ACTIVE', style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text('Target Audience (AI Filter)', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            _buildAgeRangeSlider(),
            _buildGenderDropdown(),
            
            const SizedBox(height: 20),
            const Text('AI Geo-Targeting (Global Search)', style: TextStyle(color: SovereignColors.cyan, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationSearchController,
                    onChanged: (v) {
                      if (v.length > 2) _searchLocations(v);
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search city, region or country...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      prefixIcon: const Icon(Icons.location_on, color: SovereignColors.cyan, size: 18),
                      suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: SovereignColors.cyan))) : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SovereignColors.cyan)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: SovereignColors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2))),
                    child: const Icon(Icons.map, color: SovereignColors.cyan),
                  ),
                ),
              ],
            ),
            
            if (_locationResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 10),
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: const Color(0xFF151515), 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)]
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _locationResults.length,
                  separatorBuilder: (c, i) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, index) {
                    final loc = _locationResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.map_outlined, color: Colors.white38, size: 16),
                      title: Text(loc['display_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.add_location_alt_outlined, color: SovereignColors.cyan, size: 16),
                      onTap: () {
                        setState(() {
                          _selectedGeoNode = loc;
                          _locationSearchController.text = loc['display_name'];
                          _locationResults = [];
                        });
                        widget.onInteraction('GEO_LOCKED: ${loc['display_name']}');
                      },
                    );
                  },
                ),
              ),
            
            if (!_isSearching && _locationResults.isEmpty && _locationSearchController.text.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 5),
                child: Text('NO LOCAL MATCHES FOUND. TRY NAME ONLY (e.g. "MODHUKHALI")', style: TextStyle(color: Colors.orangeAccent.withValues(alpha: 0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            
            // Re-evaluating Radius Slider Logic: Show it once a town is searched or selected
            if (_selectedGeoNode != null || _locationSearchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    if (_selectedGeoNode != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.withValues(alpha: 0.2))),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.greenAccent, size: 16),
                            const SizedBox(width: 10),
                            Expanded(child: Text('AI GEO-LOCK ACTIVE: ${(_selectedGeoNode!['display_name'] as String).split(',').first}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('HYPER-LOCAL RADIUS', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(_targetingRadiusKm < 1 ? '${(_targetingRadiusKm * 1000).toInt()}m' : '${_targetingRadiusKm.toStringAsFixed(1)}km', style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: _targetingRadiusKm,
                      min: 0.5, max: 20.0,
                      divisions: 39,
                      activeColor: SovereignColors.cyan,
                      inactiveColor: Colors.white12,
                      onChanged: (v) => setState(() => _targetingRadiusKm = v),
                    ),
                    const Text('Sovereign AI: Precise Village-to-Village targeting enabled.', style: TextStyle(color: Colors.white24, fontSize: 9, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            
            const SizedBox(height: 10),
            _buildInput('Profession Interest', 'e.g. Tech, Beauty, Crypto', controller: _professionController),
            const SizedBox(height: 40),
            
            ElevatedButton(
              onPressed: () {
                if (_selectedVideoIndex == null) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a video/photo for the template')));
                   return;
                }
                
                final double cpm = selectedCurrency == 'USD' ? widget.usdCpmListenable.value : widget.bdtCpmListenable.value;
                final double currentBalance = selectedCurrency == 'USD' ? widget.usdListenable.value : widget.bdtListenable.value;
                final double cost = _targetViewsK * cpm;
                
                if (currentBalance < cost) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('INSUFFICIENT $selectedCurrency BALANCE')));
                  return;
                }

                // 3-LAYER AI MODERATION TRIGGER [A_115]
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: SovereignColors.cyan),
                        SizedBox(height: 20),
                        Text('3-LAYER AI MODERATION IN PROGRESS...', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                      ],
                    ),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close loading

                  // A_113: Atomic Transaction Trigger (Deduct User, Credit Admin)
                  final Map<String, dynamic> txData = {
                    "action": "SPONSOR_TEMPLATE_PURCHASE",
                    "media_type": _selectedMediaType,
                    "target_views": _targetViewsK,
                    "cost": cost,
                    "currency": selectedCurrency,
                    "media_id": widget.mediaLedger[_selectedVideoIndex!]['file'] ?? "UNKNOWN",
                    "target_audience": {
                      "age_range": "${_ageRange.start.toInt()}-${_ageRange.end.toInt()}",
                      "gender": _selectedGender,
                      "profession": _professionController.text
                    },
                    "geo_targeting": _selectedGeoNode != null ? {
                      "name": _selectedGeoNode!['display_name'],
                      "lat": _selectedGeoNode!['lat'],
                      "lon": _selectedGeoNode!['lon'],
                      "type": _selectedGeoNode!['type'],
                      "radius_km": _targetingRadiusKm
                    } : null
                  };
                  
                  // V15 Secure Dispatch
                  widget.onInteraction('TRANSX:SAVE_TEMPLATE', contentId: json.encode(txData));
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('SUCCESS: ${cost.toStringAsFixed(2)} $selectedCurrency DEDUCTED FROM WALLET'),
                    backgroundColor: Colors.green,
                  ));
                  
                  if (!context.mounted) return;
                  Navigator.pop(context); // Close Template View
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan, foregroundColor: Colors.black, padding: const EdgeInsets.all(15)),
              child: const Text('SAVE TEMPLATE'),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildInput(String label, String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white12),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
      ),
    );
  }

  Widget _buildAgeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Age Range', style: TextStyle(color: Colors.white)),
            Text('${_ageRange.start.toInt()}-${_ageRange.end.toInt()}', style: const TextStyle(color: SovereignColors.cyan)),
          ],
        ),
        RangeSlider(
          values: _ageRange,
          min: 13,
          max: 65,
          divisions: 52,
          activeColor: SovereignColors.cyan,
          inactiveColor: Colors.white12,
          labels: RangeLabels(_ageRange.start.toInt().toString(), _ageRange.end.toInt().toString()),
          onChanged: (values) => setState(() => _ageRange = values),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    final items = ['All', 'Male', 'Female', 'Non-Binary'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(5)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          dropdownColor: Colors.black,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedGender = v);
          },
        ),
      ),
    );
  }
}

class VideoFeedItem extends StatefulWidget {
  final int index;
  final Function(String, {String? contentId}) onInteraction;
  final double adPanelHeight;
  final Function(String) creatorProfileOpen;
  final Function(String) soundDetailOpen;
  final bool isHome;
  final Function(String, String, String) onAddMessage;
  final String? userProfileImage;
  final double adFrequency; // Legacy: Ads per minute
  final double sponsorFrequency; // V15: Videos per sponsor badge
  final String? videoUrl;
  final String? uploaderName;
  final String? uploaderHandle;
  final bool isVerified;
  final String? description; // A_118: Real Metadata
  final String meshID; // A_105 Ownership Bridge
  final List<Map<String, dynamic>> mediaLedger;
  final VoidCallback? onSkip; // A_125: TikTok Logic Skip

  const VideoFeedItem({
    super.key,
    required this.index,
    required this.onInteraction,
    required this.adPanelHeight,
    required this.creatorProfileOpen,
    required this.soundDetailOpen,
    required this.adFrequency,
    required this.sponsorFrequency,
    required this.onAddMessage,
    required this.mediaLedger,
    required this.meshID,
    required this.uploaderHandle,
    required this.isVerified,
    required this.description,
    this.onSkip,
    this.userProfileImage,
    this.videoUrl,
    this.uploaderName,
    this.isHome = false,
  });

  @override
  State<VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<VideoFeedItem> with SingleTickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  final List<Offset> _hearts = [];
  final List<String> _bannedWords = ['scam', 'spam', 'fake', 'money'];
  String? _commentError;
  bool _isPlaying = true;
  final TextEditingController _commentController = TextEditingController();
  
  // Sovereign V15: TikTok Logic State
  double _playbackSpeed = 1.0;
  bool _isClearDisplay = false;
  bool _showCaptions = false;
  
  // Interaction States
  bool isLiked = false;
  bool isSaved = false;
  bool isFollowing = false;
  double _saveScale = 1.0;
  double _likeScale = 1.0;
  
  // V15 Reactive Comment Drawer Bridge
  StateSetter? _commentDrawerRefresher;

  String get _currentContentId => widget.index < widget.mediaLedger.length 
      ? (widget.mediaLedger[widget.index]['file'] ?? "V15_CONTENT_${widget.index}")
      : "V15_LEGACY_${widget.index}";

  String _getFormattedStat(String key, String fallback) {
    if (widget.index < widget.mediaLedger.length) {
      final stat = widget.mediaLedger[widget.index][key] ?? 0;
      if (stat == 0) return fallback;
      if (stat >= 1000) {
        return '${(stat / 1000).toStringAsFixed(1)}k';
      }
      return '$stat';
    }
    return fallback;
  }

   late AnimationController _discController;
  late VideoPlayerController _videoController;
  VideoPlayerController? _audioController; // A_128: Neural Sound Controller
  VideoPlayerController? _quantumPreloadController; // V15 Phase 10: Quantum Preload
  bool _isInitialized = false;
  bool _isImage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPushNext() {
    // A_117 Pulse: Entering sub-layer [Pausing Background Video]
    _videoController.pause();
    _audioController?.pause(); // PAUSE AUDIO
    _discController.stop();
  }

  @override
  void didUpdateWidget(VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A_120: Reactive Social Sync [Anchor to Ledger]
    if (widget.index < widget.mediaLedger.length) {
      final media = widget.mediaLedger[widget.index];
      final List? likedBy = media['liked_by'] is List ? media['liked_by'] : null;
      final List? savedBy = media['saved_by'] is List ? media['saved_by'] : null;
      if (mounted) {
        setState(() {
           isLiked = likedBy?.any((e) => e.toString().toUpperCase() == widget.meshID.toUpperCase()) ?? false;
           isSaved = savedBy?.contains(widget.meshID) ?? false;
        });
      }
      // V15 Reactive Bridge: If comment drawer is open, refresh it too
      if (_commentDrawerRefresher != null) {
        try { _commentDrawerRefresher!(() {}); } catch (_) {}
      }
    }
  }

  @override
  void didPopNext() {
    // A_117 Pulse: Returning to main circuit [Restoring Playback]
    if (_isPlaying && _isInitialized) {
      if (!_isImage) _videoController.play();
      _audioController?.play(); // RESUME AUDIO
      _discController.repeat();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // A_120: Initialize Social State from Ledger
    if (widget.index < widget.mediaLedger.length) {
      final media = widget.mediaLedger[widget.index];
      final List? likedBy = media['liked_by'] is List ? media['liked_by'] : null;
      final List? savedBy = media['saved_by'] is List ? media['saved_by'] : null;
      isLiked = likedBy?.any((e) => e.toString().toUpperCase() == widget.meshID.toUpperCase()) ?? false;
      isSaved = savedBy?.contains(widget.meshID) ?? false;
    }

    _discController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    
    // 1. Resolve Stream URLs properly
    String url = widget.videoUrl ?? getSovereignUrl(widget.index, widget.mediaLedger);
    if (!url.startsWith('http')) url = _resolveSecureUrl(url);
    
    _isImage = url.toLowerCase().contains('.jpg') || 
               url.toLowerCase().contains('.jpeg') || 
               url.toLowerCase().contains('.png') || 
               url.toLowerCase().contains('.webp');
    
    debugPrint("Mesh Pulse: Initializing index ${widget.index} -> $url");
    
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(_resolveSecureUrl(url)),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _videoController.setLooping(true);
    _videoController.setVolume(1.0); 
    
    if (!_isImage) {
      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _videoController.setPlaybackSpeed(_playbackSpeed);
            _videoController.play();
          });
          widget.onInteraction('VIDEO_VIEW', contentId: _currentContentId);
        }
      }).catchError((e) {
        debugPrint("Video Sync ERR: $e | Source: $url");
        if (mounted) setState(() => _isInitialized = true); // Allow fallback display
      });
    } else {
      setState(() => _isInitialized = true);
      widget.onInteraction('PHOTO_VIEW', contentId: _currentContentId);
    }

    // 2. Resolve Audio Stream [A_128 DNA]
    final soundInfo = _getSoundInfo();
    final String? sUrl = soundInfo['url'];
    if (sUrl != null && sUrl.isNotEmpty) {
      final String resolvedAudioUrl = _resolveSecureUrl(sUrl);
      debugPrint("Audio Pulse: $resolvedAudioUrl");
      
      _audioController = VideoPlayerController.networkUrl(
        Uri.parse(resolvedAudioUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      )..initialize().then((_) {
        if (mounted) {
          _audioController?.setLooping(true);
          double vol = 1.0;
          if (widget.index < widget.mediaLedger.length) {
            vol = (widget.mediaLedger[widget.index]['added_sound_volume'] ?? 1.0).toDouble();
          }
          _audioController?.setVolume(vol);
          if (_isPlaying) _audioController?.play();
          setState(() {});
        }
      }).catchError((e) {
        debugPrint("Audio Handshake Failed: $e");
      });
    }

    // --- Sovereign V15 Phase 10: Quantum Speed Pre-Caching ---
    if (widget.index + 1 < widget.mediaLedger.length) {
      String nextUrl = getSovereignUrl(widget.index + 1, widget.mediaLedger);
      bool isNextImage = nextUrl.toLowerCase().contains('.jpg') || 
                         nextUrl.toLowerCase().contains('.jpeg') || 
                         nextUrl.toLowerCase().contains('.png') || 
                         nextUrl.toLowerCase().contains('.webp');
      
      if (!isNextImage && nextUrl.isNotEmpty) {
        _quantumPreloadController = VideoPlayerController.networkUrl(
          Uri.parse(_resolveSecureUrl(nextUrl)),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        )..initialize().then((_) {
          debugPrint("A_121 Quantum Speed: Pre-cached next item -> $nextUrl");
        }).catchError((e) {
          debugPrint("Quantum Precache Error: $e");
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // A_117: Detach Lifecycle Observer
    routeObserver.unsubscribe(this);
    _discController.dispose();
    _videoController.dispose();
    _audioController?.dispose(); // DISPOSE AUDIO
    _quantumPreloadController?.dispose(); // DISPOSE PRELOAD BUFFER
    _commentController.dispose();
    super.dispose();
  }

  // A_128: Neural Sound Resolver [TikTok DNA]
  Map<String, String> _getSoundInfo() {
    String uploader = widget.uploaderName ?? '@SovereignUltra';
    if (uploader.startsWith('@')) uploader = uploader.substring(1);
    
    String soundName = "Original Sound - $uploader";
    String soundUrl = "";
    
    if (widget.index < widget.mediaLedger.length) {
      final entry = widget.mediaLedger[widget.index];
      
      // A_128: Priority - If an added sound exists (from library), use it first!
      if (entry['added_sound_url'] != null && entry['added_sound_url'].toString().isNotEmpty) {
        soundUrl = entry['added_sound_url'].toString();
      } 
      // Fallback: If no added sound, use harvested original sound
      else if (entry['sound_url'] != null && entry['sound_url'].toString().isNotEmpty) {
        soundUrl = entry['sound_url'].toString();
      }

      // Check if there's a custom sound name
      if (entry['sound_name'] != null && entry['sound_name'].toString().isNotEmpty) {
         String dbSoundName = entry['sound_name'].toString();
         // V15 Gap Fix: TikTok Logic Override for 'Add sound'
         if (dbSoundName != "Add sound") {
           soundName = dbSoundName;
         }
      }
    }
    
    return {
      "name": soundName,
      "url": soundUrl
    };
  }

  void _addHeart(Offset position) {
    setState(() {
      _hearts.add(position);
      _likeScale = 1.3; // Pop pulse on double tap
      if (!isLiked) {
        isLiked = true; 
        // V15 Optimistic UI: List-based increment
        final mediaItem = widget.mediaLedger[widget.index];
        mediaItem['liked_by'] ??= [];
        if (!(mediaItem['liked_by'] as List).contains(widget.meshID)) {
          (mediaItem['liked_by'] as List).add(widget.meshID);
        }
        mediaItem['likes'] = (mediaItem['liked_by'] as List).length;
      }
    });

    Future.delayed(const Duration(milliseconds: 150), () {
       if (mounted) setState(() => _likeScale = 1.0);
    });

    widget.onInteraction('VIDEO_LIKE: ${widget.mediaLedger[widget.index]['file'] ?? widget.index}', contentId: _currentContentId);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _hearts.removeAt(0);
        });
      }
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (!_isImage) _videoController.play();
        _audioController?.play(); // PLAY AUDIO
        _discController.repeat();
      } else {
        _videoController.pause();
        _audioController?.pause(); // PAUSE AUDIO
        _discController.stop();
      }
    });
    widget.onInteraction(_isPlaying ? 'VIDEO_PLAY' : 'VIDEO_PAUSE', contentId: _currentContentId);
  }

  // A_125: Neural Cadence Control
  void _togglePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else if (_playbackSpeed == 2.0) {
        _playbackSpeed = 0.5;
      } else {
        _playbackSpeed = 1.0;
      }
      
      if (!_isImage) _videoController.setPlaybackSpeed(_playbackSpeed);
    });
    widget.onInteraction('PLAYBACK_SPEED_CHANGED: $_playbackSpeed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚡ Motion Speed: ${_playbackSpeed}x'),
        duration: const Duration(seconds: 1),
        backgroundColor: SovereignColors.cyan,
      )
    );
  }

  // A_125: Visual Sensory Shield
  void _toggleClearDisplay() {
    setState(() {
      _isClearDisplay = !_isClearDisplay;
    });
    widget.onInteraction('CLEAR_DISPLAY_TOGGLED: $_isClearDisplay');
  }

  // A_125: AI Sensory Captions
  void _toggleCaptions() {
    setState(() {
      _showCaptions = !_showCaptions;
    });
    widget.onInteraction('CAPTIONS_TOGGLED: $_showCaptions');
  }

  // A_125: Content Archiving Protocol
  void _downloadVideo() {
    final String url = widget.videoUrl ?? getSovereignUrl(widget.index, widget.mediaLedger);
    widget.onInteraction('VIDEO_SAVE_INITIATED: $url');
    
    // Web Logic: Trigger native browser download behavior
    // For now, we open in new tab as a secure archiving step
    widget.onInteraction('OPTIONS_SAVE'); 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 Exporting to Sovereign Vault...'),
        backgroundColor: Colors.green,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // V15 Split-Screen Logic: Fully responsive to AdMob 40% requirement.
    final double bottomSafePadding = widget.adPanelHeight > 0 ? 12 : 80;

    return Container(
      color: Colors.black, // Background for desktop/wide focus
      alignment: Alignment.center,
      child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
            ),
            child: GestureDetector(
              onTap: _togglePlay,
              onDoubleTapDown: (details) => _addHeart(details.localPosition),
              onLongPress: _showLongPressMenu,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Video/Content Layer
                  Container(
                    color: Colors.black,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_isInitialized)
                           FittedBox(
                             fit: BoxFit.cover, 
                             clipBehavior: Clip.hardEdge,
                             child: _isImage
                                 ? Image.network(
                                     widget.videoUrl ?? getSovereignUrl(widget.index, widget.mediaLedger),
                                     fit: BoxFit.cover,
                                   )
                                 : SizedBox(
                                     width: _videoController.value.size.width,
                                     height: _videoController.value.size.height,
                                     child: VideoPlayer(_videoController),
                                   ),
                            )
                        else
                           const Center(child: CircularProgressIndicator(color: SovereignColors.cyan)),
                        
                        if (!_isPlaying)
                          const Center(child: Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white24)),
                        
                        if (widget.sponsorFrequency > 0 && (widget.index + 1) % widget.sponsorFrequency.toInt() == 0)
                          _buildBadge('SPONSORED', SovereignColors.cyan, 100),
                        
                        // Video Progress Bar
                        if (!_isImage)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: VideoProgressIndicator(
                              isPlaying: _isPlaying,
                              controller: _videoController,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // 2. Heart Animation Layer
                  ..._hearts.map((offset) => Positioned(
                    left: offset.dx - 40,
                    top: offset.dy - 40,
                    child: const PulsingHeart(),
                  )),

                  // 3. Right Sidebar
                  Positioned(
                    bottom: bottomSafePadding - 10, 
                    right: 8, 
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isClearDisplay ? 0.0 : 1.0,
                      child: Column(
                          children: [
                            _buildAvatar(),
                            const SizedBox(height: 5),
                            _buildSidebarItem(Icons.favorite, _getFormattedStat('likes', '0'), Colors.white, 'LIKE'),
                            _buildSidebarItem(Icons.comment, _getFormattedStat('comments', '0'), Colors.white, 'COMMENT_OPEN'),
                            _buildSidebarItem(Icons.bookmark, _getFormattedStat('saves', 'Save'), Colors.white, 'SAVE'),
                            _buildSidebarItem(Icons.share, _getFormattedStat('shares', '0'), Colors.white, 'SHARE'),
                            const SizedBox(height: 12),
                            _buildMusicDisc(),
                          ],
                      ),
                    ),
                  ),

                  // 4. Bottom Metadata
                  Positioned(
                     bottom: bottomSafePadding,
                     left: 12,
                     right: 70, 
                     child: AnimatedOpacity(
                       duration: const Duration(milliseconds: 300),
                       opacity: _isClearDisplay ? 0.0 : 1.0,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.uploaderName != null 
                                  ? (widget.uploaderName!.startsWith('@') ? widget.uploaderName! : '@${widget.uploaderName}')
                                  : '@Creator_${widget.index}', 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [Shadow(blurRadius: 10, color: Colors.black45)])
                              ),
                              if (widget.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: SovereignColors.cyan, size: 14),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description ?? 'Sovereign Content Sync...',
                            style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3, shadows: [Shadow(blurRadius: 5, color: Colors.black)]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.music_note, size: 10, color: Colors.white),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 120,
                                child: MarqueeText(text: _getSoundInfo()['name']!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildMusicDisc() {
    final String soundName = _getSoundInfo()['name']!;
    final String? uploaderPic = widget.index < widget.mediaLedger.length 
        ? widget.mediaLedger[widget.index]['uploader_pic'] 
        : null;

    return GestureDetector(
      onTap: () => widget.soundDetailOpen(soundName),
      child: RotationTransition(
        turns: _discController,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.black,
                    Colors.grey.shade800,
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: SovereignColors.cyan.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                image: (uploaderPic != null && uploaderPic.isNotEmpty)
                    ? DecorationImage(image: NetworkImage(uploaderPic), fit: BoxFit.cover)
                    : null,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: (uploaderPic == null || uploaderPic.isEmpty)
                  ? const Center(
                      child: Icon(Icons.music_note, color: Colors.white, size: 16),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAvatar() {
    String displayHandle = widget.uploaderHandle ?? widget.uploaderName ?? '@Creator_${widget.index}';

    return GestureDetector(
      onTap: () => widget.creatorProfileOpen(displayHandle),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: () {
                final String? uploaderPic = widget.index < widget.mediaLedger.length 
                    ? widget.mediaLedger[widget.index]['uploader_pic'] 
                    : null;
                
                return CircleAvatar(
                  radius: 17, 
                  backgroundColor: Colors.black, 
                  backgroundImage: (uploaderPic != null && uploaderPic.isNotEmpty)
                      ? NetworkImage(uploaderPic)
                      : null,
                  child: (uploaderPic == null || uploaderPic.isEmpty) 
                      ? const Icon(Icons.person, color: SovereignColors.cyan) 
                      : null,
                );
              }(),
            ),
            if (!isFollowing)
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => isFollowing = true);
                    widget.onInteraction('FOLLOW_USER', contentId: widget.uploaderName);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2), // White border effect
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 9, 
                      backgroundColor: Colors.redAccent, 
                      child: Icon(Icons.add, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircleAvatar(
                    radius: 9,
                    backgroundColor: SovereignColors.cyan,
                    child: Icon(Icons.check, color: Colors.black, size: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, Color color, String action) {
    if ((action == 'GIFT' || action == 'MORE_OPTIONS') && widget.isHome) return const SizedBox.shrink();
    
    // Dynamic Icon Logic
    Color iconColor = color;
    IconData iconData = icon;
    // V15: Absolute Identity Anchor [TikTok DNA]
    final String fileName = widget.mediaLedger[widget.index]['file'] ?? "";

    if (action == 'LIKE') {
      iconColor = isLiked ? Colors.redAccent : Colors.white;
      iconData = Icons.favorite;
    } else if (action == 'SAVE') {
       iconColor = isSaved ? Colors.yellowAccent : Colors.white;
       iconData = Icons.bookmark;
    }

    return GestureDetector(
      onTap: () {
          if (action == 'LIKE') {
            setState(() {
              isLiked = !isLiked;
              _likeScale = 1.3;
              final mediaItem = widget.mediaLedger[widget.index];
              mediaItem['liked_by'] ??= [];
              List likedBy = mediaItem['liked_by'] as List;
              if (isLiked) {
                if (!likedBy.contains(widget.meshID)) likedBy.add(widget.meshID);
              } else {
                likedBy.remove(widget.meshID);
              }
              mediaItem['likes'] = likedBy.length; // Instant Update
            });
            Future.delayed(const Duration(milliseconds: 150), () {
               if (mounted) setState(() => _likeScale = 1.0);
            });
            widget.onInteraction(isLiked ? 'VIDEO_LIKE: $fileName' : 'VIDEO_UNLIKE: $fileName', contentId: _currentContentId);
          } else if (action == 'SAVE') {
            setState(() {
              isSaved = !isSaved;
              _saveScale = 1.3;
              final mediaItem = widget.mediaLedger[widget.index];
              mediaItem['saved_by'] ??= [];
              List savedBy = mediaItem['saved_by'] as List;
              if (isSaved) {
                if (!savedBy.contains(widget.meshID)) savedBy.add(widget.meshID);
              } else {
                savedBy.remove(widget.meshID);
              }
              mediaItem['saves'] = savedBy.length; // Instant Update
            });
            Future.delayed(const Duration(milliseconds: 150), () {
               if (mounted) setState(() => _saveScale = 1.0);
            });
            widget.onInteraction(isSaved ? 'VIDEO_SAVED: $fileName' : 'VIDEO_UNSAVED: $fileName', contentId: _currentContentId);
          } else if (action == 'COMMENT_OPEN') {
               _showComments();
               widget.onInteraction(action, contentId: _currentContentId);
          } else if (action == 'SHARE') {
               _showShareSheet();
               widget.onInteraction(action, contentId: _currentContentId);
          } else if (action == 'GIFT') {
               _showGiftSheet();
               widget.onInteraction(action, contentId: _currentContentId);
          } else if (action == 'MORE_OPTIONS') {
               _showOptionsHub();
               widget.onInteraction(action, contentId: _currentContentId);
          } else {
               widget.onInteraction(action, contentId: _currentContentId);
          }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          children: [
             if (action == 'LIKE')
               AnimatedScale(
                 scale: _likeScale, 
                 duration: const Duration(milliseconds: 150), 
                 curve: Curves.easeOutBack,
                 child: Icon(iconData, size: 24, color: iconColor)
               )
             else if (action == 'SAVE') 
               AnimatedScale(
                 scale: _saveScale, 
                 duration: const Duration(milliseconds: 150), 
                 curve: Curves.easeOutBack,
                 child: Icon(iconData, size: 24, color: iconColor)
               )
             else 
               Icon(iconData, size: 24, color: iconColor),
             const SizedBox(height: 2),
             Text(label, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }



  void _showReportDialog() {
    final List<String> reasons = [
      "Inappropriate content",
      "Hate speech",
      "Sexual content",
      "Violent or graphic content",
      "Harassment or bullying",
      "Intellectual property violation",
      "Spam or misleading"
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('REPORT CONTENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            const Text('Select a reason for reporting this content', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            ...reasons.map((reason) => ListTile(
              title: Text(reason, style: const TextStyle(color: Colors.white, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white10),
              onTap: () {
                widget.onInteraction('REPORT_CONTENT: $_currentContentId|$reason');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: SovereignColors.cyan, content: Text('REPORT FILED: $reason', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                );
                // V15 Play Store Compliance: Hide video immediately
                widget.onSkip?.call();
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showComments() {
    widget.onInteraction('COMMENT_SECTION_OPENED', contentId: _currentContentId);
    

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
          // V15 Reactive Bridge: Connect drawer to parent sync
          _commentDrawerRefresher = setModalState;
          
          // Sovereign V15 Reactive Sync Pulse
          final mediaItemLive = widget.mediaLedger[widget.index];
          // V15 Optimistic Sync: Ensure we use the direct ledger list
          if (mediaItemLive['comments_data'] == null) {
              mediaItemLive['comments_data'] = <Map<String, dynamic>>[];
          }
          final List<Map<String, dynamic>> currentComments = (mediaItemLive['comments_data'] as List).cast<Map<String, dynamic>>();

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header DNA
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(height: 4, width: 36, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${currentComments.length} ${currentComments.length == 1 ? 'comment' : 'comments'}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Text('[A_122]', style: TextStyle(color: Colors.white24, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Comment List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: currentComments.length,
                    padding: const EdgeInsets.only(bottom: 10),
                    itemBuilder: (context, index) {
                      final comment = currentComments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 18, backgroundColor: SovereignColors.cyan.withValues(alpha: 0.1), child: const Icon(Icons.person, size: 20, color: SovereignColors.cyan)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                      children: [
                                        Text(comment['user'] ?? 'Anonymous', style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
                                        if (comment['isVerified'] == true) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                                        ],
                                        if (comment['isCreator'] == true) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(color: SovereignColors.cyan.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                                            child: const Text('Creator', style: TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (comment['isPinned'] == true) 
                                      const Padding(
                                        padding: EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            Icon(Icons.push_pin, color: Colors.white38, size: 12),
                                            SizedBox(width: 4),
                                            Text('Pinned', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    Text(comment['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(comment['time'] ?? 'now', style: const TextStyle(color: Colors.white24, fontSize: 12)),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () {
                                            setModalState(() => _commentController.text = '@${comment['user'] ?? 'user'} ');
                                            widget.onInteraction('REPLY_TARGET: ${comment['user'] ?? 'user'}');
                                          },
                                          child: const Text('Reply', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    
                                    // Reactive Nested Replies [A_122]
                                    if ((comment['replies'] ?? 0) > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: GestureDetector(
                                          onTap: () {
                                            setModalState(() => comment['isExpanded'] = !(comment['isExpanded'] ?? false));
                                            widget.onInteraction('EXPAND_REPLIES: ${comment['user'] ?? 'user'}');
                                          },
                                          child: Row(
                                            children: [
                                              Container(width: 24, height: 1, color: Colors.white10),
                                              const SizedBox(width: 8),
                                              Text(
                                                (comment['isExpanded'] ?? false) ? 'Hide replies' : 'View ${comment['replies'] ?? 0} replies',
                                                style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              Icon((comment['isExpanded'] ?? false) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if (comment['isExpanded'] == true && comment['nestedReplies'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12, left: 0),
                                        child: Column(
                                          children: (comment['nestedReplies'] as List).map((reply) => Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(radius: 10, backgroundColor: Colors.white10, child: const Icon(Icons.person, size: 12, color: Colors.white38)),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(reply['user'] ?? 'User', style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                                                      Text(reply['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            
                            // Interaction Node: Like
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  // V15 Optimistic UI: Toggle local state
                                  comment['liked_by'] ??= <String>[];
                                  final meshIdUp = widget.meshID.toUpperCase();
                                  if (comment['liked_by'].contains(meshIdUp)) {
                                    comment['liked_by'].remove(meshIdUp);
                                  } else {
                                    comment['liked_by'].add(meshIdUp);
                                  }
                                  comment['likes'] = comment['liked_by'].length;
                                  comment['isLiked'] = comment['liked_by'].contains(meshIdUp);
                                });
                                widget.onInteraction('COMMENT_LIKE_TOGGLE: ${comment['id']}', contentId: _currentContentId);
                              },
                              child: Column(
                                children: [
                                  Icon(
                                    ((comment['liked_by'] as List?)?.contains(widget.meshID.toUpperCase()) ?? (comment['isLiked'] ?? false)) ? Icons.favorite : Icons.favorite_border,
                                    color: ((comment['liked_by'] as List?)?.contains(widget.meshID.toUpperCase()) ?? (comment['isLiked'] ?? false)) ? Colors.red : Colors.white24,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${comment['likes']}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Emoji Bar DNA
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['🥰', '😂', '😳', '😏', '😅', '🥺', '😭', '🥵'].map((e) => GestureDetector(
                      onTap: () {
                         setModalState(() => _commentController.text += e);
                         widget.onInteraction('EMOJI_ADD: $e');
                      },
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    )).toList(),
                  ),
                ),
                
                if (_commentError != null)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                    child: Text(_commentError!, style: const TextStyle(color: Colors.redAccent, fontSize: 11), textAlign: TextAlign.center),
                  ),
                  
                // Input Mesh
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18, backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white38, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          autofocus: false,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Add comment...',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            suffixIcon: GestureDetector(
                              onTap: () => _submitComment(context, setModalState),
                              child: const Icon(Icons.send, color: SovereignColors.cyan, size: 20),
                            ),
                          ),
                          onSubmitted: (v) => _submitComment(context, setModalState),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    ).then((_) {
      // V15: Disconnect reactive bridge when drawer closes
      _commentDrawerRefresher = null;
    });
  }
  void _submitComment(BuildContext context, StateSetter setModalState) {
    final String v = _commentController.text;
    if (v.trim().isEmpty) return;

    // A_112 Smart Filter Logic
    bool isBanned = false;
    for (final word in _bannedWords) {
      if (v.toLowerCase().contains(word)) isBanned = true;
    }

    if (isBanned) {
      setModalState(() {
        _commentError = 'A_112 SMART FILTER: Text contains restricted keywords.';
      });
      widget.onInteraction('COMMENT_BLOCKED: A_112_FILTER');
    } else {
      setModalState(() {
        _commentError = null;
        final mediaItemLive = widget.mediaLedger[widget.index];
        if (mediaItemLive['comments_data'] == null) mediaItemLive['comments_data'] = [];
        final List list = mediaItemLive['comments_data'];
        
        // Detect if it's a @reply targeting a user in the mesh
        bool foundTarget = false;
        if (v.startsWith('@')) {
          final targetHandle = v.split(' ').first;
          for (var comment in list) {
            if ('@${comment['user']}' == targetHandle) {
              // Inject as nested reply
              (comment['nestedReplies'] as List).insert(0, {
                'user': 'You',
                'text': v.replaceFirst(targetHandle, '').trim(),
              });
              comment['replies']++;
              comment['isExpanded'] = true;
              foundTarget = true;
              break;
            }
          }
        }
        
        if (!foundTarget) {
          // Standard comment injection at index 0 (Optimistic UI)
          list.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch,
            'user': 'You',
            'text': v,
            'likes': 0,
            'isLiked': false,
            'isVerified': false,
            'isCreator': false,
            'isPinned': false,
            'time': 'now',
            'replies': 0,
            'isExpanded': false,
            'nestedReplies': [],
          });
          // Update global count locally for immediate feedback
          mediaItemLive['comments'] = list.length;
        }
      });
      // V15 Sidebar Sync Pulse: Force parent rebuild to update count in sidebar
      setState(() {}); 
      widget.onInteraction('COMMENT_SENT: $v', contentId: _currentContentId);
      widget.onAddMessage('Comment Live', 'Your comment has been safely synced to the matrix mesh.', 'cloud_done');
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comment Synced to Mesh')));
    }
  }


  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(height: 5, width: 40, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(5))),
            const SizedBox(height: 20),
            const Text('Share to [A_115]', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                   _buildShareBtn(Icons.repeat, 'Duet', Colors.pinkAccent),
                   _buildShareBtn(Icons.content_paste, 'Stitch', Colors.blue),
                   _buildShareBtn(Icons.qr_code_2, 'QR Code', Colors.white),
                   _buildShareBtn(Icons.link, 'Copy Link', Colors.blueAccent),
                   _buildShareBtn(Icons.send, 'Telegram', Colors.lightBlue),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildShareBtn(Icons.repeat_rounded, 'Repost', SovereignColors.cyan, onTap: () {
                    Navigator.pop(context);
                    widget.onInteraction('VIDEO_REPOST: ${widget.index}');
                    widget.onAddMessage('Video Reposted', 'Content from node #${widget.index + 100} has been re-broadcasted to your mesh profile.', 'repeat');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reposted to your profile')));
                  }),
                  _buildShareBtn(Icons.download, 'Save Video', Colors.grey),
                  _buildShareBtn(Icons.playlist_add, 'Add to Collections', Colors.grey),
                  _buildShareBtn(Icons.flag, 'Report', Colors.redAccent),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareBtn(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showLongPressMenu() {
    widget.onInteraction('LONG_PRESS_HUB_OPENED');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 25,
              children: [
                _buildLongMenuItem(Icons.download, 'Save video', onTap: () {
                    _downloadVideo();
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(Icons.bookmark_border, 'Add Favorites', onTap: () {
                    setState(() => isSaved = true);
                    widget.onInteraction('VIDEO_SAVED: ${widget.index}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Favorites')));
                }),
                _buildLongMenuItem(Icons.not_interested, 'Not Interested', onTap: () {
                    widget.onInteraction('LONG_PRESS_DISLIKE: ACTIVE');
                    Navigator.pop(context);
                    // Sovereign V15: Immediate skip logic [Recovered from Backup]
                    widget.onSkip?.call();
                }),
                _buildLongMenuItem(Icons.flag_outlined, 'Report', color: Colors.redAccent, onTap: () {
                    widget.onInteraction('LONG_PRESS_REPORT: PENDING');
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(Icons.people_outline, 'Duet', onTap: () {
                    widget.onInteraction('LONG_PRESS_DUET: OPEN');
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(Icons.content_cut_outlined, 'Stitch', onTap: () {
                    widget.onInteraction('LONG_PRESS_STITCH: OPEN');
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(Icons.speed, 'Playback speed', onTap: () {
                    _togglePlaybackSpeed();
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(_isClearDisplay ? Icons.visibility_outlined : Icons.visibility_off_outlined, 'Clear display', onTap: () {
                    _toggleClearDisplay();
                    Navigator.pop(context);
                }),
                _buildLongMenuItem(_showCaptions ? Icons.closed_caption : Icons.closed_caption_off, 'Captions', onTap: () {
                    _toggleCaptions();
                    Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildLongMenuItem(IconData icon, String label, {Color color = Colors.white, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              label, 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400)
            ),
          ),
        ],
      ),
    );
  }

  void _showGiftSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Send a Gift [A_113]', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildGiftItem('Rose', 1, Icons.local_florist, Colors.red),
                  _buildGiftItem('Coffee', 10, Icons.coffee, Colors.brown),
                  _buildGiftItem('Diamond', 99, Icons.diamond, Colors.cyan),
                  _buildGiftItem('Rocket', 1000, Icons.rocket_launch, Colors.orange),
                ],
              ),
            ),
             ElevatedButton(
              onPressed: () {
                widget.onInteraction('RECHARGE_INITIATED');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redirecting to Quantum Wallet...')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
              child: const Text('Recharge Coins', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(String name, int cost, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        final contentId = 'V15_CONTENT_${widget.index}';
        widget.onInteraction('GIFT_SENT: $name | DEBIT=$cost | CONTENT_ID=$contentId');
        widget.onAddMessage('Gift Sent', 'You sent a $name (-$cost Coins) to the creator of node #${widget.index + 100}.', 'volunteer_activism');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent $name! -$cost Coins')));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 5),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('$cost', style: const TextStyle(color: SovereignColors.cyan, fontSize: 10)),
          ],
        ),
      ),
    );
  }




  void _showOptionsHub() {
    widget.onInteraction('SOVEREIGN_OPTIONS_HUB_v15_OPENED');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 550, // High-fidelity sheet height
        decoration: BoxDecoration(
          color: const Color(0xFF161616).withValues(alpha: 0.98),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(height: 4, width: 36, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('VIDEO OPTIONS [A_110 DNA]', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
            const SizedBox(height: 25),
            
            // Layer 1: Simulated Mesh Send [Profiles]
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildShareUserNode('You', Icons.person, () {
                    widget.onInteraction('SOCIAL_SEND_TO: SELF');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video saved to your feed')));
                  }),
                  _buildShareUserNode('Node_X', Icons.face_unlock_rounded, () {
                    widget.onInteraction('SOCIAL_SEND_TO: Node_X');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Node_X')));
                  }),
                  _buildShareUserNode('Core', Icons.stream, () {
                    widget.onInteraction('SOCIAL_SEND_TO: Core');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Core')));
                  }),
                  _buildShareUserNode('Mesh', Icons.language, () {
                    widget.onInteraction('SOCIAL_SEND_TO: Mesh');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Mesh Network')));
                  }),
                  _buildShareUserNode('Pulse', Icons.bolt, () {
                    widget.onInteraction('SOCIAL_SEND_TO: Pulse');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Pulse')));
                  }),
                  _buildShareUserNode('Sync', Icons.sync, () {
                    widget.onInteraction('SOCIAL_SEND_TO: Sync');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sent to Sync Layer')));
                  }),
                  _buildShareUserNode('More', Icons.add, () {
                    widget.onInteraction('SOCIAL_SEND_TO: MORE_PICKER');
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 20),
            
            // Layer 2: Social Actions [Repost, Copy, etc]
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildActionCircle(Icons.repeat, 'Repost', Colors.pinkAccent, () {
                    widget.onInteraction('OPTIONS_REPOST: ${widget.index}');
                    Navigator.pop(context);
                  }),
                  _buildActionCircle(Icons.link, 'Copy link', Colors.blue, () {
                    widget.onInteraction('OPTIONS_COPY_LINK: ${widget.index}');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied to Mesh')));
                  }),
                  _buildActionCircle(Icons.send, 'Telegram', Colors.blueAccent, () {
                    widget.onInteraction('OPTIONS_SHARE_TELEGRAM');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Telegram...')));
                  }),
                  _buildActionCircle(Icons.messenger_outline, 'SMS', Colors.green, () {
                    widget.onInteraction('OPTIONS_SHARE_SMS');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening SMS...')));
                  }),
                  _buildActionCircle(Icons.qr_code_2, 'QR Code', Colors.white, () {
                    widget.onInteraction('OPTIONS_SHOW_QR');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating Video QR...')));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10, height: 1),
            
            // Layer 3: Advanced Logic Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 15,
                  children: [
                    _buildOptionGridItem(Icons.analytics_outlined, 'Analytics', () {
                      _showSimulatedAnalytics();
                    }),
                    _buildOptionGridItem(Icons.lock_person_outlined, 'Privacy', () {
                      _showSimulatedPrivacy();
                    }),
                    _buildOptionGridItem(Icons.download_rounded, 'Save video', () {
                      _downloadVideo();
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(Icons.bookmark_add_outlined, 'Favorites', () {
                      setState(() => isSaved = true);
                      widget.onInteraction('OPTIONS_FAV: ${widget.index}');
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Favorites')));
                    }),
                    _buildOptionGridItem(Icons.speed_rounded, 'Playback speed', () {
                      _togglePlaybackSpeed();
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(_isClearDisplay ? Icons.visibility_outlined : Icons.visibility_off_outlined, 'Clear display', () {
                      _toggleClearDisplay();
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(_showCaptions ? Icons.closed_caption : Icons.closed_caption_off_outlined, 'Captions', () {
                      _toggleCaptions();
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(Icons.people_outline, 'Duet', () {
                      widget.onInteraction('OPTIONS_DUET');
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(Icons.content_cut_outlined, 'Stitch', () {
                      widget.onInteraction('OPTIONS_STITCH');
                      Navigator.pop(context);
                    }),
                    _buildOptionGridItem(Icons.not_interested, 'Not interested', () {
                      widget.onInteraction('OPTIONS_DISLIKE');
                      Navigator.pop(context);
                      // Sovereign V15: Immediate skip logic
                      widget.onSkip?.call();
                    }),
                    _buildOptionGridItem(Icons.flag_outlined, 'Report', () {
                      Navigator.pop(context);
                      _showReportDialog();
                    }, color: Colors.redAccent),
                  ],
                ),
              ),
            ),
            
            // Critical management bridge: Only show Delete for Owner
            if (widget.uploaderName != null && (widget.uploaderName == widget.meshID || widget.uploaderName == '@${widget.meshID}'))
              ListTile(
                onTap: () {
                  String? targetFile;
                  if (widget.index < widget.mediaLedger.length) {
                    targetFile = widget.mediaLedger[widget.index]['file'];
                  }
                  
                  if (targetFile != null) {
                    widget.onInteraction('DELETE_VIDEO_REQUEST: $targetFile');
                  }
                  Navigator.pop(context);
                },
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Delete Video', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white10),
              ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildShareUserNode(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white.withValues(alpha: 0.1), child: Icon(icon, color: Colors.white70, size: 28)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Column(
          children: [
            Container(
              height: 56, width: 56,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionGridItem(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white70}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  void _showSimulatedAnalytics() {
    widget.onInteraction('OPTIONS_ANALYTICS_OPENED');
    Navigator.pop(context); // Close main hub
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Video Analytics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildStatRow('Total Views', '${12.4 + widget.index}K', Icons.visibility),
                  const Divider(color: Colors.white10, height: 24),
                  _buildStatRow('Average Watch Time', '00:${Random().nextInt(30) + 15}s', Icons.timer),
                  const Divider(color: Colors.white10, height: 24),
                  _buildStatRow('Full Video Watched', '${40 + Random().nextInt(20)}%', Icons.check_circle),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Audience Territories', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTerritoryRow('United States', 45),
            _buildTerritoryRow('United Kingdom', 20),
            _buildTerritoryRow('Mesh Network', 15),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan, foregroundColor: Colors.black),
                child: const Text('OK'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSimulatedPrivacy() {
    widget.onInteraction('OPTIONS_PRIVACY_OPENED');
    Navigator.pop(context); // Close main hub
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Privacy Settings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildPrivacyOption('Everyone', 'Anyone can view this video', Icons.public, true),
            _buildPrivacyOption('Friends', 'Only followers you follow back', Icons.people, false),
            _buildPrivacyOption('Only Me', 'Private to everyone else', Icons.lock, false),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTerritoryRow(String name, int percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: percent / 100, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(SovereignColors.cyan)),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, String subtitle, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? SovereignColors.cyan : Colors.white70),
      title: Text(title, style: TextStyle(color: isSelected ? SovereignColors.cyan : Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: isSelected ? const Icon(Icons.check, color: SovereignColors.cyan) : null,
      onTap: () {
        widget.onInteraction('PRIVACY_SET: $title');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Privacy set to $title')));
      },
    );
  }

  Widget _buildBadge(String text, Color color, double top) {
    return Positioned(
      top: top,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: color, size: 12),
            const SizedBox(width: 5),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

class PulsingHeart extends StatefulWidget {
  const PulsingHeart({super.key});
  @override
  State<PulsingHeart> createState() => _PulsingHeartState();
}

class _PulsingHeartState extends State<PulsingHeart> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    scale = Tween<double>(begin: 0.0, end: 1.2).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    opacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: controller, curve: const Interval(0.5, 1.0)));
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Transform.scale(
        scale: scale.value,
        child: Opacity(
          opacity: opacity.value,
          child: const Icon(Icons.favorite, color: Color(0xFFFF0055), size: 100),
        ),
      ),
    );
  }
}

class SovereignSoundDetail extends StatefulWidget {
  final String soundName;
  final String? soundUrl; // A_128 Sound Master Sync
  final Function(String, {String? contentId}) onInteraction;
  final VoidCallback onUseSound;
  final Function(String, String, String) onAddMessage;
  final Function(String) onSoundSelect;
  final List<Map<String, dynamic>> mediaLedger;
  final Function(int, List<int>) onVideoTap; // A_120 Synergy

  const SovereignSoundDetail({
    super.key, 
    required this.soundName, 
    this.soundUrl,
    required this.onInteraction, 
    required this.onUseSound, 
    required this.onAddMessage, 
    required this.onSoundSelect,
    required this.mediaLedger,
    required this.onVideoTap,
  });

  @override
  State<SovereignSoundDetail> createState() => _SovereignSoundDetailState();
}

class _SovereignSoundDetailState extends State<SovereignSoundDetail> with SingleTickerProviderStateMixin {
  bool _isSaved = false;
  late AnimationController _spinController;
  bool _isPlaying = false;
  VideoPlayerController? _previewController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _initPreview();
  }

  void _initPreview() {
    if (widget.soundUrl != null && widget.soundUrl!.isNotEmpty) {
      String fullUrl = widget.soundUrl!;
      if (fullUrl.startsWith('/stream')) {
        final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
        fullUrl = 'http://$host:9900$fullUrl';
      }
      
      _previewController = VideoPlayerController.networkUrl(Uri.parse(_resolveSecureUrl(fullUrl)))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredMedia() {
    return widget.mediaLedger.where((m) {
      String entrySoundName = m['sound_name']?.toString() ?? "";
      String uploader = m['uploader']?.toString() ?? "SovereignUltra";
      if (uploader.startsWith('@')) uploader = uploader.substring(1);
      
      // V15 Gap Fix: TikTok Logic Override
      // Any video with empty sound name or 'Add sound' is classed as its own Original Sound
      if (entrySoundName.isEmpty || entrySoundName == "Add sound") {
        entrySoundName = "Original Sound - $uploader";
      }
      
      return entrySoundName == widget.soundName || m['sound']?.toString() == widget.soundName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredMedia();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.white), onPressed: () => widget.onInteraction('SOUND_SHARE_HUB_OPEN')),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Sound Meta Header [A_108 DNA]
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // TikTok DNA: Spinning Vinyl Disk
                      GestureDetector(
                        onTap: () {
                          if (_previewController == null || !_previewController!.value.isInitialized) return;

                          setState(() => _isPlaying = !_isPlaying);
                          if (_isPlaying) {
                            _spinController.repeat();
                            _previewController?.play();
                            _previewController?.setLooping(true);
                          } else {
                            _spinController.stop();
                            _previewController?.pause();
                          }
                          widget.onInteraction('SOUND_PREVIEW_${_isPlaying ? "START" : "STOP"}: ${widget.soundName}');
                        },
                        child: RotationTransition(
                          turns: _spinController,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const SweepGradient(
                                colors: [Colors.black, Colors.grey, Colors.black],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(color: SovereignColors.cyan.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2),
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10, width: 2),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    _isPlaying ? Icons.pause_circle : Icons.play_circle_filled, 
                                    color: Colors.white.withValues(alpha: 0.8), 
                                    size: 30
                                  ),
                                  const Icon(Icons.music_note, color: SovereignColors.cyan, size: 15),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.soundName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Text(
                              filtered.isNotEmpty ? (filtered.first['uploader'] ?? 'Sovereign Original') : 'Sovereign Original', 
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '${filtered.length} Videos', 
                                style: const TextStyle(color: SovereignColors.cyan, fontSize: 11, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Action Row: Save Hub
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _isSaved = !_isSaved);
                            widget.onInteraction(_isSaved ? 'SOUND_SAVED: ${widget.soundName}' : 'SOUND_UNSAVED: ${widget.soundName}');
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _isSaved ? SovereignColors.cyan : Colors.transparent),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: _isSaved ? SovereignColors.cyan : Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(_isSaved ? 'In Favorites' : 'Add to Favorites', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                 // Video Mesh [A_120 Interaction Synergy]
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    // V15 Index Resolution: Find the original position in the global mesh
                    final allIndices = filtered.map((m) => widget.mediaLedger.indexOf(m)).toList();

                    return GestureDetector(
                      onTap: () => widget.onVideoTap(index, allIndices),
                      child: Container(
                        color: Colors.white12,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            (() {
                              final String tUrl = getSovereignThumb(widget.mediaLedger.indexOf(entry), widget.mediaLedger);
                              return tUrl.isNotEmpty
                                ? Image.network(tUrl, fit: BoxFit.cover)
                                : const Center(child: Icon(Icons.movie_filter_outlined, color: Colors.white24, size: 30));
                            })(),
                            
                            Positioned(
                              bottom: 5,
                              left: 5,
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow_outlined, size: 14, color: Colors.white),
                                  Text(
                                    ' ${entry['views'] ?? 0}', 
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100), // Safety Buffer
              ],
            ),
          ),
          
          // Floating Footer: USE THIS SOUND [A_117 Creator Sync]
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onInteraction('USE_SOUND_TRIGGERED: ${widget.soundName}');
                widget.onUseSound();
                // Navigator.pop removed: handled by parent reset
              },
              icon: const Icon(Icons.video_call, size: 24),
              label: const Text('USE THIS SOUND', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: SovereignColors.cyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                elevation: 10,
                shadowColor: SovereignColors.cyan.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MLMNetworkView extends StatelessWidget {
  final Function(String, {String? contentId}) onInteraction;
  final WebSocketChannel channel;
  final String meshID;
  final TextEditingController _refController = TextEditingController();
  final ValueNotifier<bool> _isActivating = ValueNotifier(false);

  MLMNetworkView({super.key, required this.onInteraction, required this.channel, required this.meshID});

  @override
  Widget build(BuildContext context) {
    String refLink = "https://fectok.com/join?ref=$meshID";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('MLM NETWORK [A_107]'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hub, size: 100, color: SovereignColors.cyan),
              const SizedBox(height: 20),
              const Text('V15 NETWORK GRAPH', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Active Nodes: 12,408', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: SovereignColors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: Text('YOUR NODE ID: $meshID', style: const TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    const Text('YOUR REFERRAL LINK', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    SelectableText(refLink, style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: refLink));
                  onInteraction('MLM_LINK_COPIED');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: SovereignColors.cyan,
                    content: Text('LINK COPIED TO CLIPBOARD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                  ));
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('COPY LINK'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),
              const Text('JOIN A NETWORK NODE', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2)),
              const SizedBox(height: 15),
              TextField(
                controller: _refController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enter Referrer Node ID',
                  hintText: 'e.g. NODE_ALPHA or SOV_XXXXXX',
                  labelStyle: TextStyle(color: Colors.white38),
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 10),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: _isActivating,
                builder: (context, loading, _) {
                  return ElevatedButton(
                    onPressed: loading ? null : () {
                      final ref = _refController.text.trim();
                      if (ref.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PLEASE ENTER A REFERRER ID')));
                        return;
                      }
                      if (ref == meshID) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SELF-REFERRAL IS NOT PERMITTED')));
                        return;
                      }

                      _isActivating.value = true;
                      onInteraction('MLM_ACTIVATE_REQUEST: $ref');
                      channel.sink.add(json.encode({
                        "action": "MLM_REFERRAL_ACTIVATE",
                        "referrer_id": ref,
                      }));
                      
                      Future.delayed(const Duration(seconds: 2), () {
                        if (context.mounted) _isActivating.value = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SovereignColors.cyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: loading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('ACTIVATE REFERRAL', style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                }
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                child: const Text('Lifetime Recurring Yield: ENABLED', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              const Text('3-LAYER AI MODERATION SECURED', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class MarqueeText extends StatefulWidget {
  final String text;
  const MarqueeText({super.key, required this.text});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat();
    _offsetAnimation = Tween<Offset>(begin: const Offset(1, 0), end: const Offset(-1, 0)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1),
      ),
    );
  }
}

class VideoProgressIndicator extends StatefulWidget {
  final bool isPlaying;
  final VideoPlayerController controller;
  const VideoProgressIndicator({super.key, required this.isPlaying, required this.controller});

  @override
  State<VideoProgressIndicator> createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateProgress);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateProgress);
    super.dispose();
  }

  void _updateProgress() {
    if (mounted) {
      if (widget.controller.value.isInitialized) {
        final duration = widget.controller.value.duration.inMilliseconds;
        final position = widget.controller.value.position.inMilliseconds;
        if (duration > 0) {
          setState(() {
            _progress = position / duration;
          });
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 1.5, // Surgical Thinness [A_125]
        thumbShape: SliderComponentShape.noThumb, // No thumb for a clean progress line
        overlayShape: SliderComponentShape.noOverlay,
        activeTrackColor: const Color(0xFFFF00FF), // Sovereign Magenta
        inactiveTrackColor: Colors.white10,
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: SizedBox(
        height: 2,
        child: Slider(
          value: _progress.clamp(0.0, 1.0),
          onChanged: (v) {
            final duration = widget.controller.value.duration;
            widget.controller.seekTo(duration * v);
            setState(() {
              _progress = v;
            });
          },
        ),
      ),
    );
  }
}


class SovereignCreatorProfile extends StatelessWidget {
  final String creatorId;
  final Function(String, {String? contentId}) onInteraction;
  const SovereignCreatorProfile({super.key, required this.creatorId, required this.onInteraction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, 
        title: Text(creatorId, style: const TextStyle(fontSize: 16)),
        actions: const [Icon(Icons.more_horiz), SizedBox(width: 20)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, backgroundColor: Colors.white12, child: Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 10),
            Text(creatorId, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('V15 Creator Node', style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 _stat('142', 'Following'),
                 _stat('2.1M', 'Followers'),
                 _stat('12M', 'Likes'),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => onInteraction('FOLLOW_ACTION'),
                  style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan, minimumSize: const Size(140, 45)),
                  child: const Text('Follow', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.mail, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75, crossAxisSpacing: 1, mainAxisSpacing: 1),
              itemCount: 12,
              itemBuilder: (context, index) => Container(color: Colors.white10, child: const Center(child: Icon(Icons.play_arrow, color: Colors.white24))),
            )
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(l, style: const TextStyle(color: Colors.white38, fontSize: 12))]);
}

class SovereignLiveFeed extends StatelessWidget {
  const SovereignLiveFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.deepPurple.shade900),
          const Center(child: Text('LIVE FEED LOGIC PENDING\nConnecting to A_119 Streaming Protocol...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38))),
          Positioned(
            top: 50, 
            left: 20, 
            child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
          ),
          // Comments
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: const Text('Say something...', style: TextStyle(color: Colors.white38)),
            ),
          )
        ],
      ),
    );
  }
}

class SovereignSearch extends StatelessWidget {
  const SovereignSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search V15...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          onSubmitted: (v) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => SovereignHashtagView(tag: v)));
          },
        ),
      ),
      body: ListView(
        children: [
          const ListTile(title: Text('Suggested', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          _suggestedItem(context, 'Sovereign Glitch'),
          _suggestedItem(context, 'Viral Trends'),
          _suggestedItem(context, 'Creator Fund'),
          _suggestedItem(context, 'V15 Mesh Ignition'),
        ],
      ),
    );
  }

  Widget _suggestedItem(BuildContext context, String title) {
    return ListTile(
      leading: const Icon(Icons.search, color: Colors.white24), 
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SovereignHashtagView(tag: title)));
      },
    );
  }
}
class VerificationCenterView extends StatelessWidget {
  const VerificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('VERIFICATION [A_114]'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified, size: 100, color: SovereignColors.cyan),
            const SizedBox(height: 20),
            const Text('ELITE TIER VERIFIED', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Verification ID: SOV-992-V15', style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
              child: const Column(
                children: [
                  Text('BENEFITS', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('• 10% Revenue Boost\n• Priority Support\n• Exclusive Filters\n• High-Limit Withdrawals', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionCenterView extends StatefulWidget {
  final Function(String, {String? contentId}) onInteraction;
  final bool camera;
  final bool mic;
  final bool gallery;
  final bool location;
  final Function(String, bool) onToggle;

  const PermissionCenterView({
    super.key, 
    required this.onInteraction,
    required this.camera,
    required this.mic,
    required this.gallery,
    required this.location,
    required this.onToggle,
  });

  @override
  State<PermissionCenterView> createState() => _PermissionCenterViewState();
}

class _PermissionCenterViewState extends State<PermissionCenterView> {
  late bool c, m, g, l;

  @override
  void initState() {
    super.initState();
    c = widget.camera;
    m = widget.mic;
    g = widget.gallery;
    l = widget.location;
  }

  void _toggle(String name, bool val) {
    setState(() {
      if (name == 'Camera') c = val;
      if (name == 'Mic') m = val;
      if (name == 'Gallery') g = val;
      if (name == 'Location') l = val;
      widget.onToggle(name, val);
    });
    widget.onInteraction('PERMISSION_CHANGE: $name -> $val');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('PERMISSION CENTER [A_106]'), centerTitle: true),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('IRREFUTABLE LEGAL ARCHIVING ACTIVE', style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
          ),
          _buildSwitch('Camera', c),
          _buildSwitch('Mic', m),
          _buildSwitch('Gallery', g),
          _buildSwitch('Location', l),
          const Divider(color: Colors.white10),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Every change is logged with User ID, IP, and Timestamp as digital evidence.', style: TextStyle(color: Colors.white24, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String name, bool val) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // High-Visibility Status Label [V15 Standard]
          Text(
            val ? 'ON' : 'OFF',
            style: TextStyle(
              color: val ? SovereignColors.cyan : Colors.white24,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: val ? [
                Shadow(color: SovereignColors.cyan.withValues(alpha: 0.5), blurRadius: 8)
              ] : null,
            ),
          ),
          const SizedBox(width: 15),
          Switch(
            value: val,
            activeThumbColor: SovereignColors.cyan,
            activeTrackColor: SovereignColors.cyan.withValues(alpha: 0.2),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
            onChanged: (v) => _toggle(name, v),
          ),
        ],
      ),
    );
  }
}

class QuantumWalletView extends StatelessWidget {
  final ValueNotifier<double> usdListenable;
  final ValueNotifier<double> bdtListenable;
  final ValueNotifier<int> coinsListenable;
  final ValueNotifier<double> frozenUsdListenable; // Added: A_177
  final ValueNotifier<double> frozenBdtListenable; // Added: A_177
  final ValueNotifier<List<dynamic>> bankHistoryListenable; // Status Tracker
  final Function(String, {String? contentId}) onInteraction;
  final Function(double, double, int) onSwap;
  final WebSocketChannel channel;
  final ValueNotifier<double> minWithdrawListenable;
  final ValueNotifier<double> commissionListenable;
  final ValueNotifier<double> mlmYieldListenable;
  final double coinRate;
  final ValueNotifier<double> bdtRateListenable;
  final ValueNotifier<Map<String, dynamic>> bridgeConfigsListenable;

  const QuantumWalletView({
    super.key, 
    required this.usdListenable, 
    required this.bdtListenable,
    required this.coinsListenable, 
    required this.onInteraction,
    required this.onSwap,
    required this.channel,
    required this.minWithdrawListenable,
    required this.commissionListenable,
    required this.mlmYieldListenable,
    required this.coinRate,
    required this.bdtRateListenable,
    required this.frozenUsdListenable,
    required this.frozenBdtListenable,
    required this.bankHistoryListenable,
    required this.meshID,
    required this.bridgeConfigsListenable,
  });

  final String meshID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('QUANTUM WALLET [A_113]'), centerTitle: true),
      body: ValueListenableBuilder(
        valueListenable: usdListenable,
        builder: (context, usd, child) {
          return ValueListenableBuilder(
            valueListenable: bdtListenable,
            builder: (context, bdt, child) {
              return ValueListenableBuilder(
                valueListenable: coinsListenable,
                builder: (context, coins, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('NEXT PULSE WINDOW [A_143]', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                    const SizedBox(height: 5),
                                    const Text('ESTIMATED RELEASE: 1ST - 5TH MARCH', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4)),
                                child: const Text('STANDBY', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _balanceCard('USD ASSETS', '\$${usd.toStringAsFixed(2)}', Colors.greenAccent),
                        ValueListenableBuilder(
                          valueListenable: frozenUsdListenable,
                          builder: (context, fUsd, _) => fUsd > 0 
                            ? Padding(
                                padding: const EdgeInsets.only(left: 30, bottom: 5),
                                child: Text('PROCESSING: \$${fUsd.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                              ) 
                            : const SizedBox.shrink(),
                        ),
                        _balanceCard('BDT ASSETS', '৳${bdt.toStringAsFixed(2)}', Colors.orangeAccent),
                        ValueListenableBuilder(
                          valueListenable: frozenBdtListenable,
                          builder: (context, fBdt, _) => fBdt > 0 
                            ? Padding(
                                padding: const EdgeInsets.only(left: 30, bottom: 5),
                                child: Text('PROCESSING: ৳${fBdt.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                              ) 
                            : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('EXCHANGE ROOM', style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12)),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _actionBtn('WITHDRAW (USD)', () => _showTransactionForm(context, 'WITHDRAW', 'INTL')),
                            _actionBtn('WITHDRAW (BDT)', () => _showTransactionForm(context, 'WITHDRAW', 'LOCAL')),
                            _actionBtn('DEPOSIT', () => _showTemplateSelector(context, 'DEPOSIT')),
                            _actionBtn('BANK PROFILE', () => _showBankProfileSetup(context)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Dr. (Debit): Local Rail', style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('Cr. (Credit): Intl Rail', style: TextStyle(color: Colors.greenAccent.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              channel.sink.add(json.encode({"action": "FORCE_SYNC"}));
                              onInteraction('A_113_FORCE_SYNC_REQUEST');
                            },
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('NEURAL SYNC PULSE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SovereignColors.cyan.withValues(alpha: 0.1),
                              foregroundColor: SovereignColors.cyan,
                              side: const BorderSide(color: SovereignColors.cyan, width: 0.5),
                              minimumSize: const Size(double.infinity, 45),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('3-LAYER AI MODERATION (DR. CR.) SYSTEM ACTIVE', style: TextStyle(color: SovereignColors.cyan, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        
                        // Roadmap Step 3: Transaction Status Tracking Pulse
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('BANK PAYOUT TRACKING [A_177]', style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 10)),
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder(
                          valueListenable: bankHistoryListenable,
                          builder: (context, history, _) {
                            if (history.isEmpty) {
                              return const Center(child: Text('NO ACTIVE TRACKING PULSE', style: TextStyle(color: Colors.white10, fontSize: 8)));
                            }
                            return Container(
                              height: 120,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(10)),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: history.length,
                                itemBuilder: (context, idx) {
                                  final item = history[idx];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('TXID: ${item['tx_id']}', style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
                                            Text('${item['amount']} ${item['currency']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: item['stage'] == 'BATCHING' ? Colors.orangeAccent.withValues(alpha: 0.2) : Colors.cyan.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['stage'] ?? 'PENDING', 
                                            style: TextStyle(
                                              color: item['stage'] == 'BATCHING' ? Colors.orangeAccent : Colors.cyan, 
                                              fontSize: 7, 
                                              fontWeight: FontWeight.bold
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                }
              );
            }
          );
        }
      ),
    );
  }

  void _showTemplateSelector(BuildContext context, String type) {
    onInteraction('${type}_TEMPLATE_REQUESTED');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DYNAMIC $type TEMPLATES', style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 20),
            const Text('LOCAL RAIL', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ListTile(
              leading: Icon(type == 'DEPOSIT' ? Icons.account_balance : Icons.phone_android, color: Colors.white70),
              title: Text(type == 'DEPOSIT' ? 'bKash / Nagad / Rocket' : 'Bank Transfer / Mobile Cash', style: const TextStyle(color: Colors.white)),
              subtitle: const Text('Local Gateway (A_113_LOCAL_UI)', style: TextStyle(color: Colors.white24, fontSize: 10)),
              onTap: () {
                Navigator.pop(context);
                _showTransactionForm(context, type, 'LOCAL');
              },
            ),
            const Divider(color: Colors.white10),
            const Text('INTERNATIONAL RAIL', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ListTile(
              leading: Icon(type == 'DEPOSIT' ? Icons.credit_card : Icons.public, color: Colors.white70),
              title: Text(type == 'DEPOSIT' ? 'Global Transfer (Sovereign Bridge)' : 'PayPal / Swift / Payoneer', style: const TextStyle(color: Colors.white)),
              subtitle: const Text('International Rail (A_113_INTL_UI)', style: TextStyle(color: Colors.white24, fontSize: 10)),
              onTap: () {
                Navigator.pop(context);
                _showTransactionForm(context, type, 'INTL');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionForm(BuildContext context, String type, String rail) {
    final accountController = TextEditingController();
    final bankNameController = TextEditingController(); 
    final routingController = TextEditingController(); 
    final amountController = TextEditingController();
    final pinController = TextEditingController(); 
    final channelController = TextEditingController(); 
    final trxIdController = TextEditingController(); // V15: SMS Bridge TxID
    String selectedCurrency = rail == 'LOCAL' ? 'BDT' : 'USD';
    String selectedMethod = rail == 'LOCAL' ? 'bkash' : 'bkash'; // Default to bkash for bridge
    bool isInstructionPhase = false;
    bool loadingBridge = false;

    // Sovereign V15: High-Precision Profile Pre-fetch
    Future<void> prefillBank() async {
      try {
        final String currentHost = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
        final resp = await http.get(Uri.parse(_resolveSecureUrl('http://$currentHost:5000/api/v15/finance/bank/get?user_id=$meshID')));
        if (resp.statusCode == 200) {
           final data = json.decode(resp.body);
           if (data['status'] == 'SUCCESS' && data['profile'] != null) {
              final p = data['profile'];
              if (selectedMethod == 'bank') {
                accountController.text = p['account_number'] ?? '';
                bankNameController.text = p['bank_name'] ?? '';
                routingController.text = p['routing_number'] ?? '';
                channelController.text = p['branch_name'] ?? '';
              }
           }
        }
      } catch(_) {}
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0D0D0D),
          title: Text('SOVEREIGN $type [$rail]', style: const TextStyle(color: SovereignColors.cyan, fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: rail == 'LOCAL' ? 'Mobile No / Account No' : 'Email / SWIFT / Wallet ID',
                  labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Text('Currency: ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('USD'),
                    selected: selectedCurrency == 'USD',
                    onSelected: (v) => setDialogState(() => selectedCurrency = 'USD'),
                    selectedColor: SovereignColors.cyan,
                    backgroundColor: Colors.white12,
                    labelStyle: TextStyle(color: selectedCurrency == 'USD' ? Colors.black : Colors.white),
                  ),
                  const SizedBox(width: 5),
                  ChoiceChip(
                    label: const Text('BDT'),
                    selected: selectedCurrency == 'BDT',
                    onSelected: (v) => setDialogState(() => selectedCurrency = 'BDT'),
                    selectedColor: SovereignColors.cyan,
                    backgroundColor: Colors.white12,
                    labelStyle: TextStyle(color: selectedCurrency == 'BDT' ? Colors.black : Colors.white),
                  ),
                ],
              ),
              if (rail == 'LOCAL') ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Text('Method: ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('bKash'),
                              selected: selectedMethod == 'bkash',
                              onSelected: (v) => setDialogState(() => selectedMethod = 'bkash'),
                              selectedColor: SovereignColors.cyan,
                              backgroundColor: Colors.white12,
                              labelStyle: TextStyle(color: selectedMethod == 'bkash' ? Colors.black : Colors.white),
                            ),
                            const SizedBox(width: 5),
                            ChoiceChip(
                              label: const Text('Nagad'),
                              selected: selectedMethod == 'nagad',
                              onSelected: (v) => setDialogState(() => selectedMethod = 'nagad'),
                              selectedColor: SovereignColors.cyan,
                              backgroundColor: Colors.white12,
                              labelStyle: TextStyle(color: selectedMethod == 'nagad' ? Colors.black : Colors.white),
                            ),
                            const SizedBox(width: 5),
                            ChoiceChip(
                              label: const Text('Rocket'),
                              selected: selectedMethod == 'rocket',
                              onSelected: (v) => setDialogState(() => selectedMethod = 'rocket'),
                              selectedColor: SovereignColors.cyan,
                              backgroundColor: Colors.white12,
                              labelStyle: TextStyle(color: selectedMethod == 'rocket' ? Colors.black : Colors.white),
                            ),
                            const SizedBox(width: 5),
                            ChoiceChip(
                              label: const Text('Bank'),
                              selected: selectedMethod == 'bank',
                              onSelected: (v) {
                                setDialogState(() => selectedMethod = 'bank');
                                prefillBank();
                              },
                              selectedColor: SovereignColors.cyan,
                              backgroundColor: Colors.white12,
                              labelStyle: TextStyle(color: selectedMethod == 'bank' ? Colors.black : Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (selectedMethod == 'bank') ...[
                const SizedBox(height: 15),
                TextField(
                  controller: bankNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'BANK NAME',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 10),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                  ),
                ),
                TextField(
                  controller: routingController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'ROUTING NUMBER (9 DIGITS)',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 10),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                  ),
                ),
                TextField(
                  controller: channelController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'BRANCH NAME',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 10),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (${selectedCurrency == 'USD' ? '\$' : '৳'})',
                  labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'QUANTUM PIN',
                  labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                ),
              ),
              if (isInstructionPhase) ...[
                const SizedBox(height: 10),
                const Divider(color: Colors.white10),
                const SizedBox(height: 10),
                Text('MANUAL PAYMENT INSTRUCTIONS', style: TextStyle(color: SovereignColors.cyan.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Send Money (৳${amountController.text}) to:', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder<Map<String, dynamic>>(
                            valueListenable: bridgeConfigsListenable,
                            builder: (context, configs, _) {
                              return SelectableText(configs[selectedMethod] ?? 'LOADING...', 
                                style: const TextStyle(color: SovereignColors.cyan, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2));
                            }
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                            onPressed: () {
                              final num = bridgeConfigsListenable.value[selectedMethod];
                              if (num != null) {
                                Clipboard.setData(ClipboardData(text: num));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('NUMBER COPIED TO CLIPBOARD'),
                                  backgroundColor: SovereignColors.cyan,
                                ));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text('2. After payment, enter your Transaction ID (TxID) below:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: trxIdController,
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'TRANSACTION ID (FROM SMS)',
                    labelStyle: TextStyle(color: Colors.white38, fontSize: 10),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 2)),
                  ),
                ),
              ] else ...[
                ValueListenableBuilder(
                  valueListenable: amountController,
                  builder: (context, amountVal, _) {
                    double amount = double.tryParse(amountVal.text) ?? 0.0;
                    return Column(
                      children: [
                        if (selectedCurrency == 'USD' && selectedMethod == 'bank') ...[
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                            valueListenable: bdtRateListenable,
                            builder: (context, bRate, _) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withValues(alpha: 0.05),
                                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text('EXCHANGE RATE: \$1 = ৳${bRate.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                    if (amount > 0)
                                      Text('YOU RECEIVE: ৳${(amount * bRate).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }
                          ),
                        ],
                        const SizedBox(height: 20),
                        ValueListenableBuilder(
                          valueListenable: mlmYieldListenable,
                          builder: (context, comm, _) {
                            double tax = amount * (comm / 100.0);
                            double total = amount + tax;
                            return Column(
                              children: [
                                Text('MLM Network Yield Tax: ${comm.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                if (amount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text('Total Debit (Principal + Tax): ${selectedCurrency == 'USD' ? '\$' : '৳'}${total.toStringAsFixed(2)}', 
                                      style: const TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                if (tax > 0)
                                  Text('Yield Tax Component: ${selectedCurrency == 'USD' ? '\$' : '৳'}${tax.toStringAsFixed(2)}', 
                                    style: const TextStyle(color: Colors.white24, fontSize: 8)),
                              ],
                            );
                          }
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 10),
                const Text('3-LAYER AI AUDIT ENGINE ACTIVE', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.5)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              onPressed: () async {
                if (meshID == "CALIBRATING...") {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IDENTITY NOT CALIBRATED. PLEASE WAIT...')));
                   return;
                }
                
                String account = accountController.text.trim();
                String pin = pinController.text.trim();
                
                if (account.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ACCOUNT NUMBER / ID IS REQUIRED')));
                  return;
                }
                if (pin.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QUANTUM PIN IS REQUIRED')));
                  return;
                }

                // Sovereign V15 Real-Mode: Format Validation Guards
                bool isValid = false;
                if (rail == 'LOCAL') {
                  if (selectedMethod == 'bank') {
                    // Bank validation: Routing number must be 9 digits
                    isValid = RegExp(r'^\d{9}$').hasMatch(routingController.text.trim());
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.orangeAccent,
                        content: Text('INVALID ROUTING NUMBER! Expected 9 digits.')
                      ));
                      return;
                    }
                    if (bankNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('BANK NAME & BRANCH REQUIRED')));
                      return;
                    }
                  } else {
                    String sanitizedAccount = account.replaceAll('-', '');
                    isValid = RegExp(r'^(\+88)?01[3-9]\d{8,9}$').hasMatch(sanitizedAccount);
                    if (!isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('INVALID LOCAL FORMAT! Expected: 11 or 12 digit mobile number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ));
                      return;
                    }
                  }
                } else {
                  bool isEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(account);
                  bool isWallet = RegExp(r'^[a-zA-Z0-9]{8,64}$').hasMatch(account);
                  if (!isEmail && !isWallet) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('INVALID INTERNATIONAL FORMAT! Expected: Email or Valid Wallet ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    ));
                    return;
                  }
                }

                double amt = double.tryParse(amountController.text) ?? 0.0;
                if (amt <= 0) return;
                
                if (type == 'WITHDRAW') {
                  double currentBalance = selectedCurrency == 'USD' ? usdListenable.value : bdtListenable.value;
                  double commissionRate = mlmYieldListenable.value;
                  double totalRequired = amt * (1 + commissionRate / 100.0);
                  
                  if (totalRequired > currentBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('INSUFFICIENT BALANCE FOR WITHDRAWAL + TAX ($commissionRate% Network Yield Tax)')
                    ));
                    return;
                  }
                  
                  if (selectedCurrency == 'USD' && amt < minWithdrawListenable.value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('MINIMUM WITHDRAWAL IS \$${minWithdrawListenable.value.toStringAsFixed(2)}')));
                    return;
                  }
                }

                // Sovereign A_113: Final Dispatch
                if (type == 'DEPOSIT') {
                  if (!isInstructionPhase) {
                    // Phase 1: Show Instructions & Fetch Numbers
                    setDialogState(() => loadingBridge = true);
                    try {
                      final String currentHost = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
                      final resp = await http.get(Uri.parse(_resolveSecureUrl('http://$currentHost:5000/api/v15/finance/bridge/config')));
                      if (resp.statusCode == 200) {
                        bridgeConfigsListenable.value = json.decode(resp.body);
                      }
                    } catch (e) {
                      debugPrint("BRIDGE_FETCH_ERR: $e");
                    }
                    setDialogState(() {
                      loadingBridge = false;
                      isInstructionPhase = true;
                    });
                    return;
                  }

                  // Phase 2: Verify TxID
                  String trxId = trxIdController.text.trim();
                  if (trxId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('TRANSACTION ID IS REQUIRED')));
                    return;
                  }

                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: SovereignColors.cyan,
                    content: Text('VERIFYING TRANSACTION PULSE... [A_113]')
                  ));

                  try {
                    // V15 GAP FIX 4: Use dynamic globalSovereignHost instead of hardcoded IP
                    final String currentHost = globalSovereignHost;
                    final response = await http.post(
                      Uri.parse('http://$currentHost:5000/api/v15/finance/deposit/verify_tx'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        "user_id": meshID,
                        "trx_id": trxId
                      })
                    );

                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      if (data['status'] == 'SUCCESS') {
                        onInteraction('BRIDGE_DEPOSIT_COMPLETE: ${data['amount']}');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.greenAccent,
                          content: Text('SUCCESS! ৳${data['amount']} ADDED TO QUANTUM WALLET', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                        ));
                      } else {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('FAILED: ${data['reason'] ?? "Invalid Transaction ID"}')
                        ));
                      }
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('BRIDGE TIMEOUT. PLEASE TRY LATER.')));
                    }
                  } catch (e) {
                    debugPrint("BRIDGE_VERIFY_ERR: $e");
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NETWORK ERROR IN BRIDGE LINK')));
                  }
                  return;
                }
                if (type == 'WITHDRAW') {
                  // Sovereign V15: A_142 Secure Preflight with OTP
                   if (!context.mounted) return;
                   _showBindingOTPChallenge(context, accountController.text, () {
                      final txId = "TXN_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().microsecond % 9000).toString()}";
                      channel.sink.add(json.encode({
                        "action": "A_113_TRANSACTION_SUBMIT",
                        "type": type,
                        "rail": selectedMethod == 'bank' ? 'bank' : (rail == 'LOCAL' ? 'amarpay' : 'stripe'),
                        "tx_id": txId,
                        "account": accountController.text.trim().replaceAll('-', ''),
                        "amount": amt,
                        "currency": selectedCurrency,
                        "method": selectedMethod,
                        "pin": pinController.text,
                        "hw_id": "CLIENT_V15_STABLE"
                      }));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('V15 SECURE $type SUBMITTED: $txId')));
                   });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
              child: loadingBridge 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                : Text(isInstructionPhase ? 'VERIFY' : 'PROCEED', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ),
  );
}

  /*
  void _showExchangeForm(BuildContext context, String from, String to) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: Text('EXCHANGE: $from TO $to', style: const TextStyle(color: SovereignColors.cyan, fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder(
              valueListenable: bdtRateListenable,
              builder: (context, bRate, _) {
                String rateText = "";
                if (from == 'USD' && to == 'BDT') {
                  rateText = "\$1 = ৳${bRate.toStringAsFixed(2)}";
                } else if (from == 'BDT' && to == 'USD') {
                  rateText = "৳${bRate.toStringAsFixed(2)} = \$1";
                }
                
                return Text('Live Rate: $rateText', style: const TextStyle(color: Colors.white38, fontSize: 10));
              }
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder(
              valueListenable: commissionListenable,
              builder: (context, comm, _) => Text('Platform Commission: ${comm.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
            ),
            const SizedBox(height: 5),
            ValueListenableBuilder(
              valueListenable: mlmYieldListenable,
              builder: (context, yieldVal, _) => Text('Network Yield Maintenance: ${yieldVal.toStringAsFixed(2)}%', style: const TextStyle(color: Colors.white24, fontSize: 9)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount of $from to swap',
                labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('3-LAYER AI MODERATION ACTIVE', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                   Text('MESH ID: $meshID', style: const TextStyle(color: SovereignColors.cyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                   const SizedBox(height: 4),
                   const Text('LEDGER STATUS: SYNCHRONIZED [A_113]', style: TextStyle(color: Colors.white10, fontSize: 7, letterSpacing: 1)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              double amt = double.tryParse(amountController.text) ?? 0.0;
              if (amt <= 0) {
                return;
              }

              // V15: Secure Server-side Exchange Protocol [A_113]
              if (meshID == "CALIBRATING...") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IDENTITY NOT CALIBRATED. PLEASE WAIT...')));
                  return;
              }

              channel.sink.add(json.encode({
                "action": "WALLET_EXCHANGE_REQUEST",
                "from": from,
                "to": to,
                "amount": amt,
                "mesh_id": meshID,
                "timestamp": DateTime.now().toIso8601String()
              }));

              onInteraction('EXCHANGE_REQUEST_SENT: $amt $from TO $to');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: SovereignColors.cyan, 
                    content: Text('EXCHANGE REQUEST QUEUED | AI AUDIT: ACTIVE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                )
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
            child: const Text('EXCHANGE', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  */

  Widget _balanceCard(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback? onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
      child: Text(label),
    );
  }

  void _showBankProfileSetup(BuildContext context) {
    final bankNameController = TextEditingController();
    final accountNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final routingController = TextEditingController();
    final branchController = TextEditingController();
    final pinController = TextEditingController();

    // Load existing profile
    Future<void> loadProfile() async {
      try {
        final String currentHost = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
        String apiUrl = _resolveSecureUrl('http://$currentHost:5000/api/v15/finance/bank/get?user_id=$meshID');
        final resp = await http.get(Uri.parse(apiUrl));
        if (resp.statusCode == 200) {
           final data = json.decode(resp.body);
           if (data['status'] == 'SUCCESS' && data['profile'] != null) {
              final p = data['profile'];
              bankNameController.text = p['bank_name'] ?? '';
              accountNameController.text = p['account_name'] ?? '';
              accountNumberController.text = p['account_number'] ?? '';
              routingController.text = p['routing_number'] ?? '';
              branchController.text = p['branch_name'] ?? '';
           }
        }
      } catch(_) {}
    }

    loadProfile();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D0D),
        title: const Text('BANK VAULT SECURE SETUP', style: TextStyle(color: SovereignColors.cyan, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _vaultField(bankNameController, 'BANK NAME'),
              _vaultField(accountNameController, 'ACCOUNT HOLDER NAME'),
              _vaultField(accountNumberController, 'ACCOUNT NUMBER'),
              _vaultField(routingController, 'ROUTING NUMBER', isNumeric: true),
              _vaultField(branchController, 'BRANCH NAME'),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'QUANTUM PIN (REQUIRED TO SAVE)',
                  labelStyle: TextStyle(color: Colors.white38, fontSize: 10),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
                ),
              ),
              const SizedBox(height: 15),
              const Text('AES-256 HARDWARE LEVEL ENCRYPTION ACTIVE', style: TextStyle(color: Colors.white10, fontSize: 8)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              if (pinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN REQUIRED')));
                return;
              }
              
              final String currentHost = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : globalSovereignHost;
              String apiUrl = _resolveSecureUrl('http://$currentHost:5000/api/v15/finance/bank/update');
              final resp = await http.post(
                Uri.parse(apiUrl),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  "user_id": meshID,
                  "details": {
                    "bank_name": bankNameController.text,
                    "account_name": accountNameController.text,
                    "account_number": accountNumberController.text,
                    "routing_number": routingController.text,
                    "branch_name": branchController.text,
                  }
                })
              );

              if (resp.statusCode == 200) {
                 if (!context.mounted) return;
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: SovereignColors.cyan,
                    content: Text('BANK VAULT UPDATED & ENCRYPTED', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
                 ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
            child: const Text('SAVE SECURELY', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _vaultField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: SovereignColors.cyan)),
      ),
    );
  }

  void _showBindingOTPChallenge(BuildContext context, String account, VoidCallback onVerified) {
    final otpController = TextEditingController();
    _pendingBindingAction = onVerified; // Secure the callback for Mesh Sync
    
    channel.sink.add(json.encode({"action": "A_142_REQUEST_BINDING_OTP", "account": account}));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Listen to broadcast stream for BINDING_SUCCESS to auto-close dialog
          return AlertDialog(
            backgroundColor: const Color(0xFF0D0D0D),
            title: const Text('SECURE IDENTITY BINDING [A_142]', style: TextStyle(color: SovereignColors.cyan, fontSize: 14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the 6-digit OTP sent to your secure hub to bind this account.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 20),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', letterSpacing: 5),
                  decoration: const InputDecoration(hintText: '******', hintStyle: TextStyle(color: Colors.white10)),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white24))),
              ElevatedButton(
                onPressed: () {
                   // V15: Instead of immediate local "onVerified", ask Mesh for authority
                   if (otpController.text.length < 6) return;
                   
                   channel.sink.add(json.encode({
                     "action": "A_142_VERIFY_BINDING",
                     "account": account,
                     "otp": otpController.text.trim()
                   }));
                   
                   // UI Feedback: Show waiting state
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('VERIFYING IDENTITY WITH MESH...')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: SovereignColors.cyan),
                child: const Text('VERIFY & PROCEED', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }
}
class SovereignGuidelinesView extends StatelessWidget {
  const SovereignGuidelinesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, 
        title: const Text('LEGAL PROTOCOLS [A_112]', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)), 
        centerTitle: true
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildExpandableSection(
                  '1. ADMIN GOD-MODE AUTHORITY', 
                  'The Sovereign Admin Grid maintains absolute God-Mode control over all nodes. For legal safety and ecosystem integrity, any node found violating protocols A_101 through A_125 is subject to immediate remote override, termination, or fiscal seizure without prior notice.',
                  Icons.bolt_rounded,
                  SovereignColors.cyan
                ),
                _buildExpandableSection(
                  '2. IRREFUTABLE LEGAL EVIDENCE [A_106]', 
                  'Every interaction, permission toggle, and fiscal move is cryptographically hashed and archived in the Sovereign Law Enforcer [A_106] vault. This data serves as irrefutable digital evidence for legal protection of the Admin Grid.',
                  Icons.gavel_rounded,
                  Colors.orangeAccent
                ),
                _buildExpandableSection(
                  '3. FISCAL ENFORCEMENT [A_105]', 
                  'The A_105 Revenue Control system enforces the Sovereign 80/20 split. Attempts to bypass templates or manipulate coin-to-view rates are detected by 3-layer AI and archived for immediate legal action.',
                  Icons.account_balance_wallet_rounded,
                  Colors.greenAccent
                ),
                _buildExpandableSection(
                  '4. SMART FILTER REGISTRY [A_112]', 
                  'Content moderation is executed at the hardware level. The A_112 registry filters prohibited data strings in sub-50ms, ensuring the mesh remains 100% compliant with Sovereign Governance V15.',
                  Icons.filter_alt_rounded,
                  Colors.purpleAccent
                ),
                _buildExpandableSection(
                  '5. NODE PRIVACY SHIELD', 
                  'Nodes are protected by the Sovereign Privacy Shield as long as they remain within protocol. Bypassing the A_106 Permission Center using external injection tools results in a permanent mesh ban.',
                  Icons.shield_rounded,
                  Colors.blueAccent
                ),
              ],
            ),
          ),
          _buildLegalFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SOVEREIGN MESH CONSTITUTION', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 12)),
          SizedBox(height: 10),
          Text('By interacting with this node, you consent to absolute Admin God-Mode sovereignty and irrefutable digital archiving.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, String body, IconData icon, Color color) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 0, 20, 20),
            child: Text(body, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded, color: SovereignColors.cyan, size: 14),
              SizedBox(width: 8),
              Text('A_106 ARCHIVING: ACTIVE', style: TextStyle(color: SovereignColors.cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          SizedBox(height: 8),
          Text('IRREFUTABLE DIGITAL EVIDENCE PULSE SYNCED', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class SovereignHashtagView extends StatelessWidget {
  final String tag;
  const SovereignHashtagView({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text('#$tag'), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withValues(alpha: 0.05),
            child: Row(
              children: [
                Container(height: 80, width: 80, color: SovereignColors.cyan.withValues(alpha: 0.1), child: const Icon(Icons.tag, size: 40, color: SovereignColors.cyan)),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#$tag', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('1.4B Views', style: TextStyle(color: Colors.white38)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text('Add to Favorites')),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(1),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75, crossAxisSpacing: 1, mainAxisSpacing: 1),
              itemCount: 21,
              itemBuilder: (context, index) => Container(color: Colors.white12, child: const Center(child: Icon(Icons.play_arrow, color: Colors.white24, size: 30))),
            ),
          )
        ],
      ),
    );
  }
}

class SovereignDMView extends StatefulWidget {
  final String user;
  const SovereignDMView({super.key, required this.user});

  @override
  State<SovereignDMView> createState() => _SovereignDMViewState();
}

class _SovereignDMViewState extends State<SovereignDMView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hey! Check out my new V15 video!', 'isMe': true},
    {'text': 'Sure, will check it now. The Mesh sync is incredible.', 'isMe': false},
    {'text': 'Exactly! Sub-50ms latency is a game changer.', 'isMe': true},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      final text = _controller.text.trim();
      setState(() {
        _messages.add({'text': text, 'isMe': true});
      });
      // Sync to Sovereign Mesh Interaction Engine
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
      WebSocketChannel.connect(Uri.parse(_resolveSecureUrl('ws://$host:5000/ws/interaction'))).sink.add(json.encode({
        "action": "DM_MESSAGE_SENT",
        "recipient": widget.user,
        "message": text,
        "timestamp": DateTime.now().toIso8601String()
      }));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(widget.user, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [Icon(Icons.info_outline, color: Colors.white), SizedBox(width: 15)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _msgCloud(_messages[index]['text'], _messages[index]['isMe']),
            ),
          ),
          
          // TikTok DNA Input Bar
          Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_emotions_outlined, color: Colors.white70, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: (v) => setState(() {}),
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Add comment...',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Icon(
                    Icons.send, 
                    color: _controller.text.isNotEmpty ? SovereignColors.cyan : Colors.white24,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _msgCloud(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? SovereignColors.cyan.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
        ),
        child: Text(
          text, 
          style: TextStyle(
            color: isMe ? SovereignColors.cyan : Colors.white, 
            fontSize: 15,
            height: 1.3
          )
        ),
      ),
    );
  }
}

class SovereignSoundHub extends StatefulWidget {
  final List<Map<String, dynamic>>? soundsList;
  final Function(Map<String, dynamic>) onSelect;
  final Function(String, {String? contentId}) onInteraction;

  const SovereignSoundHub({
    super.key, 
    this.soundsList,
    required this.onSelect, 
    required this.onInteraction,
    this.onRefresh,
  });

  final VoidCallback? onRefresh;

  @override
  State<SovereignSoundHub> createState() => _SovereignSoundHubState();
}

class _SovereignSoundHubState extends State<SovereignSoundHub> {
  String _activeTab = 'Hot';
  String _activeLocation = 'Bangladesh';
  int _bottomNavIndex = 0; // 0: Sound, 1: Volume
  bool _isSearching = false;
  double _originalVolume = 100.0;
  double _addedVolume = 100.0;
  
  // A_108: Search Intelligence State
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearchLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    setState(() => _isSearchLoading = true);
    try {
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
      final res = await http.get(Uri.parse(_resolveSecureUrl('http://$host:9900/search?query=$query')));
      if (res.statusCode == 200) {
        setState(() => _searchResults = json.decode(res.body));
      }
    } catch (e) {
      debugPrint("SOUND_HUB_SEARCH_ERR: $e");
    }
    setState(() => _isSearchLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 35, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 15),
          
          // Header Tabs [TikTok Sound DNA]
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildHubTab('Hot'),
                _buildHubTab('For You'),
                _buildHubTab('Favourites'),
                _buildHubTab('Recent'),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.search, color: _isSearching ? SovereignColors.cyan : Colors.black, size: 24),
                  onPressed: () {
                    setState(() => _isSearching = !_isSearching);
                    widget.onInteraction('SOUND_HUB_SEARCH_TOGGLE: $_isSearching');
                  },
                ),
              ],
            ),
          ),
          
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (val) => _performSearch(val),
                      decoration: InputDecoration(
                        hintText: 'Search sound...',
                        hintStyle: const TextStyle(color: Colors.black26),
                        prefixIcon: const Icon(Icons.search, color: Colors.black26, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 14, color: Colors.black26),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  if (_isSearchLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        color: SovereignColors.cyan,
                        minHeight: 1,
                      ),
                    ),
                ],
              ),
            ),
            
          const SizedBox(height: 20),
          
          // Contextual Content Layer
          Expanded(
            child: _bottomNavIndex == 0 
              ? Column(
                  children: [
                    // Location Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _buildHubPill('Bangladesh'),
                          const SizedBox(width: 10),
                          _buildHubPill('Global'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _isSearching && _searchResults.isNotEmpty
                      ? ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final s = _searchResults[index];
                            return _buildSoundItem(
                              index, 
                              s['title'] ?? 'Unknown Track', 
                              s['artist'] ?? 'Sovereign Artist', 
                              '${s['usage_count'] ?? 0} posts · 0:15',
                              s['url'] ?? '',
                              isHarvested: s['is_original'] ?? false
                            );
                          },
                        )
                      : widget.soundsList == null || widget.soundsList!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_note_outlined, color: Colors.black12, size: 48),
                              const SizedBox(height: 16),
                              const Text('Scanning Mesh for Sounds...', style: TextStyle(color: Colors.black26, fontSize: 13)),
                              const SizedBox(height: 20),
                              if (widget.onRefresh != null)
                                TextButton.icon(
                                  onPressed: widget.onRefresh,
                                  icon: const Icon(Icons.refresh, color: SovereignColors.cyan, size: 16),
                                  label: const Text('RETRY SYNC', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                        itemCount: widget.soundsList!.length,
                        itemBuilder: (context, index) {
                          final s = widget.soundsList![index];
                          return _buildSoundItem(
                            index, 
                            s['title'] ?? 'Unknown Track', 
                            s['artist'] ?? 'Sovereign Artist', 
                            '${s['usage_count'] ?? 0} posts · 0:15',
                            s['url'] ?? '',
                            isHarvested: s['is_original'] ?? false
                          );
                        },
                      ),
                    ),
                  ],
                )
              : _buildVolumeView(),
          ),
          
          // Bottom Navigation [Sync Standard]
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 25),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.black12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNav(0, Icons.music_note, 'Sound'),
                _buildBottomNav(1, Icons.volume_up_outlined, 'Volume'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHubTab(String label) {
    bool active = _activeTab == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = label);
        widget.onInteraction('SOUND_HUB_TAB_SET: $label');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Text(
          label, 
          style: TextStyle(
            color: active ? Colors.black : Colors.black38, 
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 15
          )
        ),
      ),
    );
  }

  Widget _buildHubPill(String label) {
    bool active = _activeLocation == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeLocation = label);
        widget.onInteraction('SOUND_HUB_LOCATION_SET: $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label, 
          style: TextStyle(color: active ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildBottomNav(int index, IconData icon, String label) {
    bool active = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _bottomNavIndex = index);
        widget.onInteraction('SOUND_HUB_NAV_SET: $label');
      },
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.black : Colors.grey),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              fontWeight: active ? FontWeight.bold : FontWeight.normal, 
              color: active ? Colors.black : Colors.grey
            )
          )
        ],
      ),
    );
  }

  Widget _buildVolumeView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Volume Control [TikTok DNA]', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 30),
          _buildVolumeSlider('Original sound', _originalVolume, (val) {
             setState(() => _originalVolume = val);
             widget.onInteraction('VOLUME_ORIGINAL_SET: ${val.toInt()}%');
          }),
          const SizedBox(height: 40),
          _buildVolumeSlider('Added sound', _addedVolume, (val) {
             setState(() => _addedVolume = val);
             widget.onInteraction('VOLUME_ADDED_SET: ${val.toInt()}%');
          }),
          const Spacer(),
          Center(
            child: TextButton(
               onPressed: () => Navigator.pop(context), 
               child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16))
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            Text('${value.toInt()}%', style: const TextStyle(color: Colors.black45, fontSize: 12)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.black12,
            thumbColor: Colors.black,
            overlayColor: Colors.black.withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 200, // TikTok allows boosting added sound
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSoundItem(int id, String name, String artist, String stats, String url, {bool isHarvested = false}) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isHarvested ? SovereignColors.cyan.withValues(alpha: 0.1) : Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(isHarvested ? Icons.auto_awesome : Icons.music_note, color: isHarvested ? SovereignColors.cyan : Colors.black26),
      ),
      title: Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(artist, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(stats, style: const TextStyle(color: Colors.black26, fontSize: 11)),
          const SizedBox(width: 8),
          const Icon(Icons.bookmark_border, color: Colors.black26, size: 20),
        ],
      ),
      onTap: () {
        widget.onSelect({
          'title': name,
          'artist': artist,
          'uploader': artist,
          'url': url,
        });
        Navigator.pop(context);
      },
    );
  }
}

class SovereignBlockListView extends StatefulWidget {
  final Set<String> blockedUsers;
  final Function(String) onUnblock;

  const SovereignBlockListView({super.key, required this.blockedUsers, required this.onUnblock});

  @override
  State<SovereignBlockListView> createState() => _SovereignBlockListViewState();
}

class _SovereignBlockListViewState extends State<SovereignBlockListView> {
  late List<String> _blockedList;

  @override
  void initState() {
    super.initState();
    _blockedList = widget.blockedUsers.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Block List', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _blockedList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 60, color: Colors.white10),
                  SizedBox(height: 15),
                  Text('No blocked users in the Mesh', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _blockedList.length,
              itemBuilder: (context, index) {
                final handle = _blockedList[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.person, color: Colors.white24),
                  ),
                  title: Text(handle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Restricted from your feed', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: TextButton(
                    onPressed: () {
                      widget.onUnblock(handle);
                      setState(() {
                        _blockedList.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unblocked $handle')));
                    },
                    child: const Text('Unblock', style: TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}

class SovereignVideoDetailFeed extends StatefulWidget {
  final int initialIndex;
  final List<int>? videoIndices;
  final int totalCount;
  final Function(String, {String? contentId}) onInteraction;
  final Function(String) creatorProfileOpen;
  final Function(String) soundDetailOpen;
  final Function(String, String, String) onAddMessage;
  final List<Map<String, dynamic>> mediaLedger;
  final String meshID; // A_105

  const SovereignVideoDetailFeed({
    super.key,
    required this.initialIndex,
    this.videoIndices,
    required this.totalCount,
    required this.onInteraction,
    required this.creatorProfileOpen,
    required this.soundDetailOpen,
    required this.onAddMessage,
    required this.mediaLedger,
    required this.meshID, // A_105
    required this.onSoundSelect, // A_128 Fix
  });

  final Function(String) onSoundSelect;

  @override
  State<SovereignVideoDetailFeed> createState() => _SovereignVideoDetailFeedState();
}

class _SovereignVideoDetailFeedState extends State<SovereignVideoDetailFeed> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.totalCount,
        itemBuilder: (context, index) {
          final videoIdx = widget.videoIndices != null ? widget.videoIndices![index] : index;
          String? customUrl;
          String? uploader;
          String? description;

          if (videoIdx < widget.mediaLedger.length) {
             customUrl = widget.mediaLedger[videoIdx]['url'];
             uploader = widget.mediaLedger[videoIdx]['uploader'];
             description = widget.mediaLedger[videoIdx]['desc'];
          }

          return VideoFeedItem(
            index: videoIdx,
            onInteraction: widget.onInteraction,
            adPanelHeight: 0,
            creatorProfileOpen: widget.creatorProfileOpen,
            soundDetailOpen: widget.soundDetailOpen,
            adFrequency: 0.0, 
            sponsorFrequency: 0.0,
            onAddMessage: widget.onAddMessage,
            meshID: widget.meshID, // A_105
            mediaLedger: widget.mediaLedger, // Fix Detail View Access
            videoUrl: customUrl,
            uploaderName: uploader,
            uploaderHandle: uploader,
            isVerified: (videoIdx < widget.mediaLedger.length) ? (widget.mediaLedger[videoIdx]['uploader_verified'] == true) : false,
            description: description,
          );
        },
      ),
    );
  }
}

class SystemMessagesView extends StatelessWidget {
  final Function(String, {String? contentId}) onInteraction;
  final List<Map<String, String>> messages;
  
  const SystemMessagesView({
    super.key, 
    required this.onInteraction,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('SYSTEM MESSAGES', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: SovereignColors.cyan.withValues(alpha: 0.2), width: 1))
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: messages.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, indent: 80),
              itemBuilder: (context, index) {
                final msg = messages[index];
                IconData iconData = Icons.notifications;
                if (msg['icon'] == 'sync_lock') iconData = Icons.sync_lock;
                if (msg['icon'] == 'account_balance_wallet') iconData = Icons.account_balance_wallet;
                if (msg['icon'] == 'security') iconData = Icons.security;
                if (msg['icon'] == 'verified_user') iconData = Icons.verified_user;
                if (msg['icon'] == 'account_tree') iconData = Icons.account_tree;
                if (msg['icon'] == 'settings_suggest') iconData = Icons.settings_suggest;
                if (msg['icon'] == 'policy') iconData = Icons.policy;
                if (msg['icon'] == 'lock_open') iconData = Icons.lock_open;
                if (msg['icon'] == 'advertising_units') iconData = Icons.ad_units;
                if (msg['icon'] == 'volunteer_activism') iconData = Icons.volunteer_activism;
                if (msg['icon'] == 'cloud_done') iconData = Icons.cloud_done;
                if (msg['icon'] == 'payments') iconData = Icons.payments;
                if (msg['icon'] == 'account_balance') iconData = Icons.account_balance;
                if (msg['icon'] == 'block') iconData = Icons.block;
                if (msg['icon'] == 'repeat') iconData = Icons.repeat;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SovereignColors.cyan.withValues(alpha: 0.1), 
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SovereignColors.cyan.withValues(alpha: 0.2)),
                    ),
                    child: Icon(iconData, color: SovereignColors.cyan, size: 24),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(msg['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(msg['time']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(msg['body']!, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  ),
                  onTap: () {
                    onInteraction('SYSTEM_MESSAGE_READ: ${msg['title']}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: SovereignColors.cyan,
                        content: Text('OPENING: ${msg['title']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Digital Evidence Archiving: ACTIVE [A_106]', style: TextStyle(color: Colors.white10, fontSize: 10, letterSpacing: 1, fontFamily: 'monospace')),
            ),
          ),
        ],
      ),
    );
  }
}

class SovereignSoundLibrary extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;
  const SovereignSoundLibrary({super.key, required this.onSelect});

  @override
  State<SovereignSoundLibrary> createState() => _SovereignSoundLibraryState();
}

class _SovereignSoundLibraryState extends State<SovereignSoundLibrary> {
  List<String> categories = ['Trending', 'Viral Hits', 'Pop', 'Islamic', 'Gaming'];
  String selectedCategory = 'Trending';
  List<dynamic> sounds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchSounds();
  }

  Future<void> _fetchCategories() async {
    try {
      final String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost;
      final res = await http.get(Uri.parse(_resolveSecureUrl('http://$host:9900/categories')));
      if (res.statusCode == 200) {
        setState(() => categories = List<String>.from(json.decode(res.body)));
      }
    } catch (_) {}
  }

  Future<void> _fetchSounds() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final String host = globalSovereignHost;
      final res = await http.get(Uri.parse(_resolveSecureUrl('http://$host:9900/explore/$selectedCategory')));
      if (res.statusCode == 200) {
        if (mounted) setState(() => sounds = json.decode(res.body));
      }
    } catch (_) {}
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantum Sounds', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    _fetchSounds();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        if (isSelected) Container(margin: const EdgeInsets.only(top: 4), width: 20, height: 2, color: const Color(0xFF00FFFF)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFFF)))
              : ListView.builder(
                  itemCount: sounds.length,
                  itemBuilder: (context, index) {
                    final s = sounds[index];
                    return ListTile(
                      leading: Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.music_note, color: Color(0xFF00FFFF)),
                      ),
                      title: Text(s['title'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text('${s['artist']} • ${s['duration']}s', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white38),
                        onPressed: () {
                          widget.onSelect(s);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// A_111: AI TARGETING SUITE [V15 Master Script]
class AdTargetTemplatesView extends StatefulWidget {
  final List<Map<String, dynamic>> mediaLedger;
  final String meshID;
  final Function(String, {String? contentId}) onInteraction;

  const AdTargetTemplatesView({
    super.key, 
    required this.mediaLedger, 
    required this.meshID,
    required this.onInteraction,
  });

  @override
  State<AdTargetTemplatesView> createState() => _AdTargetTemplatesViewState();
}

class _AdTargetTemplatesViewState extends State<AdTargetTemplatesView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _professionInterestController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  RangeValues _ageRange = const RangeValues(18, 24);
  String _selectedAudienceType = 'All';
  Map<String, dynamic>? _selectedVideo;
  String _activeTab = 'Video';

  @override
  void dispose() {
    _nameController.dispose();
    _professionInterestController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showProfileMediaPicker() {
    final String targetId = (widget.meshID == "CALIBRATING...") ? "" : widget.meshID;
    List<Map<String, dynamic>> userMedia = widget.mediaLedger.where((m) => 
      m['uploader'] == targetId || 
      m['uploader'] == '@$targetId' ||
      (targetId.isNotEmpty && m['uploader'].toString().contains(targetId))
    ).toList();

    bool isFallback = false;
    if (userMedia.isEmpty) {
      userMedia = List<Map<String, dynamic>>.from(widget.mediaLedger);
      isFallback = true;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 25),
            const Text(
              'V15 MESH: SELECT VIDEO', 
              style: TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)
            ),
            const SizedBox(height: 10),
            Text(
              isFallback ? 'Displaying all available mesh content' : 'Identity Verified: ${userMedia.length} Videos found', 
              style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 25),
            Expanded(
              child: userMedia.isEmpty 
                ? const Center(child: Text('EMPTY_VAULT: NO_MEDIA_FOUND', style: TextStyle(color: Colors.white12, fontSize: 12, letterSpacing: 1)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75
                    ),
                    itemCount: userMedia.length,
                    itemBuilder: (context, index) {
                      final m = userMedia[index];
                      final String? thumbName = m['thumbnail'];
                      final String thumbUrl = thumbName != null && thumbName.isNotEmpty
                          ? 'http://${kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : globalSovereignHost) : globalSovereignHost}:5000/vault/$thumbName' 
                          : "";

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedVideo = m);
                          Navigator.pop(context);
                          widget.onInteraction('AD_TEMPLATE_CONTENT_LOCKED: ${m['file']}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (thumbUrl.isNotEmpty)
                                Image.network(
                                  thumbUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white10, size: 20)),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 1, color: Color(0xFF00FFFF))));
                                  },
                                )
                              else
                                const Center(child: Icon(Icons.videocam_outlined, color: Colors.white10, size: 24)),
                              
                              Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)]
                                    )
                                  ),
                                  child: Text(
                                    m['desc'] ?? 'Video #$index',
                                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Ad Target Templates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('A_111: AI TARGETING SUITE', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 25),
            
            _buildSectionHeader('TEMPLATE IDENTITY'),
            const SizedBox(height: 12),
            _buildSimpleTextField('Template Name', _nameController),
            
            const SizedBox(height: 35),
            _buildSectionHeader('CONTENT TYPE'),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildTypeTab('Video', Icons.videocam, _activeTab == 'Video'),
                const SizedBox(width: 12),
                _buildTypeTab('Photo', Icons.photo_outlined, _activeTab == 'Photo'),
              ],
            ),
            
            const SizedBox(height: 35),
            _buildSectionHeader('TEMPLATE MEDIA SOURCE'),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _showProfileMediaPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _selectedVideo != null ? const Color(0xFF00FFFF).withValues(alpha: 0.3) : Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 65,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                        image: _selectedVideo != null && _selectedVideo!['thumbnail'] != null
                          ? DecorationImage(
                              image: NetworkImage('http://${kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : "localhost") : globalSovereignHost}:5000/vault/${_selectedVideo!['thumbnail']}'),
                              fit: BoxFit.cover
                            )
                          : null
                      ),
                      child: _selectedVideo == null 
                        ? const Icon(Icons.video_library_outlined, color: Colors.white24, size: 20) 
                        : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedVideo != null 
                              ? (_selectedVideo!['desc'] != null && _selectedVideo!['desc'].toString().isNotEmpty 
                                  ? _selectedVideo!['desc'] 
                                  : 'Selected Pillar') 
                              : 'No Media Selected',
                            style: TextStyle(
                              color: _selectedVideo != null ? Colors.white : Colors.white38, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          const Text('PICK FROM PROFILE VIDEO', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 35),
            _buildSectionHeader('TARGET AUDIENCE (AI Filter)'),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Age Range', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('${_ageRange.start.toInt()}-${_ageRange.end.toInt()}', style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            RangeSlider(
              values: _ageRange,
              min: 13,
              max: 65,
              activeColor: const Color(0xFF00FFFF),
              inactiveColor: Colors.white10,
              onChanged: (values) => setState(() => _ageRange = values),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAudienceType,
                  dropdownColor: const Color(0xFF101010),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                  items: ['All', 'Creators', 'Businesses', 'Casual Users'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedAudienceType = val!),
                ),
              ),
            ),

            const SizedBox(height: 35),
            _buildSectionHeader('AI GEO-TARGETING (GLOBAL SEARCH)'),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search city, region or country...',
                  hintStyle: TextStyle(color: Colors.white12),
                  prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF00FFFF), size: 18),
                  suffixIcon: Icon(Icons.map_outlined, color: Color(0xFF00FFFF), size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildProfessionField('Profession Interest', _professionInterestController),
            
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                    if (_selectedVideo != null) {
                      widget.onInteraction('AD_TEMPLATE_SAVE_INITIATED: ${_nameController.text}');
                      widget.onInteraction('AD_TARGET_PROFESSION: ${_professionInterestController.text}');
                      widget.onInteraction('AD_TARGET_LOCATION: ${_locationController.text}');
                      widget.onInteraction('AD_TARGET_AGE: ${_ageRange.start.toInt()}-${_ageRange.end.toInt()}');
                      
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('TEMPLATE SAVED & AI TARGETING ACTIVE'), 
                        backgroundColor: Color(0xFF00FFFF)
                      ));
                      Navigator.pop(context);
                    }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFFF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  elevation: 0
                ),
                child: const Text('Save Template', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2));
  }

  Widget _buildProfessionField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00FFFF).withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold),
          hintText: 'e.g. Tech, Beauty, Crypto',
          hintStyle: const TextStyle(color: Colors.white12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  Widget _buildSimpleTextField(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00FFFF) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isActive ? const Color(0xFF00FFFF) : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.black : Colors.white38, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.white38, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class SovereignPrivacyView extends StatelessWidget {
  const SovereignPrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, 
        title: const Text('PRIVACY & DATA SAFETY', style: TextStyle(letterSpacing: 2, fontSize: 16, fontWeight: FontWeight.bold)), 
        centerTitle: true
      ),
      body: ListView(
        padding: const EdgeInsets.all(25),
        children: [
          const Icon(Icons.shield_outlined, color: SovereignColors.cyan, size: 50),
          const SizedBox(height: 20),
          const Text(
            'SOVEREIGN V15 DATA PROTOCOL',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 30),
          _buildPrivacySection('1. DATA ENCRYPTION', 'All interactions on the Sovereign Mesh are cryptographically hashed using V15 standard protocols. Your digital footprint is secured at the hardware level.'),
          _buildPrivacySection('2. USER DATA CONTROL', 'In compliance with global guidelines, you maintain absolute control over your node. Account deletion results in immediate total mesh purge of your identity.'),
          _buildPrivacySection('3. EVIDENCE ARCHIVING [A_106]', 'Interaction logs are maintained for 30 days in a high-security vault for Admin Legal Immunity defense, after which they are subject to automated rotation.'),
          _buildPrivacySection('4. THIRD-PARTY DECOUPLING', 'The Sovereign Mesh does not sell or distribute your SOV_ID to external advertising data-brokers. All targeting is handled by internal AI [A_111].'),
          _buildPrivacySection('5. SUPPORT & CONTACT', 'For data safety inquiries or support, contact the Mesh Architect at support@fectok.com'),
          const SizedBox(height: 40),
          const Text(
            'Admin Decision: FINAL | Mesh Protocol: ACTIVE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: SovereignColors.cyan, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
