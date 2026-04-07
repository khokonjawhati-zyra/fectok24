import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// ═══════════════════════════════════════════════════════════════
// SOVEREIGN V15: UNIVERSAL DYNAMIC SMS BRIDGE [A_124 DNA]
// ═══════════════════════════════════════════════════════════════
// Developed for: lovetok / fectok.com
// Purpose: Intercept MFS SMS and Forward to DigitalOcean Node

void main() => runApp(const SovereignSMSBridge());

class SovereignSMSBridge extends StatelessWidget {
  const SovereignSMSBridge({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        primaryColor: const Color(0xFF00F2FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FF),
          secondary: Color(0xFF0D1117),
        ),
      ),
      home: const BridgeDashboard(),
    );
  }
}

class BridgeDashboard extends StatefulWidget {
  const BridgeDashboard({super.key});
  @override
  State<BridgeDashboard> createState() => _BridgeDashboardState();
}

class _BridgeDashboardState extends State<BridgeDashboard> {
  final Telephony telephony = Telephony.instance;
  
  // DYNAMIC SLOTS [A_124]
  final TextEditingController _domainController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _stationController = TextEditingController();
  
  bool _isBridgeActive = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  // Load Saved Slots from Memory
  _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _domainController.text = prefs.getString('domain') ?? "http://167.71.193.34";
      _keyController.text = prefs.getString('key') ?? "SOV_V15_GOD_MODE_777";
      _stationController.text = prefs.getString('station') ?? "FECTOK_MAIN_NODE";
      _isBridgeActive = prefs.getBool('active') ?? false;
      
      if (_isBridgeActive) _startSmsService();
    });
  }

  // Save Config to Memory
  _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('domain', _domainController.text);
    await prefs.setString('key', _keyController.text);
    await prefs.setString('station', _stationController.text);
    await prefs.setBool('active', _isBridgeActive);
    _addLog("SYSTEM: Config Saved & Synchronized.");
  }

  // SMS Ignition Pulse
  void _startSmsService() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        String sender = message.address?.toUpperCase() ?? "";
        String body = message.body ?? "";

        // Filter: bKash (bKash), Nagad (NAGAD), Rocket (16216)
        if (sender.contains("BKASH") || sender.contains("NAGAD") || sender.contains("16216") || sender.contains("ROCKET")) {
          _processSms(sender, body);
        }
      },
      listenInBackground: true,
    );
  }

  void _processSms(String sender, String body) {
    _addLog("INTERCEPT: Found MFS SMS from $sender");
    
    // Pattern Search for TxID (Alphanumeric 8-10 chars) and Amount
    RegExp txPattern = RegExp(r"(TrxID|TxID|Transaction ID|OID):\s*([A-Z0-9]+)", caseSensitive: false);
    RegExp amtPattern = RegExp(r"(Amount|Tk|৳|Amt)\s*([0-9.,]+)", caseSensitive: false);

    String trxId = txPattern.firstMatch(body)?.group(2) ?? "NULL_TXID";
    String amtRaw = amtPattern.firstMatch(body)?.group(2) ?? "0";
    double amt = double.tryParse(amtRaw.replaceAll(',', '')) ?? 0.0;

    if (trxId != "NULL_TXID") {
      _addLog("EXTRACTED: ID: $trxId | AMT: $amt");
      _dispatchToServer(sender, trxId, amt);
    } else {
      _addLog("WARN: Failed to extract TxID from Message Body.");
    }
  }

  void _dispatchToServer(String sender, String trxId, double amt) async {
    String endpoint = "${_domainController.text}/api/v15/finance/webhook/sms";
    
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "sender": sender,
          "trx_id": trxId,
          "amount": amt,
          "method": sender.contains("BKASH") ? "bKash" : (sender.contains("NAGAD") ? "Nagad" : "Rocket"),
          "secret_key": _keyController.text,
          "station_id": _stationController.text
        }),
      );

      if (response.statusCode == 200) {
        _addLog("DISPATCH: Succeeded. Pulse Logged at DigitalOcean Node.");
      } else {
        _addLog("ALARM: Server Rejected Pulse. Code: ${response.statusCode}");
      }
    } catch (e) {
      _addLog("ERROR: Connection Refused. Check Server IP/Domain.");
    }
  }

  void _addLog(String msg) {
    String timestamp = "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";
    setState(() => _logs.insert(0, "[$timestamp] $msg"));
    if (_logs.length > 50) _logs.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1117), Color(0xFF010409)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER [Cyberpunk]
              _buildHeader(),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 20),
                    _buildSectionHeader("ACTIVE SLOTS"),
                    _buildSlot("SERVER ADDRESS (IP or Domain)", _domainController, Icons.dns),
                    _buildSlot("AUTH KEY (Nexus Secret)", _keyController, Icons.lock, obscure: true),
                    _buildSlot("DEVICE STATION ID", _stationController, Icons.router),
                    
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    
                    const SizedBox(height: 30),
                    _buildSectionHeader("PULSE MONITOR"),
                    _buildLogPanel(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SOVEREIGN V15", style: TextStyle(color: Color(0xFF00F2FF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              Text("SMS BRIDGE", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          SpinKitPulse(color: _isBridgeActive ? Colors.greenAccent : Colors.redAccent, size: 40),
        ],
      ),
    );
  }

  Widget _buildSlot(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: const TextStyle(color: Color(0xFF00F2FF), fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() => _isBridgeActive = !_isBridgeActive);
            _saveConfig();
            if (_isBridgeActive) _startSmsService();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isBridgeActive 
                  ? [Colors.greenAccent.withValues(alpha: 0.8), Colors.green.withValues(alpha: 0.8)]
                  : [const Color(0xFF00F2FF).withValues(alpha: 0.8), const Color(0xFF00BCC6).withValues(alpha: 0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: (_isBridgeActive ? Colors.greenAccent : const Color(0xFF00F2FF)).withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Text(
                _isBridgeActive ? "PULSE STATUS: ACTIVE" : "IGNITE BRIDGE",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogPanel() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _logs.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _logs[i],
              style: const TextStyle(fontSize: 10, color: Colors.greenAccent, fontFamily: 'monospace'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }
}
