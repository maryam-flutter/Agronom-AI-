
import 'dart:async';
import 'package:agronom_ai/registemodel/model.dart';
import 'package:agronom_ai/pages/home_page_nav.dart';
import 'package:agronom_ai/pages/sms_login1.dart';
import 'package:agronom_ai/registerProvider/registerProvider.dart';
import 'package:agronom_ai/registerProvider/verify_provider.dart';
import 'package:agronom_ai/pages/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';


class SmsPage extends StatefulWidget {
  final String phone;
  final String email;
  final String address;

   SmsPage({
    Key? key,
    required this.phone,
    required this.email,
    required this.address,
  }) : super(key: key);

  @override
  State<SmsPage> createState() => _SmsPageState();
}

class _SmsPageState extends State<SmsPage> with CodeAutoFill {
  final int codeLength = 6; // Backend 8 xonali kod yuboradi
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
    if (code != null && code!.length == codeLength) {
      for (int i = 0; i < codeLength; i++) {
        _controllers[i].text = code![i];
      }
      _onChanged(codeLength - 1, _controllers.last.text); // Bu o'z navbatida _checkCode() ni chaqiradi
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
    // Foydalanuvchi yozishni boshlaganda eski xatolikni tozalash
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    if (verifyProvider.errorMessage != null) {
      verifyProvider.clearError(); // Provider'dagi xatoni tozalash uchun maxsus metod
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _checkCode();
    }
  }

  void _checkCode() async {
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);

    if (verifyProvider.isLoading || _attempts >= _maxAttempts) return;

    final sessionId = registerProvider.sessionId;
    if (sessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sessiya topilmadi! Qaytadan urinib ko'ring.")));
      return;
    }

    String enteredCode = _controllers.map((c) => c.text).join();

    await verifyProvider.verifyCode(
      sessionId: sessionId,
      code: enteredCode,
    );

    if (!mounted) return;

    if (verifyProvider.isSuccess) {
      Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => const HomePageNav()), (route) => false,
      );
    } else {
      setState(() {
        _attempts++;
        for (var controller in _controllers) { controller.clear(); }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      });
    }
  }

  void _resendCode() async {
    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    if (registerProvider.isLoading || _countdown > 0) return;

    final model = RegisterModel(phone: widget.phone, email: widget.email, address: widget.address);
    await registerProvider.register(model);

    if (!mounted) return;

    if (registerProvider.isSuccess && registerProvider.sessionId != null) {
      setState(() {
        _attempts = 0;
        for (var controller in _controllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
        _startTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.codeResent),
          backgroundColor: Colors.green, // Muvaffaqiyat uchun yashil rang
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
    return Consumer2<VerifyProvider, RegisterProvider>(
      builder: (context, verifyProvider, registerProvider, child) {
        String errorText = '';
        if (verifyProvider.errorMessage != null) {
          if (_attempts >= _maxAttempts) {
            errorText = AppStrings.attemptsFinished;
          } else {
            // Serverdan kelgan aniq xatoni ko'rsatamiz, agar u bo'lmasa, umumiy xabarni chiqaramiz.
            errorText = verifyProvider.errorMessage ?? AppStrings.attemptsLeft(_maxAttempts - _attempts);
          }
        } else if (registerProvider.errorMessage != null) {
          errorText = registerProvider.errorMessage!;
        }

        final isSuccess = verifyProvider.isSuccess;
        final isLoading = verifyProvider.isLoading || registerProvider.isLoading;

        final borderColor = errorText.isNotEmpty
            ? Theme.of(context).colorScheme.error
            : isSuccess
                ? Colors.green
                : Colors.grey.shade300;

        return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              "Kodni kiriting",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.codeSentToEmail,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Color.fromARGB(205, 0, 0, 0)),
            ),
            const SizedBox(height: 32),
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
                    child: Text( // O'zgartirildi
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