import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SovereignAuthPage extends StatefulWidget {
  final Function(String id, String name, String profession) onAuthComplete;
  final VoidCallback? onGuidelinesTap;

  const SovereignAuthPage({super.key, required this.onAuthComplete, this.onGuidelinesTap});

  @override
  State<SovereignAuthPage> createState() => _SovereignAuthPageState();
}

class _SovereignAuthPageState extends State<SovereignAuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _floatAnimation1;
  late Animation<Offset> _floatAnimation2;
  late Animation<Offset> _floatAnimation3;
  late Animation<Offset> _floatAnimation4;
  
  bool isLogin = true;
  bool isForgotPassword = false;
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _resetCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDOB;
  bool _termsAccepted = false;
  bool _rememberMe = false;
  bool _isLoading = true;
  bool isVerifyingOTP = false;
  String? _temporarySovId;
  String? _activeEmailPulse;
  String? _referrerName; 
  int _lockoutSeconds = 0; 
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Sovereign V15: Referral Auto-Sync Pulse [A_107]
    if (kIsWeb) {
      // Robust URL Parameter extraction using standard Uri.base
      final String? refCode = Uri.base.queryParameters['ref'] ?? 
                             (Uri.parse(Uri.base.toString().replaceAll('#', '?')).queryParameters['ref']);
      
      if (refCode != null && refCode.isNotEmpty) {
        _referralController.text = refCode;
        isLogin = false; // Force Registration Mode
      }
    }

    _floatAnimation1 = Tween<Offset>(begin: const Offset(-0.4, -0.4), end: const Offset(0.4, 0.4))
        .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)));

    _floatAnimation2 = Tween<Offset>(begin: const Offset(0.4, 0.4), end: const Offset(-0.4, -0.4))
        .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.25, 0.75, curve: Curves.easeInOut)));

    _floatAnimation3 = Tween<Offset>(begin: const Offset(-0.4, 0.4), end: const Offset(0.4, -0.4))
        .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
        
    _floatAnimation4 = Tween<Offset>(begin: const Offset(0.4, -0.4), end: const Offset(-0.4, 0.4))
        .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.6, curve: Curves.easeInOut)));

    _referralController.addListener(_onReferralChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lockoutTimer?.cancel();
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    _referralController.dispose();
    _professionController.dispose();
    _resetCodeController.dispose();
    super.dispose();
  }

  void _onReferralChanged() {
    if (!isLogin && _referralController.text.length >= 6) {
      _checkReferrerPulse();
    } else {
      if (_referrerName != null) {
        setState(() => _referrerName = null);
      }
    }
  }

  Future<void> _checkReferrerPulse() async {
    try {
        String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : 'fectok.com';
        String protocol = kIsWeb ? Uri.base.scheme : (host.contains('fectok.com') ? 'https' : 'http');
        
        // Remove port if in production/IP
        if (host.contains('fectok.com') || RegExp(r'\d{1,3}\.\d{1,3}').hasMatch(host)) {
          host = host.split(':')[0];
        } else if (host == 'localhost' || host == '127.0.0.1') {
          host = '$host:5000';
          protocol = 'http';
        }
        
        final response = await http.post(Uri.parse("$protocol://$host/check_referral"), 
headers: {"Content-Type": "application/json"}, body: jsonEncode({"referral_id": _referralController.text}));
      final result = jsonDecode(response.body);
      if (!mounted) return;
      if (result['status'] == 'SUCCESS') {
        setState(() => _referrerName = result['name']);
      }
    } catch (_) {}
  }

  void _startLockoutTimer(int seconds) {
    setState(() => _lockoutSeconds = seconds);
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSeconds > 0) {
        setState(() => _lockoutSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      try {
        String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : 'fectok.com';
        String protocol = kIsWeb ? Uri.base.scheme : (host.contains('fectok.com') ? 'https' : 'http');
        
        // Ensure protocol consistency for IP access
        if (host == 'localhost' || host == '127.0.0.1') {
           host = '$host:5000';
           protocol = 'http';
        }
        
        final response = await http.post(Uri.parse("$protocol://$host/verify_token"), 
headers: {"Content-Type": "application/json"}, body: jsonEncode({"token": token}));
        final result = jsonDecode(response.body);
        if (!mounted) return;
        if (result['status'] == 'SUCCESS') {
          widget.onAuthComplete(result['sov_id'], result['name'], result['profession'] ?? "User");
          return;
        }
      } catch (_) {}
    }
    _loadSavedCredentials();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _emailPhoneController.text = prefs.getString('remembered_email') ?? '';
      _passwordController.text = prefs.getString('remembered_password') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;
      
      // Sovereign V15: Referral Persistence Sync [A_107]
      final String? savedRef = prefs.getString('referral_id') ?? prefs.getString('referral_pulse');
      if (savedRef != null && savedRef.isNotEmpty) {
        _referralController.text = savedRef;
        isLogin = false; // Auto-Switch to Registration mode
      }
    });
  }

  Future<void> _saveSession(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _emailPhoneController.text);
      await prefs.setString('remembered_password', _passwordController.text);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remembered_email');
      await prefs.remove('remembered_password');
      await prefs.setBool('remember_me', false);
    }
  }

  bool _validateEmailPhone(String value) {
    if (value.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return emailRegex.hasMatch(value) || phoneRegex.hasMatch(value);
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  Future<void> _handleAuth() async {
    final String normalizedEmail = _emailPhoneController.text.trim().toLowerCase();
    if (_lockoutSeconds > 0) {
      _showError("Account Locked. Try again in $_lockoutSeconds seconds.");
      return;
    }
    if (!_validateEmailPhone(normalizedEmail)) {
      _showError("Enter a valid email or phone number");
      return;
    }
    if (_passwordController.text.length < 4) {
      _showError("Password must be at least 4 characters");
      return;
    }

    if (!isLogin && !isForgotPassword) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError("Passwords do not match");
        return;
      }
      if (_calculatePasswordStrength(_passwordController.text) < 0.75) {
        _showError("Password too weak. Use uppercase, numbers, and symbols.");
        return;
      }
      if (_pinController.text.length < 4 || !RegExp(r'^[0-9]+$').hasMatch(_pinController.text)) {
        _showError("Secure PIN must be at least 4-6 digits");
        return;
      }
      if (_nameController.text.isEmpty || _professionController.text.isEmpty || _selectedDOB == null || !_termsAccepted) {
        _showError("Complete all fields and accept terms");
        return;
      }
      
      // V15 Play Store COPPA Compliance: Age Gating (Must be >= 13 years old)
      final age = DateTime.now().difference(_selectedDOB!).inDays / 365;
      if (age < 13) {
        _showError("You must be at least 13 years old to use this platform.");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      String endpoint = isLogin ? '/login' : '/register';
      Map<String, dynamic> body = {};

      if (isForgotPassword) {
        if (_temporarySovId == null) {
          endpoint = '/forgot_password';
          body = {"email_phone": normalizedEmail};
        } else {
          endpoint = '/reset_password';
          body = {"sov_id": _temporarySovId, "token": _resetCodeController.text, "new_password": _passwordController.text};
        }
      } else if (isVerifyingOTP) {
        endpoint = '/verify_registration';
        body = {"email_phone": _activeEmailPulse, "otp": _resetCodeController.text};
      } else {
        body = isLogin 
          ? {"email_phone": normalizedEmail, "password": _passwordController.text}
          : {"name": _nameController.text, "profession": _professionController.text, "email_phone": normalizedEmail, "dob": _selectedDOB!.toIso8601String(), "password": _passwordController.text, "pin": _pinController.text, "referral_id": _referralController.text, "legal_consent": _termsAccepted};
      }

      String host = kIsWeb ? (Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost') : 'fectok.com';
      String protocol = kIsWeb ? Uri.base.scheme : (host.contains('fectok.com') ? 'https' : 'http');
      
      if (host == 'localhost' || host == '127.0.0.1') {
         host = '$host:5000';
         protocol = 'http';
      }

      final response = await http.post(Uri.parse("$protocol://$host$endpoint"), 
headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
      final result = jsonDecode(response.body);

      if (!mounted) return;

      if (result['status'] == 'SUCCESS') {
        if (result['message'] == 'IDENTITY_PULSE_SENT') {
          setState(() { isVerifyingOTP = true; _activeEmailPulse = normalizedEmail; _isLoading = false; });
          _showSuccess("Identity Pulse Sent! Check your email.");
          return;
        }
        if (isForgotPassword) {
          if (_temporarySovId == null) {
            setState(() { _temporarySovId = result['sov_id']; _isLoading = false; });
            _showSuccess("Reset code generated! Check your email.");
            return;
          } else {
            _showSuccess("Password reset successful. All sessions logged out.");
            setState(() { isForgotPassword = false; isLogin = true; _temporarySovId = null; _resetCodeController.clear(); });
          }
        } else if (isVerifyingOTP) {
          if (result['token'] != null) await _saveSession(result['token']);
          _showSuccess("Identity Verified! Welcome to the Mesh.");
          widget.onAuthComplete(result['sov_id'], result['name'], result['profession'] ?? _professionController.text);
          return;
        } else {
          if (result['token'] != null) await _saveSession(result['token']);
          if (isLogin) await _saveCredentials();
          if (!mounted) return;
          widget.onAuthComplete(result['sov_id'], result['name'], result['profession'] ?? _professionController.text);
        }
      } else {
        if (result['reason'] == 'ACCOUNT_LOCKED_TEMPORARILY') {
          _startLockoutTimer(result['seconds'] ?? 900);
        }
        _showError(result['reason'] ?? "Operation failed");
      }
    } catch (e) {
      _showError("Vault Connection Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
  }
  
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.cyan, behavior: SnackBarBehavior.floating));
  }

  Future<void> _selectDOB() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null) {
      setState(() => _selectedDOB = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // V15 NEON RAINBOW AURA
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildAuraOrb(top: -150 + (200 * _floatAnimation1.value.dy), left: -100 + (200 * _floatAnimation1.value.dx), color: Colors.blueAccent, size: 600),
                  _buildAuraOrb(bottom: -150 + (200 * _floatAnimation2.value.dy), right: -100 + (200 * _floatAnimation2.value.dx), color: Colors.purpleAccent, size: 600),
                  _buildAuraOrb(top: 100 + (200 * _floatAnimation3.value.dy), right: -100 + (200 * _floatAnimation3.value.dx), color: Colors.greenAccent, size: 500),
                  _buildAuraOrb(bottom: 100 + (200 * _floatAnimation4.value.dy), left: -100 + (200 * _floatAnimation4.value.dx), color: Colors.redAccent, size: 500),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Center(
              child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    _buildLogoHeader(),
                    const SizedBox(height: 30),
                    if (_lockoutSeconds > 0) _buildLockoutStatus(),
                    _buildGlassCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAuthHeader(),
                          const SizedBox(height: 30),
                          _buildFormFields(),
                          const SizedBox(height: 25),
                          _buildActionButtons(),
                          const SizedBox(height: 20),
                          _buildToggleLink(),
                        ],
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

  Widget _buildLockoutStatus() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.security, color: Colors.redAccent, size: 20),
        const SizedBox(width: 10),
        Text("VAULT LOCKED: ${(_lockoutSeconds ~/ 60).toString().padLeft(2, '0')}:${(_lockoutSeconds % 60).toString().padLeft(2, '0')}s", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildAuraOrb({required double size, required Color color, double? top, double? left, double? right, double? bottom}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05), Colors.transparent]))),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF0055), Color(0xFFFF5E9B), Color(0xFFFF0055)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "fect",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                    shadows: [
                      Shadow(color: const Color(0xFFFF0055).withValues(alpha: 0.8), blurRadius: 25, offset: const Offset(2, 4)),
                      Shadow(color: const Color(0xFFFF0055).withValues(alpha: 0.5), blurRadius: 50),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: const Color(0xFFFF0055).withValues(alpha: 0.8), blurRadius: 30),
                    ],
                  ),
                ),
                Text(
                  "k",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                    shadows: [
                      Shadow(color: const Color(0xFFFF0055).withValues(alpha: 0.8), blurRadius: 25, offset: const Offset(2, 4)),
                      Shadow(color: const Color(0xFFFF0055).withValues(alpha: 0.5), blurRadius: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, childWidget) {
            final rainbowColor = HSVColor.fromAHSV(1.0, (_animationController.value * 360), 0.8, 1.0).toColor();
            return Container(
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(width: 2.0, color: rainbowColor.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: rainbowColor.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: -5)]
              ),
              child: childWidget,
            );
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildAuthHeader() {
    String title = isLogin ? "SOVEREIGN LOGIN" : (isVerifyingOTP ? "VERIFY IDENTITY" : "GENERATE DNA");
    String sub = isLogin ? "SECURE ACCESS TO V15 MESH" : (isVerifyingOTP ? "ENTER PULSE CODE SENT TO MESH" : "INITIALIZE REAL-TIME IDENTITY");
    if (isForgotPassword) { title = "RECOVER PULSE"; sub = _temporarySovId == null ? "VERIFY ACCOUNT OWNERSHIP" : "INJECT NEW CREDENTIALS"; }
    return Column(children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ),
      const SizedBox(height: 5),
      const Text("V15-NET-SYNC [PRO] v1.5.3", style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 10),
      Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    ]);
  }

  Widget _buildFormFields() {
    if (isVerifyingOTP) {
       return Column(children: [
        _buildField(controller: _resetCodeController, label: "IDENTITY PULSE CODE", icon: Icons.security, isKeyboardType: TextInputType.number, color: Colors.cyanAccent),
        const SizedBox(height: 10),
        Text("SENT TO: $_activeEmailPulse", style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1)),
      ]);
    }
    if (isForgotPassword && _temporarySovId != null) {
      return Column(children: [
        _buildField(controller: _resetCodeController, label: "RESET CODE", icon: Icons.vpn_key, color: Colors.amberAccent),
        const SizedBox(height: 15),
        _buildField(controller: _passwordController, label: "NEW MASTER PASSWORD", icon: Icons.lock_reset, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), color: Colors.redAccent),
      ]);
    }
    return Column(children: [
      if (!isLogin && !isForgotPassword) ...[
        _buildField(controller: _nameController, label: "FULL NAME", icon: Icons.person_add_alt_1, color: Colors.purpleAccent),
        const SizedBox(height: 15),
        _buildField(controller: _professionController, label: "PROFESSION (COMPULSORY)", icon: Icons.work_outline, color: Colors.orangeAccent),
        const SizedBox(height: 15),
        _buildDOBButton(),
        const SizedBox(height: 15),
      ],
      _buildField(controller: _emailPhoneController, label: "EMAIL OR PHONE", icon: Icons.alternate_email, color: Colors.blueAccent),
      if (!isForgotPassword) ...[
        const SizedBox(height: 15),
        _buildField(controller: _passwordController, label: "PASSWORD", icon: Icons.lock_outline, isPassword: true, obscure: _obscurePassword, onToggle: () => setState(() => _obscurePassword = !_obscurePassword), color: Colors.redAccent),
        if (!isLogin) ...[
          _buildStrengthIndicator(),
          _buildField(controller: _confirmPasswordController, label: "CONFIRM PASSWORD", icon: Icons.verified, isPassword: true, obscure: _obscureConfirmPassword, onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword), color: Colors.orangeAccent),
          const SizedBox(height: 15),
          _buildField(controller: _pinController, label: "SECURE PIN (4-6 DIGITS)", icon: Icons.security, isKeyboardType: TextInputType.number, color: Colors.pinkAccent),
          const SizedBox(height: 15),
          _buildField(controller: _referralController, label: "REFERRAL ID", icon: Icons.hub_outlined, color: Colors.cyanAccent),
          if (_referrerName != null) _buildReferrerBadge(),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
        ] else ...[
          const SizedBox(height: 12),
          _buildLoginOptions(),
        ],
      ],
    ]);
  }

  Widget _buildStrengthIndicator() {
    final strength = _calculatePasswordStrength(_passwordController.text);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Text("PULSE: ", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: strength, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(strength < 0.5 ? Colors.red : strength < 0.8 ? Colors.orange : Colors.greenAccent), minHeight: 4))),
      ]),
    );
  }

  Widget _buildReferrerBadge() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10),
      child: Row(children: [
        const Icon(Icons.bolt, color: Colors.cyanAccent, size: 16),
        const SizedBox(width: 8),
        Text("INVITED BY: $_referrerName", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _buildField({required TextEditingController controller, required String label, required IconData icon, required Color color, bool isPassword = false, bool obscure = false, VoidCallback? onToggle, TextInputType? isKeyboardType}) {
    return TextField(
      controller: controller, obscureText: isPassword && obscure, keyboardType: isKeyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      onChanged: (v) { if (!isLogin && isPassword) setState(() {}); },
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        prefixIcon: Icon(icon, color: color, size: 22),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white24, size: 18), onPressed: onToggle) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: color, width: 2)),
        filled: true, fillColor: Colors.white.withValues(alpha: 0.03), contentPadding: const EdgeInsets.symmetric(vertical: 22),
      ),
    );
  }

  Widget _buildDOBButton() {
    return InkWell(
      onTap: _selectDOB, borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Row(children: [
          const Icon(Icons.cake_outlined, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 15),
          Text(_selectedDOB == null ? "BIRTH DATE" : "${_selectedDOB!.day} / ${_selectedDOB!.month} / ${_selectedDOB!.year}", style: TextStyle(color: _selectedDOB == null ? Colors.white24 : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildLoginOptions() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [
        Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v!), activeColor: Colors.blueAccent, side: const BorderSide(color: Colors.white24)),
        const Text("REMEMBER", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
      TextButton(onPressed: () => setState(() => isForgotPassword = true), child: const Text("RESET VAULT?", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildTermsCheckbox() {
    return Row(children: [
      Checkbox(value: _termsAccepted, onChanged: (v) => setState(() => _termsAccepted = v!), activeColor: Colors.cyanAccent),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
            children: [
              const TextSpan(text: "I SUBMIT TO THE "),
              TextSpan(
                text: "SOVEREIGN STATUTE",
                style: const TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()..onTap = widget.onGuidelinesTap,
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity, height: 65,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: (isLogin ? Colors.blueAccent : Colors.purpleAccent).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: -5)]),
      child: ElevatedButton(
        onPressed: _isLoading || _lockoutSeconds > 0 ? null : _handleAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLogin ? Colors.blueAccent : Colors.purpleAccent, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3) : Text(isLogin ? "SYNC WITH MESH" : "GENERATE IDENTITY", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildToggleLink() {
    return TextButton(
      onPressed: () => setState(() { isForgotPassword ? (isForgotPassword = false, _temporarySovId = null) : isLogin = !isLogin; }),
      child: Text(isForgotPassword ? "RETURN TO SYNC PORTAL" : (isLogin ? "NEW NODE? CREATE DNA" : "EXISTING NODE? SYNC PROFILE"), style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
    );
  }
}

