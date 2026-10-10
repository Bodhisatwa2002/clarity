import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'widgets/onboarding_widgets.dart';

/// 04 · OTP verification — step 2 of sign-up. Any 6 digits work for now.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  static const int codeLength = 6;
  static const int resendSeconds = 30;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondsLeft = OtpScreen.resendSeconds;

  String get _code => _controller.text;
  bool get _complete => _code.length == OtpScreen.codeLength;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = OtpScreen.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) t.cancel();
      setState(() => _secondsLeft--);
    });
  }

  void _resend() {
    _controller.clear();
    _startTimer();
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    if (context.appRead.isNewAccount) {
      Navigator.pushNamed(context, Routes.createProfile);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Routes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.app.phoneDisplay;
    return SkyScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepHeader(step: 2),
          const SizedBox(height: 28),
          Center(
            child: GlassOrb(
              size: 96,
              shadow: true,
              child: const AppIconView(AppIcon.chat, size: 36, color: AppColors.white, strokeWidth: 1.6),
            ),
          ),
          const SizedBox(height: 22),
          const StepTitle('Enter the code'),
          const SizedBox(height: 8),
          Text(
            'We sent a 6-digit code to',
            textAlign: TextAlign.center,
            style: AppText.sans(15, height: 1.45, color: AppColors.onBlueSoft),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Text(
                phone,
                style: AppText.sans(16, weight: FontWeight.w700, color: AppColors.white),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Change',
                  style: AppText.sans(
                    14,
                    weight: FontWeight.w700,
                    color: AppColors.white,
                  ).copyWith(decoration: TextDecoration.underline, decorationColor: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          _CodeBoxes(controller: _controller, focusNode: _focus, onChanged: () => setState(() {})),
          const SizedBox(height: 22),
          SizedBox(
            height: 44,
            child: Center(
              child: _secondsLeft > 0
                  ? Text(
                      'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.white),
                    )
                  : PillButton(
                      label: 'Resend code',
                      height: 44,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      background: AppColors.whiteA(0.55),
                      foreground: AppColors.navy,
                      dashedBorder: AppColors.navy,
                      onPressed: _resend,
                    ),
            ),
          ),
          const Spacer(),
          PrimaryButton(label: 'Verify & continue', onPressed: _complete ? _verify : null),
          const SizedBox(height: 14),
          const Footnote('The code expires in 10 minutes. Never share it with anyone.'),
        ],
      ),
    );
  }
}

/// Six boxes driven by one invisible text field, so paste and SMS autofill
/// work like a single input.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.controller, required this.focusNode, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    return GestureDetector(
      onTap: focusNode.requestFocus,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < OtpScreen.codeLength; i++)
                _box(char: i < code.length ? code[i] : null, active: i == code.length && focusNode.hasFocus),
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: OtpScreen.codeLength,
                showCursor: false,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onChanged(),
                decoration: const InputDecoration(counterText: '', border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({String? char, required bool active}) {
    if (char != null) {
      return Container(
        width: 50,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.shadow.withValues(alpha: 0.15), blurRadius: 22, offset: const Offset(0, 8)),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          char,
          style: AppText.sans(26, weight: FontWeight.w700, color: AppColors.navyInk),
        ),
      );
    }
    if (active) {
      return Container(
        width: 50,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.whiteA(0.32),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.white, width: 2),
        ),
        alignment: Alignment.center,
        child: Container(width: 2, height: 26, color: AppColors.white),
      );
    }
    return DashedBorder(
      color: AppColors.whiteA(0.85),
      radius: 18,
      child: Container(
        width: 50,
        height: 62,
        decoration: BoxDecoration(color: AppColors.whiteA(0.14), borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
