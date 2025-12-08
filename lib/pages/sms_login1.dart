import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../registerProvider/login_provider.dart';
import '../registerProvider/verify_provider.dart';
import 'app_strings.dart';
import 'home_page_nav.dart';

class SmsLoginPage extends StatefulWidget {
  final String email;

  const SmsLoginPage({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> with CodeAutoFill {
  final int codeLength = 6;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  // Urinishlar va taymer uchun
  int _attempts = 0;
  static const int _maxAttempts = 3;
  Timer? _timer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    listenForCode();
    for (int i = 0; i < codeLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    _startTimer(); // Sahifa ochilganda taymerni ishga tushirish
  }

  @override
  void dispose() {
    cancel();
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void codeUpdated() {
    final code = this.code;
    if (code != null && code.length == codeLength) {
      for (int i = 0; i < codeLength; i++) {
        _controllers[i].text = code[i];
      }
      _onChanged(codeLength - 1, _controllers.last.text);
      _checkCode();
    }
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < codeLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    // Xatolikni tozalash
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    if (verifyProvider.errorMessage != null) {
      verifyProvider.clearError();
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _checkCode();
    }
  }

  void _checkCode() async {
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    if (verifyProvider.isLoading || _attempts >= _maxAttempts) return;

    final currentSessionId = loginProvider.sessionId;
    if (currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sessiya topilmadi! Qaytadan kiring.")));
      return;
    }

    String enteredCode = _controllers.map((c) => c.text).join();

    // --- DEBUG UCHUN ---
    // Konsolda serverga qanday ma'lumotlar yuborilayotganini tekshiring
    print("--- Verifying Login Code ---");
    print("Session ID: $currentSessionId");
    print("Email: ${widget.email}"); // emailni ham logga chiqaramiz
    print("Entered Code: $enteredCode");
    // --- DEBUG TUGADI ---

    await verifyProvider.verifyCode(
      sessionId: currentSessionId,
      email: widget.email, // Login tasdiqlashda email yuborilishi kerak
      code: enteredCode,
    );

    if (!mounted) return;

    if (verifyProvider.isSuccess) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePageNav()),
        (route) => false,
      );
    } else {
      setState(() {
        _attempts++;
        // Xato bo'lganda maydonlarni tozalash
        for (var controller in _controllers) { controller.clear(); }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  void _resendCode() async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    if (loginProvider.isLoading || _countdown > 0) return;

    await loginProvider.login(widget.email);

    // Yangi session ID ni VerifyProvider ga o'tkazish uchun
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    verifyProvider.clearState(); // Eski holatni tozalaymiz

    if (!mounted) return;

    if (loginProvider.isSuccess && loginProvider.sessionId != null) {
      setState(() {
        _attempts = 0;
        for (var controller in _controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
        _startTimer(); // Taymerni qayta ishga tushirish
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.codeResent)),
      );
    }
  }

  void _startTimer() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) { setState(() => _countdown--); }
      else { timer.cancel(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VerifyProvider, LoginProvider>(
      builder: (context, verifyProvider, loginProvider, child) {
        String errorText = '';
        if (verifyProvider.errorMessage != null) {
          if (_attempts >= _maxAttempts) {
            errorText = AppStrings.attemptsFinished;
          } else {
            // Serverdan kelgan aniq xatoni ko'rsatamiz, agar u bo'lmasa, umumiy xabarni chiqaramiz.
            errorText = verifyProvider.errorMessage ?? AppStrings.attemptsLeft(_maxAttempts - _attempts);
          }
        }

        final isSuccess = verifyProvider.isSuccess;
        final isLoading = verifyProvider.isLoading || loginProvider.isLoading;

        final borderColor = errorText.isNotEmpty
            ? Colors.red
            : isSuccess
                ? Colors.green
                : Colors.grey.shade300;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: const BackButton(),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 29),
            child: SingleChildScrollView(
              child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              "Kodni kiriting",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.codeSentToEmail,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // Markazlashtirilgan PinCodeField vidjeti
            PinCodeField(
              controllers: _controllers,
              focusNodes: _focusNodes,
              onChanged: _onChanged,
              codeLength: codeLength,
              isEnabled: !isLoading && _attempts < _maxAttempts,
              borderColor: borderColor,
              errorText: errorText,
              isSuccess: isSuccess,
            ),
            const SizedBox(height: 16),
            if (errorText.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : TextButton.icon(
                    onPressed: _countdown > 0 || _attempts >= _maxAttempts ? null : _resendCode,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      _countdown > 0
                          ? AppStrings.resendCodeIn(_countdown)
                          : AppStrings.resendCode,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      disabledForegroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
          ],
        ),
            ),
          ),
        );
      },
    );
  }
}

// Qayta ishlatish uchun alohida vidjet
class PinCodeField extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(int, String) onChanged;
  final int codeLength;
  final bool isEnabled;
  final Color borderColor;
  final String errorText;
  final bool isSuccess;

  const PinCodeField({
    Key? key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.codeLength,
    required this.isEnabled,
    required this.borderColor,
    required this.errorText,
    required this.isSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: List.generate(codeLength, (i) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: controllers[i],
            focusNode: focusNodes[i],
            enabled: isEnabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: 24,
              color: errorText.isNotEmpty ? Colors.red : (isSuccess ? Colors.green : Colors.black),
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: errorText.isNotEmpty ? Colors.red : Colors.green,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => onChanged(i, v),
          ),
        );
      }),
    );
  }
}
  