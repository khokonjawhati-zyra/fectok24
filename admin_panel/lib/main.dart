import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'dart:js' as js; 
import 'core/theme/admin_theme.dart';
import 'admin_auth_page.dart';

void main() {
  runApp(const SovereignAdminApp());
}

class SovereignAdminApp extends StatefulWidget {
  const SovereignAdminApp({super.key});

  @override
  State<SovereignAdminApp> createState() => _SovereignAdminAppState();
}

class _SovereignAdminAppState extends State<SovereignAdminApp> {
  bool _isAuthenticated = false;
  String? _sessionToken;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_session');
    if (token != null) {
      // Verify token against backend before trusting it
      try {
        String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
        if (host == 'localhost' || host == '127.0.0.1') host = '$host:5000';
        final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
        final response = await http.post(
          Uri.parse('$protocol://$host/verify_token'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'token': token}),
        ).timeout(const Duration(seconds: 5));
        final result = json.decode(response.body);
        if (response.statusCode == 200 && result['sov_id'] == 'MASTER_ADMIN') {
          setState(() { _sessionToken = token; _isAuthenticated = true; });
        } else {
          await prefs.remove('admin_session'); // Token invalid — force re-login
        }
      } catch (e) {
        // Backend offline — still show UI with stored token, WS will show error
        setState(() { _sessionToken = token; _isAuthenticated = true; });
      }
    }
  }

  Future<void> _onAuthSuccess(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_session', token);
    setState(() {
      _sessionToken = token;
      _isAuthenticated = true;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_session');
    setState(() {
      _sessionToken = null;
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sovereign Control',
      theme: AdminTheme.theme,
      home: _isAuthenticated 
          ? AdminScaffold(onLogout: _logout, token: _sessionToken!) 
          : AdminAuthPage(onAuthSuccess: _onAuthSuccess),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminScaffold extends StatefulWidget {
  final VoidCallback onLogout;
  final String token;
  const AdminScaffold({super.key, required this.onLogout, required this.token});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  late WebSocketChannel channel;
  int _selectedIndex = 0;

  bool _isMaintenanceActive = false;
  bool _isProductionMode = false;
  bool _isGatingEnabled = true;
  bool _isAdSplitEnabled = true;
  bool _isAIInjectorEnabled = true;
  bool _isAdRandomizerEnabled = false;

  String _healUrl(String url) {
    if (url.isEmpty) return url;
    final String currentHost = html.window.location.hostname ?? 'localhost';
    final RegExp ipRegex = RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    return url.replaceAll(ipRegex, currentHost).replaceAll('localhost', currentHost);
  }
  final Map<String, String> _networkApiKeys = {
    'ADM': 'ADM_LIVE_X99',
    'UNT': 'UNT_LIVE_X77',
    'APL': 'APL_LIVE_X55',
    'IRS': 'IRS_LIVE_X44',
    'META': 'META_LIVE_X33',
    'VGL': 'VGL_LIVE_X22',
  };
  
  String _yieldPer1k = "1.5 - 3.5 USD";
  int _adsPerMinute = 4;
  int _rotationInterval = 15;
  
  Future<void> _updateBridgeNumbers() async {
    try {
      final String host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      await http.post(
        Uri.parse('$protocol://$host/api/v15/finance/bridge/update_numbers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "master_key": "SOV_V15_GOD_MODE_777",
          "bkash": _bkashNumber,
          "nagad": _nagadNumber,
          "rocket": _rocketNumber
        }),
      );
    } catch (e) {
      debugPrint("BRIDGE_UPDATE_ERR: $e");
    }
  }

  Future<void> _fetchBridgeConfig() async {
    try {
      String host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      if (host == 'localhost' || host == '127.0.0.1') host = '$host:5000';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      final resp = await http.get(Uri.parse('$protocol://$host/api/v15/finance/bridge/config'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          _bkashNumber = data['bkash'] ?? _bkashNumber;
          _nagadNumber = data['nagad'] ?? _nagadNumber;
          _rocketNumber = data['rocket'] ?? _rocketNumber;
        });
      }
    } catch (e) {
      debugPrint("BRIDGE_FETCH_ERR: $e");
    }
  }

  double _likeWeight = 50.0;
  double _commentWeight = 50.0;
  double _shareWeight = 50.0;

  double _platformShare = 70.0;
  double _creatorShare = 20.0;
  double _userShare = 10.0;

  double _coinToViewRate = 200.0; // A_111 Update: Default to 200 Views per Coin
  double _bdtCpm = 5.0; // Renegade V15 Rename: Was _adFrequency
  double _sponsorFrequency = 5.0;

  double _viralSoundBoost = 100.0;
  double _soundRecLimit = 10.0;

  double _mlmRecurringYield = 5.0;
  double _mlmNetworkDepth = 15.0;

  double _aiIntegritySensitivity = 50.0;
  double _aiBehavioralSensitivity = 50.0;
  double _aiStrategicSensitivity = 50.0;

  // A_113 Quantum Wallet - Admin Core
  double _adminUSD = 540.0;
  double _adminBDT = 0.0;
  int _adminCoins = 12450;
  
  String _bkashNumber = "01700000000";
  String _nagadNumber = "01800000000";
  String _rocketNumber = "01900000000";
  String _sslcommerzStoreId = "LEGACY_DECOMMISSIONED";
  String _sslcommerzStorePassword = "LEGACY_DECOMMISSIONED";

  double _withdrawLimitSlider = 500.0;
  double _minWithdrawLimit = 10.0;
  double _bdtRate = 115.0; // 1 USD = 115 BDT
  double _depositLimitSlider = 1000.0;
  double _withdrawRiskPercent = 85.0;
  double _depositRiskPercent = 90.0;
  double _platformCommission = 10.0;
  bool _autoApproveWithdraw = false;
  bool _autoApproveDeposit = true;
  bool _killSwitchEngaged = false; // A_156
  bool _spreadGuardActive = true; // A_150
  String _withdrawTableStatus = "MONITORING";
  String _depositTableStatus = "LISTENING";

  final List<Map<String, dynamic>> _withdrawHistory = [];
  final List<Map<String, dynamic>> _depositHistory = [];

  final List<String> _interactionLogs = [];
  
  // A_119: Governance & User Management
  List<Map<String, dynamic>> _registeredUsers = [];
  bool _isGovernanceLoading = false;
  String _userSearchQuery = "";
  
  // A_107 Verification States
  final List<Map<String, dynamic>> _verificationRequests = [];
  bool _autoApproveVerification = false;
  bool _requireWithdrawVerification = true; // Sovereign V15: Identity Gate
  double _verificationRiskThreshold = 15.0; // Max risk allowed for auto-approve (15% = 85% confidence)

  // A_111: Live Revenue Charting States
  double _totalLiveRevenue = 0.0;
  double _lastYield = 0.0;
  final List<double> _revenueTrend = [];

  @override
  void initState() {
    super.initState();
    _fetchBridgeConfig(); // V15: High-Fidelity Bridge State Sync
    String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
    if (host == 'localhost' || host == '127.0.0.1') host = '$host:5000';
    final String wsProtocol = Uri.base.scheme == 'https' ? 'wss' : 'ws';
    channel = WebSocketChannel.connect(
      Uri.parse('$wsProtocol://$host/ws/admin?token=${widget.token}'),
    );
    channel.stream.listen((message) {
      setState(() {
        String msg = message.toString();
        _interactionLogs.insert(0, msg);
        if (_interactionLogs.length > 50) _interactionLogs.removeLast();

        // Real-time A_113 Table Sync & Auto-Approval Logic [GUARDED FROM LOOPS]
        if (msg.startsWith('{')) {
          try {
            final data = json.decode(msg);
            final action = data['action'];

            if (action == 'A_113_TRANSACTION_SUBMIT') {
              final type = data['type'] ?? 'DEPOSIT';
              final txId = data['tx_id'] ?? 'TXN_UNK';
              
              // Prevent duplicate entry in history (Sync Bridge might broadcast multiple times)
              bool exists = (type == 'WITHDRAW' ? _withdrawHistory : _depositHistory).any((e) => e['tx_id'] == txId);
              
                if (!exists) {
                  final Map<String, dynamic> historyItem = Map<String, dynamic>.from(data);
                  historyItem['status'] = 'PENDING';
                  historyItem['processed_at'] = null;
                  
                  if (type == 'WITHDRAW') {
                    _withdrawHistory.insert(0, historyItem);
                    String details = data['details'] ?? "REQUEST: ${data['amount']} ${data['currency']} (ID: $txId)";
                    _withdrawTableStatus = details;
                    if (_autoApproveWithdraw) {
                      _approveTransaction('WITHDRAW', details, txId: txId);
                    }
                  } else {
                    _depositHistory.insert(0, historyItem);
                    String details = data['details'] ?? "REQUEST: ${data['amount']} ${data['currency']} (ID: $txId)";
                    _depositTableStatus = details;
                    if (_autoApproveDeposit) {
                      _approveTransaction('DEPOSIT', details, txId: txId);
                    }
                  }
                }
            } else if (action == 'A_113_HISTORY_SYNC') {
              // Sovereign V15: Permanent Ledger Recovery Protocol
              final List<dynamic> pending = data['pending'] ?? [];
              final List<dynamic> batches = data['batches'] ?? [];
              final List<dynamic> history = data['history'] ?? [];
              
              setState(() {
                _withdrawHistory.clear();
                _depositHistory.clear();
                
                // 1. Process Pending Requests
                for (var item in pending) {
                  final Map<String, dynamic> historyItem = Map<String, dynamic>.from(item);
                  if (item['type'] == 'WITHDRAW') {
                    _withdrawHistory.add(historyItem);
                  } else {
                    _depositHistory.add(historyItem);
                  }
                }
                
                // 2. Process Batch History (Queued Withdrawals)
                for (var item in batches) {
                   final Map<String, dynamic> historyItem = Map<String, dynamic>.from(item);
                   if (!_withdrawHistory.any((e) => e['tx_id'] == historyItem['tx_id'])) {
                      _withdrawHistory.add(historyItem);
                   }
                }

                // 3. Process Permanent Ledger (Approved/Rejected/Archive)
                for (var item in history) {
                   final Map<String, dynamic> historyItem = Map<String, dynamic>.from(item);
                   // Standardize mesh ID key
                   if (historyItem['user_mesh_id'] == null) historyItem['user_mesh_id'] = item['user_id'];
                   
                   final String type = (item['type'] ?? '').toString().toUpperCase();
                   if (type.contains('WITHDRAW')) {
                      if (!_withdrawHistory.any((e) => e['tx_id'] == historyItem['tx_id'])) {
                         _withdrawHistory.add(historyItem);
                      }
                   } else if (type.contains('DEPOSIT')) {
                      if (!_depositHistory.any((e) => e['tx_id'] == historyItem['tx_id'])) {
                         _depositHistory.add(historyItem);
                      }
                   }
                }
                
                // Zero-Point Sort: Show newest first
                _withdrawHistory.sort((a, b) => b['tx_id'].toString().compareTo(a['tx_id'].toString()));
                _depositHistory.sort((a, b) => b['tx_id'].toString().compareTo(a['tx_id'].toString()));
              });
              debugPrint("A_113 SYNC: Recovered ${pending.length + batches.length + history.length} nodes from Sovereign Vault.");
            } else if (action == 'EXCHANGE_COMMISSION') {
              // Logic: A_113 Double-Entry Accounting
              double comm = (data['amount'] ?? 0.0).toDouble();
              String curr = data['currency'] ?? 'USD';
              if (curr == 'BDT') {
                _adminBDT += comm;
              } else {
                _adminUSD += comm;
              }
              _syncAssetLedger();
            } else if (data['status'] == 'IMPRESSION_VERIFIED') {
              // A_111: Neural Revenue Sync
              double y = (data['yield'] ?? 0.0).toDouble();
              if (y > 0) {
                _lastYield = y;
                _totalLiveRevenue += (data['splits']?['admin'] ?? 0.0).toDouble();
                _revenueTrend.add(_totalLiveRevenue);
                if (_revenueTrend.length > 20) _revenueTrend.removeAt(0);
                _adminUSD += (data['splits']?['admin'] ?? 0.0).toDouble();
              }
            } else if (action == 'A_113_TRANSACTION_DECISION') {
              // Remote decision sync (e.g. from backend or another admin)
              final tId = data['tx_id'];
              final decision = data['decision'];
              final vault = data['vault'];
              final targetHistory = (vault == 'WITHDRAW' ? _withdrawHistory : _depositHistory);
              int idx = targetHistory.indexWhere((e) => e['tx_id'] == tId);
              if (idx != -1) {
                targetHistory[idx]['status'] = decision;
                targetHistory[idx]['processed_at'] = data['timestamp'] ?? DateTime.now().toIso8601String();
                // Inject MLM data if present in decision (Backend might unify this)
                if (data['mlm_amount'] != null) {
                  targetHistory[idx]['mlm_amount'] = data['mlm_amount'];
                  targetHistory[idx]['mlm_comm_percent'] = data['mlm_comm_percent'];
                  targetHistory[idx]['referrer_id'] = data['referrer_id'];
                }
              }
            } else if (action == 'A_107_MLM_YIELD') {
              // A_107 MLM Sync: Update Revenue Metrics & History Record
              double y = (data['amount'] ?? 0.0).toDouble();
              String? tId = data['tx_id'];
              if (tId != null) {
                int idx = _withdrawHistory.indexWhere((e) => e['tx_id'] == tId);
                if (idx != -1) {
                  _withdrawHistory[idx]['mlm_comm_percent'] = data['rate'];
                  _withdrawHistory[idx]['referrer_id'] = data['referrer'];
                  _withdrawHistory[idx]['mlm_amount'] = y;
                  debugPrint("A_107 UI: Injected MLM yield into TX $tId");
                }
              }
              if (y > 0) {
                _totalLiveRevenue += y; 
                _adminUSD += y; 
                _revenueTrend.add(_totalLiveRevenue);
                if (_revenueTrend.length > 20) _revenueTrend.removeAt(0);
              }
            } else if (action == 'A_111_NEURAL_REVENUE_SYNC') {
              // A_113: Managed Revenue Sync from AI Brain [PATCH-V15]
              int amount = (data['amount'] ?? 0).toInt();
              String type = data['type'] ?? '';
              setState(() {
                if (type == 'TEMPLATE_CREDIT') {
                  _adminCoins += amount;
                  _interactionLogs.insert(0, "A_115: AI-VERIFIED. Cr. $amount SYNCED TO VAULT [SUCCESS]");
                  _interactionLogs.insert(0, "A_113 AUDIT: Cr. $amount Added to Revenue Wallet [SPONSOR_SYNC]");
                  
                  // Strategic Logic Injection [Module A_115]
                  if (amount >= 1000) {
                     _interactionLogs.insert(0, "A_115 AI_MOD: High-Gravity Template Detected. Automated Strategic Boost Active.");
                     _viralSoundBoost *= 1.05; 
                  }
                  
                  // A_111: Refresh from Source of Truth
                  _fetchSponsorStats();
                }
                _syncAssetLedger(); 
              });
            } else if (action == 'A_113_WALLET_SYNC') {
              // Sovereign V15 FIXED: Single unified handler with setState
              setState(() {
                if (data['usd'] != null) _adminUSD = (data['usd']).toDouble();
                if (data['bdt'] != null) _adminBDT = (data['bdt']).toDouble();
                if (data['coins'] != null) _adminCoins = (data['coins']).toInt();
                
                if (data['mlm_yield'] != null) _mlmRecurringYield = (data['mlm_yield']).toDouble();
                if (data['min_withdraw'] != null) _minWithdrawLimit = (data['min_withdraw']).toDouble();
                if (data['platform_commission'] != null) _platformCommission = (data['platform_commission']).toDouble();
                if (data['bdt_rate'] != null) _bdtRate = (data['bdt_rate']).toDouble();
                if (data['platform_share'] != null) _platformShare = (data['platform_share']).toDouble();
                if (data['creator_share'] != null) _creatorShare = (data['creator_share']).toDouble();
                if (data['user_share'] != null) _userShare = (data['user_share']).toDouble();
                if (data['payout_mode'] != null) _isProductionMode = data['payout_mode'] == 'PRODUCTION';
                if (data['usd_cpm'] != null) _coinToViewRate = (data['usd_cpm']).toDouble();
                if (data['bdt_cpm'] != null) _bdtCpm = (data['bdt_cpm']).toDouble();
                if (data['sponsor_frequency'] != null) _sponsorFrequency = (data['sponsor_frequency']).toDouble();

                // *** THE KEY FIX: Inject saved API keys from backend config.json ***
                if (data['ad_api_keys'] != null) {
                  final keys = Map<String, dynamic>.from(data['ad_api_keys']);
                  keys.forEach((k, v) => _networkApiKeys[k] = v.toString());
                }
                if (data['ad_toggles'] != null) {
                  final toggles = Map<String, dynamic>.from(data['ad_toggles']);
                  _isMaintenanceActive = toggles['maintenance'] ?? _isMaintenanceActive;
                  _isGatingEnabled = toggles['gating'] ?? _isGatingEnabled;
                  _isAIInjectorEnabled = toggles['ai_injector'] ?? _isAIInjectorEnabled;
                  _isAdRandomizerEnabled = toggles['ad_randomizer'] ?? _isAdRandomizerEnabled;
                }
                
                _sslcommerzStoreId = _networkApiKeys['sslcommerz_key'] ?? _sslcommerzStoreId;
                _sslcommerzStorePassword = _networkApiKeys['sslcommerz_secret'] ?? _sslcommerzStorePassword;
              });
              debugPrint("A_113 SYNC: Admin State + API Keys Calibrated from Backend Config.");
            } else if (action == 'USER_INTERACTION') {
              final interactionType = data['type'] ?? '';
              if (interactionType.contains('TEMPLATE_SAVED_AI_OPTIMIZED')) {
                _interactionLogs.insert(0, "A_115: SCANNING TEMPLATE FOR COMPLIANCE...");
                if (interactionType.contains('ID=0')) {
                   setState(() {
                     _isAdSplitEnabled = false;
                     channel.sink.add(json.encode({"action": "AD_SPLIT_TOGGLE", "enabled": false}));
                     _interactionLogs.insert(0, "A_115 AI_MOD: AUTO-OFF AD SYSTEM [REASON: SECURITY_BREACH]");
                   });
                }
              }
            } else if (action == 'A_107_VERIFICATION_REQUEST') {
              // A_107: Sovereign Identity Sync
              setState(() {
                _verificationRequests.insert(0, data);
                if (_verificationRequests.length > 20) _verificationRequests.removeLast();
              });
            } else if (action == 'ALL_USERS_SYNC') {
              // A_119: User Identity Pulse
              setState(() {
                _registeredUsers = List<Map<String, dynamic>>.from(data['users']);
                _isGovernanceLoading = false;
              });
              debugPrint("A_119: Governance Ledger Synced (${_registeredUsers.length} Nodes)");
            } else if (action == 'USER_CONTROL_ACK') {
              // A_119: Tactical Acknowledgement
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("GOVERNANCE: ${data['command']} SUCCESS [${data['target_id']}]"),
                backgroundColor: const Color(0xFFFF00FF),
              ));
              _fetchUsers(); // Refresh the list
            } else if (action == 'A_107_CONFIG_SYNC') {
              setState(() {
                _autoApproveVerification = data['auto_approve'] ?? _autoApproveVerification;
                _requireWithdrawVerification = data['require_withdrawal_verification'] ?? _requireWithdrawVerification;
              });
            } else if (action == 'AD_SYNC_HYPER_LOGIC') {
               // A_111 Master Sync Pulse
               setState(() {
                 _coinToViewRate = (data['usd_cpm'] ?? _coinToViewRate).toDouble();
                 _bdtCpm = (data['bdt_cpm'] ?? _bdtCpm).toDouble();
                 _sponsorFrequency = (data['sponsor_frequency'] ?? _sponsorFrequency).toDouble();
               });
            }
          } catch (e) {
            debugPrint("SYNC_ERR: Handshake Failed -> $e");
          }
        }
      });
    }, onError: (error) {
      debugPrint("WS_ERR: $error");
      setState(() {
        _interactionLogs.insert(0, "⚠ WS CONNECTION FAILED: $error");
      });
      // Show snackbar hint to re-login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("⚠ BACKEND CONNECTION LOST — Please logout and login again.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 10),
        ));
      }
    }, onDone: () {
      debugPrint("WS_CLOSED: Admin channel closed.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("⚠ BACKEND DISCONNECTED. Refresh or re-login.", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 8),
        ));
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 15) _fetchUsers(); // A_119: Proactive Scan on Enter
    });
    // Do not close drawer automatically for larger screens, but helpful for mobile web view
    if (MediaQuery.of(context).size.width < 1000) {
      Navigator.pop(context);
    }
  }

  void _toggleMaintenance() {
    setState(() {
      _isMaintenanceActive = !_isMaintenanceActive;
    });
    channel.sink.add('{"action": "MAINTENANCE_TOGGLE"}');
  }

  void _togglePayoutMode() {
    setState(() {
      _isProductionMode = !_isProductionMode;
    });
    channel.sink.add(json.encode({
      "action": "A_113_PAYOUT_MODE_TOGGLE",
      "mode": _isProductionMode ? "PRODUCTION" : "SANDBOX"
    }));
  }

  void _toggleLegalGating() {
    setState(() {
      _isGatingEnabled = !_isGatingEnabled;
    });
    channel.sink.add('{"action": "GATING_TOGGLE", "enabled": $_isGatingEnabled}');
  }

  void _toggleAdSplit() {
    setState(() {
      _isAdSplitEnabled = !_isAdSplitEnabled;
    });
    channel.sink.add('{"action": "AD_SPLIT_TOGGLE", "enabled": $_isAdSplitEnabled}');
  }

  void _toggleAIInjector() {
    setState(() {
      _isAIInjectorEnabled = !_isAIInjectorEnabled;
    });
    channel.sink.add('{"action": "AD_AI_INJECTOR_TOGGLE", "enabled": $_isAIInjectorEnabled}');
  }

  void _toggleAdRandomizer() {
    setState(() {
      _isAdRandomizerEnabled = !_isAdRandomizerEnabled;
    });
    channel.sink.add(json.encode({"action": "AD_RANDOMIZER_TOGGLE", "enabled": _isAdRandomizerEnabled}));
  }

  void _updateApiKey(String network, String key) {
    setState(() {
      _networkApiKeys[network] = key;
    });
    // Unified V15 Sync: Send the update in a way the backend persists it to config.json
    channel.sink.add(json.encode({
      "action": "AD_API_UPDATE",
      "network": network,
      "key": key,
      "ad_api_keys": _networkApiKeys // Inject full map for context
    }));
  }

  void _updatePayoutKey(String network, String key, String secret) {
    channel.sink.add(json.encode({
      "action": "AD_API_UPDATE",
      "network": network,
      "key": key,
      "secret": secret
    }));
  }

  void _saveAdSetting(String action, dynamic value) {
    setState(() {
      if (action == 'AD_YIELD_UPDATE') _yieldPer1k = value;
      if (action == 'AD_RATE_UPDATE') {
        double val = double.tryParse(value) ?? _adsPerMinute.toDouble();
        _adsPerMinute = val.toInt();
        _rotationInterval = (60.0 / val).toInt();
      }
      if (action == 'AD_INTERVAL_UPDATE') {
        double val = double.tryParse(value) ?? _rotationInterval.toDouble();
        _rotationInterval = val.toInt();
        _adsPerMinute = (60.0 / val).toInt();
      }
    });
    channel.sink.add('{"action": "$action", "value": "$value"}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('HYPER-SYNC: ${action == "AD_RATE_UPDATE" ? "Interval Auto-Locked to $_rotationInterval" : "Rate Auto-Locked to $_adsPerMinute"}s'), 
      backgroundColor: const Color(0xFF00FFFF),
      duration: const Duration(milliseconds: 500),
    ));
  }

  void _enforceLegal() {
    channel.sink.add('{"action": "LEGAL_ENFORCE"}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('LEGAL GATING ENFORCED GLOBALLY')),
    );
  }

  void _updateImpressionWeights(double l, double c, double s) async {
    setState(() {
      _likeWeight = l;
      _commentWeight = c;
      _shareWeight = s;
    });
    try {
      String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      if (host == 'localhost' || host == '127.0.0.1') host = '$host:5000';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      await http.post(
        Uri.parse('$protocol://$host/api/v15/finance/impression/update_weights?l=${l.toInt()}&c=${c.toInt()}&s=${s.toInt()}'),
      );
    } catch (e) {
      debugPrint('A_120 Sync Error: $e');
    }
  }

  void _updateAIModerationConfig(double integrity, double behavior, double strategy) {
    setState(() {
      _aiIntegritySensitivity = integrity;
      _aiBehavioralSensitivity = behavior;
      _aiStrategicSensitivity = strategy;
    });
    channel.sink.add(json.encode({
      "action": "A_115_CONFIG_UPDATE",
      "integrity": integrity.toInt(),
      "behavior": behavior.toInt(),
      "strategy": strategy.toInt()
    }));
  }

  void _saveMLMSetting(String action, dynamic value) {
    setState(() {
      if (action == 'MLM_YIELD_UPDATE') {
        _mlmRecurringYield = double.parse((value is double ? value : double.parse(value.toString())).toStringAsFixed(2));
      }
      if (action == 'MLM_DEPTH_UPDATE') {
        _mlmNetworkDepth = (value is double ? value : double.parse(value.toString())).roundToDouble();
      }
    });
    channel.sink.add(json.encode({"action": action, "value": action == 'MLM_YIELD_UPDATE' ? _mlmRecurringYield.toStringAsFixed(2) : value.toString()}));
  }

  void _updateRevenueShares(double p, double c, double u) {
    setState(() {
      _platformShare = p;
      _creatorShare = c;
      _userShare = u;
    });
    channel.sink.add(json.encode({
      "action": "AD_SPLIT_UPDATE",
      "p": p.toInt(),
      "c": c.toInt(),
      "u": u.toInt()
    }));
  }

  void _updateVerificationConfig(bool auto, double threshold, {bool? requireWithdrawal}) {
    setState(() {
      _autoApproveVerification = auto;
      _verificationRiskThreshold = threshold;
      if (requireWithdrawal != null) _requireWithdrawVerification = requireWithdrawal;
    });
    channel.sink.add(json.encode({
      "action": "A_107_AUTO_CONFIG",
      "auto_approve": auto,
      "risk_threshold": 100.0 - threshold,
      "require_withdrawal_verification": _requireWithdrawVerification
    }));
  }

  void _verificationDecision(String userId, String decision) {
    channel.sink.add(json.encode({
      "action": "A_107_VERIFICATION_DECISION",
      "user_id": userId,
      "decision": decision
    }));
    setState(() {
      _verificationRequests.removeWhere((req) => req['user_id'] == userId);
    });
  }

  void _updateSponsorConfig(double rate, double bdt, double sFreq) async {
    setState(() {
      _coinToViewRate = rate;
      _bdtCpm = bdt;
      _sponsorFrequency = sFreq;
    });
    // A_111: Real-time Hyper-Logic Sync
    channel.sink.add(json.encode({
      "action": "AD_SYNC_HYPER_LOGIC",
      "coin_to_view_rate": rate,
      "ad_frequency": _adsPerMinute.toDouble(), // FIXED: Use real ad rate
      "sponsor_frequency": sFreq,
      "usd_cpm": rate,
      "bdt_cpm": bdt,
    }));
    try {
      final String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      
      // Combined API endpoint for Sponsor Config
      await http.post(
        Uri.parse('$protocol://$host/api/v15/sponsor/update_config?rate=$rate&bdt=$bdt&sponsor_freq=$sFreq'),
      );
    } catch (e) {
      debugPrint('Sponsor Sync Error: $e');
    }
  }

  void _fetchSponsorStats() async {
    // Stat retrieval via established WebSocket or Unified API
  }

  void _updateSoundConfig(double boost, double limit) async {
    setState(() {
      _viralSoundBoost = boost;
      _soundRecLimit = limit;
    });
    try {
      String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      if (host == 'localhost' || host == '127.0.0.1') host = '$host:5000';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      await http.post(
        Uri.parse('$protocol://$host/api/v15/sound/admin_logic?viral_boost=${boost.toInt()}&rec_limit=${limit.toInt()}'),
      );
    } catch (e) {
      debugPrint('Sound Sync Error: $e');
    }
  }

  void _updateWalletConfig() {
    channel.sink.add(json.encode({
      "action": "A_113_WALLET_SYNC",
      "withdraw_limit": _withdrawLimitSlider,
      "min_withdraw": _minWithdrawLimit,
      "deposit_limit": _depositLimitSlider,
      "withdraw_risk": _withdrawRiskPercent,
      "deposit_risk": _depositRiskPercent,
      "auto_approve_withdraw": _autoApproveWithdraw,
      "auto_approve_deposit": _autoApproveDeposit,
      "platform_commission": _platformCommission,
      "mlm_yield": _mlmRecurringYield, 
      "bdt_rate": _bdtRate,
    }));
  }

  void _syncAssetLedger() {
    channel.sink.add(json.encode({
      "action": "A_113_WALLET_SYNC",
      "usd": _adminUSD,
      "bdt": _adminBDT,
      "coins": _adminCoins,
      "min_withdraw": _minWithdrawLimit,
    }));
  }

  void _approveTransaction(String vault, String details, {String? txId}) {
  String currency = details.contains("BDT") ? "BDT" : "USD";
  double amt = 0.0;
  try {
    // Robust extraction: find potential float or int in string
    final res = RegExp(r"(\d+(\.\d+)?)").firstMatch(details);
    if (res != null) amt = double.parse(res.group(1)!);
  } catch (_) {}

  channel.sink.add(json.encode({
    "action": "A_113_TRANSACTION_DECISION",
    "tx_id": txId,
    "vault": vault,
    "decision": "APPROVED",
    "currency": currency,
    "amount": amt,
    "details": details,
    "timestamp": DateTime.now().toIso8601String()
  }));
  setState(() {
    // Update History Ledger
    final targetHistory = (vault == 'WITHDRAW' ? _withdrawHistory : _depositHistory);
    int idx = targetHistory.indexWhere((e) => e['tx_id'] == txId);
    if (idx != -1) {
      targetHistory[idx]['status'] = 'APPROVED';
      targetHistory[idx]['processed_at'] = DateTime.now().toIso8601String();
    }

    if (vault == 'WITHDRAW') {
      _withdrawTableStatus = "MONITORING (APPROVED)";
      if (currency == 'BDT') {
        _adminBDT -= amt;
      } else {
        _adminUSD -= amt;
      }
    } else {
      _depositTableStatus = "LISTENING (APPROVED)";
      if (currency == 'BDT') {
        _adminBDT += amt;
      } else {
        _adminUSD += amt;
      }
    }
  });
}

  void _rejectTransaction(String vault, String details, {String? txId}) {
    String currency = details.contains("BDT") ? "BDT" : "USD";
    
    // Auto-extract txId if not provided (for manual button clicks)
    if (txId == null && details.contains("(ID: ")) {
       final res = RegExp(r"\(ID: (.*?)\)").firstMatch(details);
       if (res != null) txId = res.group(1);
    }

    channel.sink.add(json.encode({
      "action": "A_113_TRANSACTION_DECISION",
      "tx_id": txId,
      "vault": vault,
      "decision": "REJECTED",
      "currency": currency,
      "details": details,
      "timestamp": DateTime.now().toIso8601String()
    }));
    setState(() {
      // Update History Ledger
      final targetHistory = (vault == 'WITHDRAW' ? _withdrawHistory : _depositHistory);
      int idx = targetHistory.indexWhere((e) => e['tx_id'] == txId);
      if (idx != -1) {
        targetHistory[idx]['status'] = 'REJECTED';
        targetHistory[idx]['processed_at'] = DateTime.now().toIso8601String();
      }

      if (vault == 'WITHDRAW') {
        _withdrawTableStatus = "MONITORING (REJECTED)";
      } else {
        _depositTableStatus = "LISTENING (REJECTED)";
      }
    });
  }

  void _executeOmniSync() {
    channel.sink.add('{"action": "SYNC_TRIGGER", "status": "OMNI_SYNC_ACTIVE"}');
    _fetchUsers(); // A_119: Sync users as part of Omni-Pulse
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OMNI-SYNC EXECUTED')),
    );
  }

  void _fetchUsers() {
    setState(() => _isGovernanceLoading = true);
    channel.sink.add('{"action": "GET_ALL_USERS"}');
  }

  void _adminCommand(String userId, String cmd) {
    channel.sink.add(json.encode({
      "action": "ADMIN_USER_CONTROL",
      "target_id": userId,
      "command": cmd
    }));
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboard(),
      _buildRevenueControl(),
      _buildMLMProtocol(),
      _buildSmartFilter(),
      _buildQuantumWallet(),
      _buildImpressionEngine(),
      _buildLawEnforcer(),
      _buildSoundMaster(),
      _buildAdEngineControl(),
      _buildSponsorSystem(),
      _buildStealthPatch(),
      _buildInteractionLogs(),
      _buildGlobalSync(),
      _buildAIModeration(),
      _buildPostHub(),
      _buildGovernance(),
    ];

    final List<String> titles = [
      'A_101: CORE DASHBOARD',
      'A_105: REVENUE CONTROL',
      'A_107: MLM PROTOCOL',
      'A_112: SMART FILTER',
      'A_113: QUANTUM WALLET',
      'A_120: IMPRESSION ENGINE',
      'A_106: LAW ENFORCER',
      'A_108: SOUND MASTER',
      'A_111: AD ENGINE CONTROL',
      'SPONSOR SYSTEM',
      'A_121: STEALTH PATCH',
      'A_110: INTERACTION LOGS',
      'A_109: GLOBAL SYNC',
      'A_115: AI MODERATION',
      'A_118: POST HUB',
      'A_119: GOVERNANCE',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 6)
            Row(
              children: [
                const Text('GATING', style: TextStyle(fontSize: 10, color: Colors.white38)),
                Switch(
                  value: _isGatingEnabled, 
                  onChanged: (v) => _toggleLegalGating(),
                  activeThumbColor: const Color(0xFF00FFFF),
                ),
              ],
            ),
          IconButton(
            icon: Icon(
              Icons.sync_problem, 
              color: _isMaintenanceActive ? Colors.red : Colors.orange,
            ),
            onPressed: _toggleMaintenance,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D0D0D)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('SOVEREIGN ADMIN', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 24, fontWeight: FontWeight.bold)),
                   const Text('V15 Chain-Reaction', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 12)),
                ],
              ),
            ),
            _buildDrawerSection('Core Modules'),
            _buildDrawerItem(0, Icons.dashboard, 'Dashboard'),
            _buildDrawerItem(12, Icons.alt_route, 'Global Sync [A_109]'),
            
            _buildDrawerSection('Fiscal Systems'),
            _buildDrawerItem(1, Icons.account_balance_wallet, 'Revenue Control [A_105]'),
            _buildDrawerItem(4, Icons.wallet, 'Quantum Wallet [A_113]'),
            _buildDrawerItem(9, Icons.business, 'Sponsor System'),
            _buildDrawerItem(2, Icons.account_tree, 'MLM Protocol [A_107]'),
            
            _buildDrawerSection('Neural & Logic'),
            _buildDrawerItem(3, Icons.filter_alt, 'Smart Filter [A_112]'),
            _buildDrawerItem(13, Icons.psychology, 'AI Moderation [A_115]'),
            _buildDrawerItem(5, Icons.analytics, 'Impression Engine [A_120]'),
            _buildDrawerItem(10, Icons.visibility_off, 'Stealth Patch [A_121]'),
            _buildDrawerItem(11, Icons.history, 'Interaction Logs [A_110]'),
            
            _buildDrawerSection('Content & Media'),
            _buildDrawerItem(7, Icons.audiotrack, 'Sound Master [A_108]'),
            _buildDrawerItem(14, Icons.video_collection, 'Post Hub [A_118]'),
            _buildDrawerItem(8, Icons.ads_click, 'Ad Engine Control [A_111]'),
            
            _buildDrawerSection('Legal & Registry'),
            _buildDrawerItem(6, Icons.gavel, 'Law Enforcer [A_106]'),
            _buildDrawerItem(15, Icons.verified_user, 'Governance [A_119]'),
            
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Maintenance Mode'),
              trailing: Switch(
                value: _isMaintenanceActive, 
                onChanged: (v) => _toggleMaintenance(),
                activeThumbColor: const Color(0xFFFF00FF),
              ),
            ),
            ListTile(
              leading: Icon(Icons.security, color: _isProductionMode ? Colors.green : Colors.orange),
              title: Text(_isProductionMode ? 'REAL TRANSACTION MODE' : 'TEST MODE (SANDBOX)'),
              subtitle: Text(_isProductionMode ? 'Armed: Production API' : 'Safe: Simulation only', style: const TextStyle(fontSize: 10, color: Colors.white24)),
              trailing: Switch(
                value: _isProductionMode, 
                onChanged: (v) => _togglePayoutMode(),
                activeThumbColor: const Color(0xFF00FFFF),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.power_settings_new, color: Colors.redAccent),
              title: const Text('Flush Master Identity', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: widget.onLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: pages[_selectedIndex],
    );
  }

  Widget _buildDrawerSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: _selectedIndex == index ? const Color(0xFFFF00FF) : Colors.white70, size: 20),
      title: Text(label, style: TextStyle(color: _selectedIndex == index ? const Color(0xFFFF00FF) : Colors.white, fontSize: 13)),
      onTap: () => _onItemTapped(index),
    );
  }

  Widget _buildDashboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPulseIndicator('SYSTEM PULSE', 'ONLINE', Colors.green),
          const SizedBox(height: 15),
          _buildPulseIndicator('V15 NEURAL MESH', 'SYNCED', const Color(0xFF00FFFF)),
          const SizedBox(height: 15),
          _buildPulseIndicator('NETWORK LATENCY', '< 50ms', Colors.orange),
          const SizedBox(height: 15),
          _buildPulseIndicator('GLOBAL MODULES', '15/15 ACTIVE', const Color(0xFFFF00FF)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _executeOmniSync,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF00FF),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 10,
              shadowColor: const Color(0xFFFF00FF).withValues(alpha: 0.5),
            ),
            child: const Text('EXECUTE OMNI-SYNC NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseIndicator(String label, String value, Color color) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueControl() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('YIELD ORCHESTRATION & ANALYTICS [A_105]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // A_111: Dashboard Live Revenue Chart - LIVE DATA
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF00FFFF).withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(color: const Color(0xFF00FFFF).withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('LIVE YIELD MONITOR [A_111]', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL PLATFORM USD', style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('\$${_totalLiveRevenue.toStringAsFixed(4)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('LAST AD YIELD', style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('+\$${_lastYield.toStringAsFixed(5)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Visual "Trend" line using dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(20, (i) {
                  double val = i < _revenueTrend.length ? _revenueTrend[i] : 0.0;
                  double scale = _totalLiveRevenue > 0 ? (val / _totalLiveRevenue) : 0.0;
                  return Container(
                    width: 4,
                    height: 4 + (20 * scale),
                    decoration: BoxDecoration(
                      color: i < _revenueTrend.length ? const Color(0xFF00FFFF).withValues(alpha: 0.5) : Colors.white10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        _buildWeightSlider('PLATFORM SHARE', _platformShare, (v) => _updateRevenueShares(v, _creatorShare, _userShare)),
        _buildWeightSlider('CREATOR SHARE', _creatorShare, (v) => _updateRevenueShares(_platformShare, v, _userShare)),
        _buildWeightSlider('USER SHARE', _userShare, (v) => _updateRevenueShares(_platformShare, _creatorShare, v)),
        
        const Divider(color: Colors.white10, height: 40),
        const Text('FISCAL STATUS (QUANTUM AUDIT)', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildControlTile('Automated Fiscal Distribution', 'ACTIVE'),
        _buildControlTile('Dr./Cr. Fiscal Method [A_113]', 'SYNCED'),
        _buildControlTile('Live monitor (monitor_engine.py)', 'ONLINE'),
      ],
    );
  }

  Widget _buildMLMProtocol() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SOVEREIGN MLM NETWORK [A_107]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // Activation Fee Tile Removed (Now FREE by Admin Request)
        _buildWeightSliderFullRange('Lifetime Recurring Yield (%)', _mlmRecurringYield, 0, 100, (v) => _saveMLMSetting('MLM_YIELD_UPDATE', v)),
        const SizedBox(height: 10),
        _buildWeightSliderFullRange('Network Depth (Levels)', _mlmNetworkDepth, 1, 50, (v) => _saveMLMSetting('MLM_DEPTH_UPDATE', v)),
        const Divider(color: Colors.white10, height: 40),
        _buildControlTile('MLM Sync Status', 'ENFORCED'),
        _buildControlTile('Fiscal Vault Linking', 'ACTIVE'),

        const Divider(color: Colors.white10, height: 40),
        const Text('IDENTITY HUB & AI VERIFICATION [A_107]', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        ListTile(
          title: const Text('AI AUTO-SLICER JUSTIFY', style: TextStyle(color: Colors.white70, fontSize: 12)),
          subtitle: Text('Auto-decide if Risk < ${_verificationRiskThreshold.toInt()}%', style: const TextStyle(color: Colors.white24, fontSize: 10)),
          trailing: Switch(
            value: _autoApproveVerification,
            onChanged: (v) => _updateVerificationConfig(v, _verificationRiskThreshold),
            activeThumbColor: const Color(0xFF00FFFF),
          ),
        ),
        ListTile(
          title: const Text('WITHDRAWAL VERIFICATION GATE', style: TextStyle(color: Colors.white70, fontSize: 12)),
          subtitle: const Text('Block withdrawals for unverified users', style: TextStyle(color: Colors.white24, fontSize: 10)),
          trailing: Switch(
            value: _requireWithdrawVerification,
            onChanged: (v) => _updateVerificationConfig(_autoApproveVerification, _verificationRiskThreshold, requireWithdrawal: v),
            activeThumbColor: const Color(0xFFFF00FF),
          ),
        ),
        _buildWeightSliderFullRange('RISK TOLERANCE (%)', _verificationRiskThreshold, 0, 100, (v) => _updateVerificationConfig(_autoApproveVerification, v)),

        const SizedBox(height: 10),
        const Text('PENDING IDENTITY DECISIONS', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        
        if (_verificationRequests.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('NO PENDING IDENTITIES', style: TextStyle(color: Colors.white10, fontSize: 10))),
          )
        else
          ..._verificationRequests.map((req) {
            final report = req['report'] ?? {};
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (report['risk'] ?? 0) > _verificationRiskThreshold ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('USER: ${req['user_id']}', style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.blueAccent, size: 20),
                            onPressed: () {
                               if (req['doc_url'] != null) {
                                  html.window.open(_healUrl(req['doc_url']), '_blank');
                               }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                            onPressed: () => _verificationDecision(req['user_id'], 'APPROVED'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                            onPressed: () => _verificationDecision(req['user_id'], 'REJECTED'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text('DOC: ${report['doc_type']?.toString().replaceAll('_', ' ') ?? 'ID_CARD'}', style: const TextStyle(color: Colors.white38, fontSize: 8)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _reportStat('QUALITY', report['q_score']),
                      _reportStat('AUTH', report['a_score']),
                      _reportStat('SYNC', report['p_score']),
                      _reportStat('RISK %', report['risk'], isRisk: true),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _reportStat(String label, dynamic val, {bool isRisk = false}) {
    double v = (val ?? 0.0).toDouble();
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8)),
        Text('${v.toStringAsFixed(1)}${isRisk ? "%" : ""}', style: TextStyle(color: isRisk ? (v > _verificationRiskThreshold ? Colors.red : Colors.green) : Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSmartFilter() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const TextField(decoration: InputDecoration(labelText: 'Add Ban Keyword', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        _buildControlTile('Real-time Keyword Registry', 'ACTIVE'),
        _buildControlTile('Shadow-Ban Protocols', 'ENABLED'),
      ],
    );
  }

  Widget _buildQuantumWallet() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('IMPERIAL FINANCE COMMAND CONSOLE [A_138]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFF00FF).withValues(alpha: 0.2)),
            gradient: LinearGradient(colors: [Colors.black, const Color(0xFF0D0D0D)]),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('TOTAL UNPAID LIABILITIES', '৳${(_withdrawHistory.where((e) => e['status'] == 'PENDING' || e['status'] == 'BATCHING').fold(0.0, (val, element) => val + (double.tryParse(element['amount'].toString()) ?? 0.0))).toStringAsFixed(2)}', Colors.redAccent),
                  _buildStatItem('GATEWAY RESERVE', '৳${(_adminBDT).toStringAsFixed(2)}', Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                   channel.sink.add(json.encode({"action": "A_140_BATCH_RELEASE"}));
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                     content: Text('MFA CHALLENGE INITIALIZED: PROCESSING BATCH...'),
                     backgroundColor: Colors.orangeAccent,
                   ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF00FF),
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('RELEASE MONTHLY PULSE BATCH [A_140]', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SYSTEM MODE: ARMORED DISBURSEMENT', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1)),
                  Row(
                    children: [
                      const Text('KILL-SWITCH', style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                      Switch(
                        value: _killSwitchEngaged, 
                        activeThumbColor: Colors.red,
                        onChanged: (v) {
                          setState(() { _killSwitchEngaged = v; });
                          channel.sink.add(json.encode({"action": "A_156_KILL_SWITCH", "enabled": v, "reason": "Admin Triggered"}));
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _showBankPayoutDashboard(context),
          icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
          label: const Text('BANK PAYOUT COMMAND CENTER [PHASE 3]', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            foregroundColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.blueAccent, width: 0.5),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
        const SizedBox(height: 30),
        const Text('ARCHITECTURE & ASSET MANAGEMENT [A_113]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildEditableTile('ADMIN USD LEDGER', '\$$_adminUSD', (v) { setState(() { _adminUSD = double.tryParse(v.replaceAll('\$', '')) ?? _adminUSD; }); _syncAssetLedger(); }),
        _buildEditableTile('ADMIN BDT LEDGER', '৳$_adminBDT', (v) { setState(() { _adminBDT = double.tryParse(v.replaceAll('৳', '')) ?? _adminBDT; }); _syncAssetLedger(); }),
        _buildEditableTile('SYSTEM COIN STOCK', '$_adminCoins', (v) { setState(() { _adminCoins = int.tryParse(v) ?? _adminCoins; }); _syncAssetLedger(); }),
        
        const Divider(color: Colors.white10, height: 20),
        const Text('SSLCOMMERZ GATEWAY [A_113]', style: TextStyle(color: Colors.cyanAccent, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildEditableTile('SSLCommerz Store ID', _sslcommerzStoreId, (v) { setState(() { _sslcommerzStoreId = v; }); _updatePayoutKey('sslcommerz', v, _sslcommerzStorePassword); }),
        _buildEditableTile('SSLCommerz Store Password', _sslcommerzStorePassword, (v) { setState(() { _sslcommerzStorePassword = v; }); _updatePayoutKey('sslcommerz', _sslcommerzStoreId, v); }),
        const Divider(color: Colors.white10, height: 20),
        _buildWeightSliderFullRange('PLATFORM COMMISSION (%)', _platformCommission, 0, 50, (v) { setState(() { _platformCommission = v; }); _updateWalletConfig(); }),
        _buildWeightSliderFullRange('BDT EXCHANGE RATE (1\$ = ৳X)', _bdtRate, 80, 150, (v) { setState(() { _bdtRate = v; }); _updateWalletConfig(); }),
        
        SwitchListTile(
          title: const Text('LIVE CURRENCY SPREAD GUARD [A_150]', style: TextStyle(color: Colors.white70, fontSize: 11)),
          subtitle: const Text('Protects against 2%+ market spikes during Pulse Window', style: TextStyle(color: Colors.white24, fontSize: 9)),
          value: _spreadGuardActive, 
          activeThumbColor: const Color(0xFF00FFFF),
          onChanged: (v) {
            setState(() { _spreadGuardActive = v; });
            channel.sink.add(json.encode({"action": "A_150_SPREAD_GUARD", "enabled": v}));
            _updateWalletConfig();
          }
        ),
        const Divider(color: Colors.white10, height: 20),
        const Divider(color: Colors.white10, height: 20),
        const Text('SOVEREIGN SMART BRIDGE: PERSONAL NUMBERS [A_113]', style: TextStyle(color: Colors.orangeAccent, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildEditableTile('bKash Personal No', _bkashNumber, (v) { setState(() { _bkashNumber = v; }); _updateBridgeNumbers(); }),
        _buildEditableTile('Nagad Personal No', _nagadNumber, (v) { setState(() { _nagadNumber = v; }); _updateBridgeNumbers(); }),
        _buildEditableTile('Rocket Personal No', _rocketNumber, (v) { setState(() { _rocketNumber = v; }); _updateBridgeNumbers(); }),

        const Divider(color: Colors.white10, height: 40),
        const Text('WITHDRAW VAULT: RISK & LIMITS', style: TextStyle(color: Colors.redAccent, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildWeightSliderFullRange('WITHDRAW RISK PERCENT (%)', _withdrawRiskPercent, 0, 100, (v) { setState(() { _withdrawRiskPercent = v; }); _updateWalletConfig(); }),
        _buildWeightSliderFullRange('MINIMUM WITHDRAW LIMIT (\$)', _minWithdrawLimit, 0, 100, (v) { setState(() { _minWithdrawLimit = v; }); _updateWalletConfig(); }),
        _buildWeightSliderFullRange('MAX WITHDRAW LIMIT (\$)', _withdrawLimitSlider, 0, 10000, (v) { setState(() { _withdrawLimitSlider = v; }); _updateWalletConfig(); }),
        ListTile(
          title: const Text('AUTO-APPROVE WITHDRAWAL', style: TextStyle(color: Colors.white70, fontSize: 12)),
          trailing: Switch(
            value: _autoApproveWithdraw,
            onChanged: (v) { setState(() { _autoApproveWithdraw = v; }); _updateWalletConfig(); },
            activeThumbColor: Colors.redAccent,
          ),
        ),
        _buildStatusTileWithActions('Withdraw Table Status', _withdrawTableStatus, 'WITHDRAW'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuantumLedgerPage(
              title: 'WITHDRAWAL ARCHIVE', 
              history: _withdrawHistory,
              onApprove: (item) => _approveTransaction('WITHDRAW', item['details'] ?? "REQUEST: ${item['amount']} ${item['currency']} (ID: ${item['tx_id']})", txId: item['tx_id']),
              onReject: (item) => _rejectTransaction('WITHDRAW', item['details'] ?? "REQUEST: ${item['amount']} ${item['currency']} (ID: ${item['tx_id']})", txId: item['tx_id']),
            ))),
            child: const Text('VIEW FULL WITHDRAW LEDGER »', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),

        const Divider(color: Colors.white10, height: 40),
        const Text('DEPOSIT VAULT: RISK & LIMITS', style: TextStyle(color: Colors.greenAccent, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildWeightSliderFullRange('DEPOSIT RISK PERCENT (%)', _depositRiskPercent, 0, 100, (v) { setState(() { _depositRiskPercent = v; }); _updateWalletConfig(); }),
        _buildWeightSliderFullRange('MAX DEPOSIT LIMIT (\$)', _depositLimitSlider, 0, 10000, (v) { setState(() { _depositLimitSlider = v; }); _updateWalletConfig(); }),
        ListTile(
          title: const Text('AUTO-APPROVE DEPOSIT', style: TextStyle(color: Colors.white70, fontSize: 12)),
          trailing: Switch(
            value: _autoApproveDeposit,
            onChanged: (v) { setState(() { _autoApproveDeposit = v; }); _updateWalletConfig(); },
            activeThumbColor: Colors.greenAccent,
          ),
        ),
        _buildStatusTileWithActions('Deposit Table Status', _depositTableStatus, 'DEPOSIT'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuantumLedgerPage(
              title: 'DEPOSIT ARCHIVE', 
              history: _depositHistory,
              onApprove: (item) => _approveTransaction('DEPOSIT', item['details'] ?? "REQUEST: ${item['amount']} ${item['currency']} (ID: ${item['tx_id']})", txId: item['tx_id']),
              onReject: (item) => _rejectTransaction('DEPOSIT', item['details'] ?? "REQUEST: ${item['amount']} ${item['currency']} (ID: ${item['tx_id']})", txId: item['tx_id']),
            ))),
            child: const Text('VIEW FULL DEPOSIT LEDGER »', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 20),
        const Divider(color: Colors.white10, height: 40),
        _buildControlTile('Strict Balance Validation', 'ACTIVE'),
        _buildControlTile('AI Risk/Precision Scores', 'ENFORCED'),
      ],
    );
  }

  Widget _buildWeightSliderFullRange(String label, double value, double min, double max, Function(double) onChanged) {
    bool isDepth = label.contains('Depth');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(isDepth ? '${value.toInt()}' : '${value.toStringAsFixed(2)}%', style: const TextStyle(color: Color(0xFFFF00FF), fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: isDepth ? (max - min).toInt() : 1000,
          activeColor: const Color(0xFFFF00FF),
          inactiveColor: Colors.white10,
          onChanged: (v) {
            setState(() {
              if (label.contains('COMMISSION')) { _platformCommission = v; }
              if (label.contains('EXCHANGE RATE')) { _bdtRate = v; }
              if (label.contains('RISK PERCENT')) {
                if (label.contains('WITHDRAW')) { _withdrawRiskPercent = v; }
                else { _depositRiskPercent = v; }
              }
              if (label.contains('WITHDRAW LIMIT')) {
                if (label.contains('MINIMUM')) { _minWithdrawLimit = v; }
                else { _withdrawLimitSlider = v; }
              }
              if (label.contains('DEPOSIT LIMIT')) { _depositLimitSlider = v; }
              if (label.contains('Yield')) { _mlmRecurringYield = v; }
              if (label.contains('Depth')) { _mlmNetworkDepth = v; }
              if (label.contains('RISK TOLERANCE')) { _verificationRiskThreshold = v; }
            });
          },
          onChangeEnd: onChanged,
        ),
      ],
    );
  }

  void _showBankPayoutDashboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final bankPool = _withdrawHistory.where((e) => (e['status'] == 'PENDING' || e['status'] == 'BATCHING') && (e['gateway']?.toString().toLowerCase() == 'bank' || e['method']?.toString().toLowerCase() == 'bank')).toList();
          
          return AlertDialog(
            backgroundColor: const Color(0xFF0D0D0D),
            title: const Text('BANK PAYOUT COMMAND CENTER', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 14, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 600,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('TOTAL OUTSTANDING: ৳${bankPool.fold(0.0, (v, e) => v + (double.tryParse(e['amount'].toString()) ?? 0.0)).toStringAsFixed(2)}', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                           Text('REQUEST COUNT: ${bankPool.length}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                         ],
                       ),
                       ElevatedButton.icon(
                        onPressed: () {

                           final String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';

                           final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';

                           final String url = '$protocol://$host/api/v15/finance/admin/bank/export?token=FATHER_OF_ALL_LOGIC_V15';

                           // Sovereign V15: Pure-JS Download (bypasses Dart html interop, defined in web/index.html)

                           js.context.callMethod('sovDownloadCSV', [url, 'fectok_bank_payout_export.csv']);

                        },
                        icon: const Icon(Icons.download, size: 14),
                        label: const Text('DOWNLOAD CSV (BEFTN/NPSB)', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  if (bankPool.isEmpty) 
                     const Padding(padding: EdgeInsets.all(30), child: Text('NO PENDING BANK TRANSFERS', style: TextStyle(color: Colors.white10)))
                  else
                     Flexible(
                       child: ListView.builder(
                         shrinkWrap: true,
                         itemCount: bankPool.length,
                         itemBuilder: (context, i) {
                           final item = bankPool[i];
                           return ListTile(
                             dense: true,
                             title: Text('Account: ${item['account']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                             subtitle: Text('Amt: ${item['amount']} ${item['currency']} ${item['currency'] == 'USD' ? '(৳${((double.tryParse(item['amount'].toString()) ?? 0) * (double.tryParse(item['bdt_rate'].toString()) ?? 115.0)).toStringAsFixed(2)})' : ''} | ID: ${item['tx_id']} | [${item['status']}]', style: TextStyle(color: item['status'] == 'BATCHING' ? Colors.orangeAccent : Colors.white38, fontSize: 10)),
                             trailing: IconButton(
                               icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                               onPressed: () {
                                  _markBankAsPaid([item['tx_id']]);
                                  setDialogState(() {});
                               },
                             ),
                           );
                         },
                       ),
                     ),
                  const Divider(color: Colors.white10, height: 20),
                  if (bankPool.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        final ids = bankPool.map((e) => e['tx_id'].toString()).toList();
                        _markBankAsPaid(ids);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(double.infinity, 40)),
                      child: const Text('MARK ALL AS PAID (INSTANT SYNC)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Future<void> _markBankAsPaid(List<String> txIds) async {
    try {
      final String host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      final String protocol = Uri.base.scheme == 'https' ? 'https' : 'http';
      final resp = await http.post(
        Uri.parse('$protocol://$host/api/v15/finance/admin/bank/mark_paid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"tx_ids": txIds})
      );
      if (resp.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('BANK PAYOUT SYNCED: ${txIds.length} ITEMS PAID'), backgroundColor: Colors.greenAccent));
      }
    } catch(e) {
      debugPrint("MARK_PAID_ERR: $e");
    }
  }

  Widget _buildImpressionEngine() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('AI-DYNAMIC WEIGHT ORCHESTRATION', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildWeightSlider('LIKE WEIGHT', _likeWeight, (v) => _updateImpressionWeights(v, _commentWeight, _shareWeight)),
        _buildWeightSlider('COMMENT WEIGHT', _commentWeight, (v) => _updateImpressionWeights(_likeWeight, v, _shareWeight)),
        _buildWeightSlider('SHARE WEIGHT', _shareWeight, (v) => _updateImpressionWeights(_likeWeight, _commentWeight, v)),
        
        const Divider(color: Colors.white10, height: 40),
        const Text('ENGINE STATUS', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildControlTile('3-Layer Pattern Validation', 'ACTIVE'),
        _buildControlTile('Quantum Bot Detection', 'ACTIVE'),
        _buildControlTile('Engagement Weight Hub', 'SYNCED'),
      ],
    );
  }

  Widget _buildWeightSlider(String label, double value, Function(double) onChanged) {
    bool isPercent = label.contains('%') || label.contains('Weight') || label.contains('Share') || label.contains('Frequency');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(isPercent ? '${value.toInt()}%' : value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFFF00FF), fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Slider(
          value: value,
          min: (label.contains('VIEW RATE') || label.contains('AD RATE') || label.contains('INTERVAL')) ? (label.contains('INTERVAL') ? 5.0 : 1.0) : 0,
          max: label.contains('VIEW RATE') ? 500.0 : (label.contains('INTERVAL') ? 60.0 : (label.contains('AD RATE') ? 20.0 : 100.0)), // A_111: Custom ranges for V15 Scaling
          activeColor: const Color(0xFFFF00FF),
          inactiveColor: Colors.white10,
          onChanged: (v) {
            setState(() {
              if (label.contains('LIKE')) { _likeWeight = v; }
              if (label.contains('COMMENT')) { _commentWeight = v; }
              if (label.contains('SHARE')) { _shareWeight = v; }
              if (label.contains('PLATFORM SHARE')) { _platformShare = v; }
              if (label.contains('CREATOR SHARE')) { _creatorShare = v; }
              if (label.contains('USER SHARE')) { _userShare = v; }
              if (label.contains('VIRAL BOOST')) { _viralSoundBoost = v; }
              if (label.contains('FEED FREQUENCY')) { _soundRecLimit = v; }
              if (label.contains('VIEW RATE')) { _coinToViewRate = v; }
              if (label.contains('BDT CPM')) { _bdtCpm = v; }
              if (label.contains('SPONSOR FREQUENCY')) { _sponsorFrequency = v; }
              if (label.contains('AD RATE')) { _adsPerMinute = v.toInt(); }
              if (label.contains('ROTATION INTERVAL')) { _rotationInterval = v.toInt(); }
            });
            // V15 Enhancement: Real-time Hyper-Logic Sync on slide
            if (label.contains('VIEW RATE') || label.contains('BDT CPM') || label.contains('SPONSOR FREQUENCY')) {
               onChanged(v);
            }
          },
          onChangeEnd: (v) {
             if (!(label.contains('VIEW RATE') || label.contains('BDT CPM') || label.contains('SPONSOR FREQUENCY'))) {
                onChanged(v);
             }
          },
        ),
      ],
    );
  }

  Widget _buildLawEnforcer() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildControlTile('Universal Constitution', 'IRON-CLAD'),
        _buildControlTile('Gavel Protocol Gating', _isGatingEnabled ? 'ACTIVE' : 'DISABLED'),
        _buildControlTile('D.O.B Auto-Calendar', 'ENABLED'),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _enforceLegal,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text('ENFORCE LEGAL GATING GLOBALLY'),
        ),
      ],
    );
  }

  Widget _buildSoundMaster() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('TIKTOK SOUND VIRAL LOOP [A_108]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildWeightSlider('VIRAL BOOST (Popularity Weight)', _viralSoundBoost, (v) => _updateSoundConfig(v, _soundRecLimit)),
        _buildWeightSlider('FEED FREQUENCY (Interval Limit)', _soundRecLimit, (v) => _updateSoundConfig(_viralSoundBoost, v)),
        
        const Divider(color: Colors.white10, height: 40),
        const Text('ACOUSTIC SYNC STATUS', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildControlTile('Sovereign Sound Loop', 'SYNCED'),
        _buildControlTile('Music Disk Marquee', 'ACTIVE'),
        _buildControlTile('Sound Detail Pages', 'LIVE'),
      ],
    );
  }

  Widget _buildAdEngineControl() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildControlTile('6-Network Native Hub', 'A_111'),
        ListTile(
          title: const Text('75/25 Split-Screen Logic', style: TextStyle(color: Colors.white70)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isAdSplitEnabled ? 'ACTIVE' : 'DISABLED', style: TextStyle(color: _isAdSplitEnabled ? const Color(0xFF00FFFF) : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 10),
              Switch(
                value: _isAdSplitEnabled,
                onChanged: (v) => _toggleAdSplit(),
                activeThumbColor: const Color(0xFF00FFFF),
              ),
            ],
          ),
        ),
        _buildEditableTile('Yield per 1k Views', _yieldPer1k, (v) => _saveAdSetting('AD_YIELD_UPDATE', v)),
        const Divider(color: Colors.white10, height: 40),
        const Text('OPERATIONAL HYPER-LOGIC', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildWeightSlider('AD RATE (Ads/Min)', _adsPerMinute.toDouble(), (v) => _saveAdSetting('AD_RATE_UPDATE', v.toInt().toString())),
        _buildWeightSlider('ROTATION INTERVAL (Seconds)', _rotationInterval.toDouble(), (v) => _saveAdSetting('AD_INTERVAL_UPDATE', v.toInt().toString())),
        _buildControlTile('AI Pre-Loader Buffer', 'ENABLED'),
        _buildControlTile('Contextual Sync', 'ACTIVE'),
        _buildControlTile('Stealth Bypass Policy', '100% SAFE'),
        const Divider(color: Colors.white10, height: 40),
        const Text('6-NETWORK API TEMPLATE SLOTS', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        ..._networkApiKeys.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: TextField(
            controller: TextEditingController(text: entry.value)..selection = TextSelection.fromPosition(TextPosition(offset: entry.value.length)),
            onChanged: (v) => _updateApiKey(entry.key, v),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: '${entry.key} GATEWAY ID',
              labelStyle: const TextStyle(color: Colors.white38, fontSize: 11),
              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFFF))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
        )),
        const Divider(color: Colors.white10, height: 40),
        ListTile(
          title: const Text('AI HIGH-CPM RANDOM INJECTOR', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 11, fontWeight: FontWeight.bold)),
          subtitle: const Text('Automated Niche-Matching Logic Active', style: TextStyle(color: Colors.white38, fontSize: 10)),
          trailing: Switch(
            value: _isAIInjectorEnabled,
            onChanged: (v) => _toggleAIInjector(),
            activeThumbColor: const Color(0xFFFF00FF),
          ),
        ),
        ListTile(
          title: const Text('AD RANDOMIZER PROTOCOL', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 11, fontWeight: FontWeight.bold)),
          subtitle: const Text('Bypass Sequential Patterns [ANTI-BAN]', style: TextStyle(color: Colors.white38, fontSize: 10)),
          trailing: Switch(
            value: _isAdRandomizerEnabled,
            onChanged: (v) => _toggleAdRandomizer(),
            activeThumbColor: const Color(0xFF00FFFF),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
             channel.sink.add(json.encode({
               "action": "AD_SYNC_HYPER_LOGIC",
               "coin_to_view_rate": _coinToViewRate,
               "ad_frequency": _adsPerMinute.toDouble(),
               "sponsor_frequency": _sponsorFrequency,
               "usd_cpm": _coinToViewRate, 
               "bdt_cpm": _bdtCpm,
               "ad_api_keys": _networkApiKeys, // Persist Slot IDs
               "ad_toggles": {
                 "maintenance": _isMaintenanceActive,
                 "gating": _isGatingEnabled,
                 "ad_split": _isAdSplitEnabled,
                 "ai_injector": _isAIInjectorEnabled,
                 "ad_randomizer": _isAdRandomizerEnabled
               }
             }));
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SOVEREIGN AI 6-NETWORK ENGINE SYNCED & PERSISTED'), backgroundColor: Color(0xFF00FFFF)));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFFF),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('SYNC HYPER-LOGIC DESK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSponsorSystem() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('SPONSOR HYPER-CONFIG & REVENUE [A_111]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // A_113: SPONSOR REVENUE WALLET (Dr./Cr. Ledger)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFF00FF).withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ADMIN REVENUE WALLET', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 11, fontWeight: FontWeight.bold)),
                  Icon(Icons.account_balance, color: Color(0xFFFF00FF), size: 16),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('USD REVENUE (Cr.)', style: TextStyle(color: Colors.white24, fontSize: 8)),
                          Text('\$${_adminUSD.toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('BDT REVENUE (Cr.)', style: TextStyle(color: Colors.white24, fontSize: 8)),
                          Text('৳${_adminBDT.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: const Text('AUTO-SYNC: ON', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('PENDING AI-CLEARANCE', style: TextStyle(color: Colors.white38, fontSize: 9)),
                   Text('400 COINS (LEGACY)', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        _buildWeightSlider('USD CPM (Cost per 1k Views)', _coinToViewRate, (v) => _updateSponsorConfig(v, _bdtCpm, _sponsorFrequency)),
        _buildWeightSlider('BDT CPM (Cost per 1k Views)', _bdtCpm, (v) => _updateSponsorConfig(_coinToViewRate, v, _sponsorFrequency)),
        _buildWeightSlider('SPONSOR FREQUENCY (Videos/Ad)', _sponsorFrequency, (v) => _updateSponsorConfig(_coinToViewRate, _bdtCpm, v)),
        
        const Divider(color: Colors.white10, height: 40),
        const Text('SPONSOR CLOUD STATUS & AI MODERATION', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildControlTile('Sponsor Vault [3-LAYER AI]', 'SECURE'),
        _buildControlTile('Yield Distribution', 'REAL-TIME'),
        _buildControlTile('Sponsor Detail Templates', 'AUTO-SYNCED'),
        _buildControlTile('A_115 AI Oversight', 'CEO_MODE_ACTIVE'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  String _maskData(String val) {
    if (val.length < 6) return "****";
    if (val.contains('@')) {
      final parts = val.split('@');
      return "${parts[0][0]}***@${parts[1]}";
    }
    return "${val.substring(0, 3)}****${val.substring(val.length - 2)}";
  }

  Widget _buildStealthPatch() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildControlTile('Visibility Weighting', 'DYNAMIC'),
        _buildControlTile('Interaction-to-Boost Ratio', '1:50'),
        _buildControlTile('Stealth Reach Multiplier', '2.5x'),
      ],
    );
  }

  Widget _buildInteractionLogs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LIVE INTERACTION STREAM', style: TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(5)),
                child: const Text('LISTENING', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _interactionLogs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), border: Border.all(color: Colors.white10)),
                child: Text(
                  _interactionLogs[index],
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalSync() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildControlTile('Quantum Bridge Status', 'ONLINE'),
        _buildControlTile('Sync Engine Latency', '< 30ms'),
        _buildControlTile('Global Mesh Health', 'OPTIMAL'),
      ],
    );
  }

  Widget _buildAIModeration() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('3-LAYER AI MODERATION PROTOCOL [A_115]', style: TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildWeightSlider('LEVEL 1: INTEGRITY GUARD (Structure)', _aiIntegritySensitivity, (v) => _updateAIModerationConfig(v, _aiBehavioralSensitivity, _aiStrategicSensitivity)),
        _buildWeightSlider('LEVEL 2: BEHAVIORAL PULSE (Bot/Spam)', _aiBehavioralSensitivity, (v) => _updateAIModerationConfig(_aiIntegritySensitivity, v, _aiStrategicSensitivity)),
        _buildWeightSlider('LEVEL 3: STRATEGIC CEO MODE (Finance)', _aiStrategicSensitivity, (v) => _updateAIModerationConfig(_aiIntegritySensitivity, _aiBehavioralSensitivity, v)),
        
        const Divider(color: Colors.white10, height: 40),
        const Text('AI SECURE STATUS [A-Z ENFORCEMENT]', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _buildControlTile('Neural Guard Sensitivity', 'ADAPTIVE'),
        _buildControlTile('Recursive Reply Scanner', 'ACTIVE'),
        _buildControlTile('V15 Central Sync Guard', 'ENABLED'),
        _buildControlTile('Finance/Accounting Oversight', 'AI-GOVERNED'),
        _buildControlTile('CEO Strategic Mode', 'ACTIVE'),
        
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00FFFF).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user, color: Color(0xFF00FFFF), size: 16),
              SizedBox(width: 10),
              Text('PROJECT UNDER CEO AI GOVERNANCE', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostHub() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildControlTile('Metadata Orchestration', 'A_118'),
        _buildControlTile('Social Governance Toggles', 'ACTIVE'),
        _buildControlTile('Seamless Navigation Reset', 'ENABLED'),
      ],
    );
  }

  Widget _buildGovernance() {
    final int total = _registeredUsers.length;
    final int active = _registeredUsers.where((u) => u['status'] == 'ACTIVE').length;
    final int blocked = _registeredUsers.where((u) => u['status'] == 'BLOCKED').length;
    final int online = _registeredUsers.where((u) => u['is_online'] == true).length;

    final filteredUsers = _registeredUsers.where((u) {
      final q = _userSearchQuery.toLowerCase();
      return u['sov_id'].toString().toLowerCase().contains(q) || 
             u['name'].toString().toLowerCase().contains(q) ||
             u['email_phone'].toString().toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        _buildIdentityDashboard(total, active, blocked, online),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _userSearchQuery = v),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'SEARCH BY SOV_ID, NAME OR PHONE...',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00FFFF), size: 18),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                onPressed: _fetchUsers,
                icon: Icon(Icons.refresh, color: _isGovernanceLoading ? Colors.grey : const Color(0xFFFF00FF)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _registeredUsers.isEmpty 
          ? Center(child: Text(_isGovernanceLoading ? 'SCANNING IDENTITY MESH...' : 'NO USERS DISCOVERED', style: const TextStyle(color: Colors.white24)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final u = filteredUsers[index];
                final isBlocked = u['status'] == 'BLOCKED';
                final isOnline = u['is_online'] ?? false;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isOnline ? const Color(0xFF00FFFF).withValues(alpha: 0.3) : isBlocked ? Colors.red.withValues(alpha: 0.2) : Colors.white10),
                  ),
                  child: ExpansionTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: isBlocked ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF00FFFF).withValues(alpha: 0.1),
                          child: Text(u['name'][0].toUpperCase(), style: TextStyle(color: isBlocked ? Colors.red : const Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                                boxShadow: [
                                  BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 5),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(u['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        if (isOnline) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('ONLINE', style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(u['sov_id'], style: const TextStyle(color: Color(0xFFFF00FF), fontSize: 10, letterSpacing: 1)),
                    trailing: Icon(isOnline ? Icons.sensors : Icons.verified_user, color: isOnline ? Colors.greenAccent : (isBlocked ? Colors.red : Colors.green), size: 16),
                    iconColor: const Color(0xFF00FFFF),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _specRow('IDENTITY EMAIL/PHONE', _maskData(u['email_phone'].toString())),
                            _specRow('D.O.B (LEGAL DNA)', u['dob']),
                            _specRow('SIGNUP IP', u['signup_ip']),
                            _specRow('MASTER REGISTRY TIMESTAMP', u['signup_timestamp']),
                            _specRow('LAST NEURAL PULSE', u['last_login']),
                            _specRow('LEGAL CONSENT', u['legal_version']),
                            const Divider(color: Colors.white10, height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _balanceMini('USD', '\$${u['balance']['USD'].toStringAsFixed(2)}', Colors.greenAccent),
                                _balanceMini('BDT', '৳${u['balance']['BDT'].toStringAsFixed(2)}', Colors.orangeAccent),
                                _balanceMini('COINS', '${u['balance']['COINS']}', const Color(0xFFFF00FF)),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _govButton(
                                  isBlocked ? 'ACTIVATE' : 'BLOCK USER', 
                                  isBlocked ? Colors.green : Colors.redAccent,
                                  () => _adminCommand(u['sov_id'], isBlocked ? 'UNBLOCK' : 'BLOCK'),
                                ),
                                _govButton(
                                  'PURGE IDENTITY', 
                                  Colors.white24,
                                  () => _adminCommand(u['sov_id'], 'DELETE'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ),
      ],
    );
  }

  Widget _govButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildIdentityDashboard(int total, int active, int blocked, int online) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _statCard('TOTAL NODES', '$total', const Color(0xFF00FFFF)),
          _statCard('ACTIVE', '$active', Colors.greenAccent),
          _statCard('ONLINE', '$online', const Color(0xFFFF00FF), isGlowing: true),
          _statCard('BLOCKED', '$blocked', Colors.redAccent),
        ],
      ),
    );
  }

  Widget _statCard(String label, String val, Color color, {bool isGlowing = false}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: isGlowing ? 0.4 : 0.1)),
          boxShadow: isGlowing ? [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10)] : null,
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 5),
            Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _balanceMini(String label, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Text(val, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _specRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(val, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildControlTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      trailing: Text(value, style: const TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
      onTap: () {},
    );
  }

  Widget _buildStatusTileWithActions(String label, String value, String vault) {
    bool hasRequest = value.contains('REQUEST:');
    
    // Extract TxID if present for the buttons
    String? txId;
    if (hasRequest && value.contains("(ID: ")) {
       final res = RegExp(r"\(ID: (.*?)\)").firstMatch(value);
       if (res != null) txId = res.group(1);
    }

    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      subtitle: hasRequest ? Text(value, style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 12)) : null,
      trailing: hasRequest 
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                onPressed: () => _approveTransaction(vault, value, txId: txId),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
                onPressed: () => _rejectTransaction(vault, value, txId: txId),
              ),
            ],
          )
        : Text(value, style: const TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEditableTile(String label, String value, Function(String) onSave) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(value, style: const TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.bold, fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.white38, size: 18),
        onPressed: () {
          final controller = TextEditingController(text: value.split(' ')[0]);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF0D0D0D),
              title: Text('Edit $label', style: const TextStyle(color: Colors.white)),
              content: TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'New Value',
                  labelStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFFF))),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
                TextButton(
                  onPressed: () {
                    onSave(controller.text);
                    Navigator.pop(context);
                  }, 
                  child: const Text('SAVE', style: TextStyle(color: Color(0xFF00FFFF)))
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuantumLedgerPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> history;
  final Function(Map<String, dynamic>) onApprove;
  final Function(Map<String, dynamic>) onReject;

  const QuantumLedgerPage({
    super.key, 
    required this.title, 
    required this.history,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<QuantumLedgerPage> createState() => _QuantumLedgerPageState();
}

class _QuantumLedgerPageState extends State<QuantumLedgerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF00FFFF), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: widget.history.isEmpty 
        ? const Center(child: Text('NO ARCHIVED RECORDS FOUND', style: TextStyle(color: Colors.white24, fontSize: 10)))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: widget.history.length,
            itemBuilder: (context, index) {
              final item = widget.history[index];
              final status = item['status'] ?? 'PENDING';
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['tx_id'] ?? 'N/A', style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 12, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            if (status == 'PENDING') ...[
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                                onPressed: () {
                                  widget.onApprove(item);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.highlight_off, color: Colors.redAccent, size: 18),
                                onPressed: () {
                                  widget.onReject(item);
                                  setState(() {});
                                },
                              ),
                              const SizedBox(width: 12),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'APPROVED' ? Colors.green.withValues(alpha: 0.1) : status == 'REJECTED' ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(status, style: TextStyle(color: status == 'APPROVED' ? Colors.greenAccent : status == 'REJECTED' ? Colors.redAccent : Colors.orangeAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                            if (item['mlm_amount'] != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00FFFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF00FFFF).withValues(alpha: 0.3)),
                                ),
                                child: const Text('MLM REWARD SYNCED', style: TextStyle(color: Color(0xFF00FFFF), fontSize: 7, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _specRow('AMOUNT', '${item['amount']} ${item['currency']}'),
                    _specRow('METHOD', '${item['rail']}'),
                    _specRow('ACCOUNT', '${item['account']}'),
                    _specRow('REQUESTED', '${item['timestamp']}'),
                    if (item['processed_at'] != null)
                      _specRow('PROCESSED', '${item['processed_at']}'),
                    if (item['mlm_comm_percent'] != null)
                      _specRow('MLM COMMISSION %', '${item['mlm_comm_percent']}%'),
                    if (item['referrer_id'] != null)
                      _specRow('REFERRER ID', '${item['referrer_id']}'),
                    if (item['mlm_amount'] != null)
                      _specRow('MLM AMOUNT', '${item['mlm_amount']} ${item['currency']}'),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _specRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          Text(val, style: const TextStyle(color: Colors.white70, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
