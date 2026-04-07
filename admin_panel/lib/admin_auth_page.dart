import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AdminAuthPage extends StatefulWidget {
  final Function(String token) onAuthSuccess;

  const AdminAuthPage({super.key, required this.onAuthSuccess});

  @override
  State<AdminAuthPage> createState() => _AdminAuthPageState();
}

class _AdminAuthPageState extends State<AdminAuthPage> with TickerProviderStateMixin {
  final TextEditingController _masterPassController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  int _failedAttempts = 0;
  String? _errorMessage;
  
  // Animation controllers for Matrix background
  late AnimationController _matrixController;
  
  final List<int> _pinNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];

  @override
  void initState() {
    super.initState();
    _matrixController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _shufflePin();
  }

  // Sovereign V15: Dynamic Host Detection for Mirror Parity
  String get _currentHost {
    if (Uri.base.host.isNotEmpty) return Uri.base.host;
    return '167.71.193.34'; // Fallback for direct node access
  }
  
  String get _apiBaseUrl {
    // If running on domain, ports are handled by Nginx paths
    if (Uri.base.host.contains('fectok.com')) return 'https://$_currentHost';
    return 'http://$_currentHost:5000'; // Localhost/IP standby
  }

  @override
  void dispose() {
    _matrixController.dispose();
    _masterPassController.dispose();
    _pinController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _shufflePin() {
    setState(() {
      _pinNumbers.shuffle();
    });
  }

  Future<void> _handleInitialLogin() async {
    if (_masterPassController.text.isEmpty || _pinController.text.isEmpty) {
      _showError("Credentials Required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/admin_auth_init'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'master_key': _masterPassController.text,
          'pin': _pinController.text,
          'hwid': 'ADMIN_NODE_ALPHA_V15', // Simulation of Hardware ID
        }),
      );

      final result = json.decode(response.body);

      if (!mounted) return;

      if (result['status'] == 'SUCCESS') {
        setState(() {
          _otpSent = true;
          _isLoading = false;
          _errorMessage = null;
        });
        _showSuccess("Master Pulse Sent to Registered Email.");
      } else {
        _handleFailure(result['reason'] ?? "Access Denied");
      }
    } catch (e) {
      _showError("Neural Link Failure: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/admin_auth_verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'otp': _otpController.text,
          'hwid': 'ADMIN_NODE_ALPHA_V15',
        }),
      );

      final result = json.decode(response.body);

      if (!mounted) return;

      if (result['status'] == 'SUCCESS') {
        widget.onAuthSuccess(result['token']);
      } else {
        _showError("Invalid Pulse Token");
      }
    } catch (e) {
      _showError("Verification Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFailure(String reason) {
    setState(() {
      _failedAttempts++;
      _errorMessage = "ALERT: $reason [Attempt $_failedAttempts/3]";
    });
    if (_failedAttempts >= 3) {
      _showError("SYSTEM LOCKDOWN INITIATED");
      // Panic Mode logic can be added here
    }
  }

  void _showError(String msg) {
    setState(() => _errorMessage = msg);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.greenAccent.withValues(alpha: 0.2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          _buildMatrixBackground(),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF00FF).withValues(alpha: 0.3), width: 1),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF00FF).withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    if (!_otpSent) ...[
                      _buildMasterField(),
                      const SizedBox(height: 20),
                      _buildPinPad(),
                      const SizedBox(height: 30),
                      _buildLoginButton(),
                    ] else ...[
                      _buildOtpField(),
                      const SizedBox(height: 30),
                      _buildVerifyButton(),
                      TextButton(
                        onPressed: () => setState(() => _otpSent = false),
                        child: const Text("Re-Authorize", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      )
                    ],
                    if (_errorMessage != null)
                      Padding(
                        padding: const Duration(milliseconds: 200) < const Duration(seconds: 1) ? const EdgeInsets.only(top: 20) : EdgeInsets.zero,
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixBackground() {
    return AnimatedBuilder(
      animation: _matrixController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: MatrixPainter(_matrixController.value),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.security, color: Color(0xFFFF00FF), size: 50),
        const SizedBox(height: 10),
        const Text(
          "CORE GOVERNANCE v1.5.3",
          style: TextStyle(color: Color(0xFFFF00FF), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
        ),
        const Text("V15-GATEWAY-SYNC [MIRROR]", style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
        Text(
          "SOVEREIGN V15 MASTER ACCESS",
          style: TextStyle(color: Colors.blueAccent.withValues(alpha: 0.7), fontSize: 10, letterSpacing: 2),
        ),
      ],
    );
  }

  Widget _buildMasterField() {
    return TextField(
      controller: _masterPassController,
      obscureText: true,
      style: const TextStyle(color: Colors.white, letterSpacing: 4),
      decoration: InputDecoration(
        labelText: "MASTER KEY",
        labelStyle: const TextStyle(color: Colors.grey, letterSpacing: 2),
        prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFFFF00FF)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF00FF))),
      ),
    );
  }

  Widget _buildPinPad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("SECURITY PIN", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2)),
            Text(_pinController.text.replaceAll(RegExp(r'.'), '*'), style: const TextStyle(color: Color(0xFF00FFFF), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _pinNumbers.map((n) {
            return InkWell(
              onTap: () {
                if (_pinController.text.length < 6) {
                  setState(() => _pinController.text += n.toString());
                  _shufflePin();
                }
              },
              child: Container(
                width: 60,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.white.withValues(alpha: 0.02), Colors.white.withValues(alpha: 0.05)],
                  ),
                ),
                child: Text(n.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList()
            ..add(
              InkWell(
                onTap: () => setState(() => _pinController.clear()),
                child: Container(
                  width: 60,
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.backspace, color: Colors.redAccent, size: 18),
                ),
              ),
            ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleInitialLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF00FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("INITIALIZE HANDSHAKE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildOtpField() {
    return Column(
      children: [
        const Icon(Icons.mark_email_unread, color: Color(0xFF00FFFF), size: 40),
        const SizedBox(height: 20),
        const Text("ENTER MASTER PULSE", style: TextStyle(color: Colors.grey, letterSpacing: 3)),
        const SizedBox(height: 20),
        TextField(
          controller: _otpController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: Color(0xFF00FFFF), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
          decoration: const InputDecoration(
            counterText: "",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFFF))),
          ),
          onChanged: (v) {
            if (v.length == 6) _verifyOtp();
          },
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFFF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.black)
          : const Text("AUTHORIZE ACCESS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}

class MatrixPainter extends CustomPainter {
  final double progress;
  MatrixPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF00FF).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
        double x = (size.width / 12) * i;
        double y = (size.height * ((progress + (i * 0.15)) % 1.0));
        canvas.drawCircle(Offset(x, y), 1.5, paint);
        canvas.drawLine(Offset(x, 0), Offset(x, y), 
          Paint()..color = const Color(0xFFFF00FF).withValues(alpha: 0.1)..strokeWidth = 0.5
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
