import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/onboarding_widgets.dart';

class _Country {
  const _Country(this.iso, this.name, this.code, this.length);
  final String iso;
  final String name;
  final String code;

  /// Digits in a national number.
  final int length;
}

const _countries = [
  _Country('IN', 'India', '+91', 10),
  _Country('AE', 'UAE', '+971', 9),
  _Country('GB', 'United Kingdom', '+44', 10),
  _Country('US', 'United States', '+1', 10),
];

/// 03 · Phone number — step 1 of sign-up.
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  _Country _country = _countries.first;
  bool _picking = false;
  late final _termsTap = TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, Routes.terms);
  late final _privacyTap = TapGestureRecognizer()..onTap = () => Navigator.pushNamed(context, Routes.privacy);

  String get _digits => _controller.text.replaceAll(RegExp(r'\D'), '');
  bool get _valid => _digits.length == _country.length;

  @override
  void dispose() {
    _controller.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    final digits = _digits.substring(0, _digits.length.clamp(0, _country.length));
    final formatted = digits.length > 5 ? '${digits.substring(0, 5)} ${digits.substring(5)}' : digits;
    if (formatted != _controller.text) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    // Full number typed: drop the keyboard so "Send code" is in reach.
    if (digits.length == _country.length) FocusScope.of(context).unfocus();
    setState(() {});
  }

  void _pick(_Country c) {
    setState(() {
      _country = c;
      _picking = false;
    });
    _onChanged(_controller.text);
  }

  bool _sending = false;

  Future<void> _sendCode() async {
    final state = context.appRead;
    state.setPhone(countryCode: _country.code, digits: _digits);
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    final error = await state.sendCode();
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pushNamed(context, Routes.otp);
  }

  /// Switches between "Get started" and "I already have an account" without
  /// going back to the welcome screen.
  void _switchMode(bool signUp) {
    final state = context.appRead;
    signUp ? state.startNewAccount() : state.signInExisting();
  }

  @override
  Widget build(BuildContext context) {
    final signUp = context.app.isNewAccount;
    return SkyScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepHeader(step: 1, signUp: signUp),
          const SizedBox(height: 36),
          StepIntro(
            title: StepTitle(signUp ? 'Create your account' : 'Welcome back'),
            subtitle: signUp
                ? "Start with your phone number. We'll text you a 6-digit code, and it helps friends find you."
                : "Log in with the number you signed up with. We'll text you a 6-digit code.",
          ),
          const SizedBox(height: 40),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                spacing: 10,
                children: [
                  _CountryButton(country: _country, onTap: () => setState(() => _picking = !_picking)),
                  Expanded(
                    child: WhitePillField(
                      height: 60,
                      child: BareTextField(
                        controller: _controller,
                        hint: '98765 43210',
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumberNational],
                        onChanged: _onChanged,
                        style: AppText.sans(20, weight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.navyInk),
                      ),
                    ),
                  ),
                ],
              ),
              if (_picking)
                Positioned(
                  left: 0,
                  top: 70,
                  child: _CountryMenu(selected: _country, onPick: _pick),
                ),
            ],
          ),
          const SizedBox(height: 18),
          const InfoNote(
            icon: AppIcon.lock,
            text:
                'Only used to verify you and match friends who already have your number. Never shown on your profile.',
          ),
          const Spacer(),
          PrimaryButton(label: _sending ? 'Sending…' : 'Send code', onPressed: _valid && !_sending ? _sendCode : null),
          TextLinkButton(
            label: signUp ? 'Already have an account? Log in' : 'New here? Create an account',
            fontSize: 14,
            height: 44,
            onPressed: () => _switchMode(!signUp),
          ),
          Text.rich(
            TextSpan(
              style: AppText.sans(12, weight: FontWeight.w400, height: 1.5, color: AppColors.navy),
              children: [
                const TextSpan(text: 'By continuing you agree to our '),
                TextSpan(
                  text: 'Terms',
                  recognizer: _termsTap,
                  style: AppText.sans(
                    12,
                    weight: FontWeight.w700,
                    color: AppColors.navy,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  recognizer: _privacyTap,
                  style: AppText.sans(
                    12,
                    weight: FontWeight.w700,
                    color: AppColors.navy,
                  ).copyWith(decoration: TextDecoration.underline),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CountryButton extends StatelessWidget {
  const _CountryButton({required this.country, required this.onTap});

  final _Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: 'Country code ${country.code}, change',
      child: DashedBorder(
        color: AppColors.whiteA(0.85),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppColors.whiteA(0.18), borderRadius: BorderRadius.circular(30)),
          child: Row(
            spacing: 8,
            children: [
              Text(
                country.iso,
                style: AppText.sans(12, weight: FontWeight.w700, letterSpacing: 0.6, color: AppColors.onBlueMuted),
              ),
              Text(
                country.code,
                style: AppText.sans(18, weight: FontWeight.w700, color: AppColors.white),
              ),
              const AppIconView(AppIcon.chevronDown, size: 14, color: AppColors.white, strokeWidth: 2.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryMenu extends StatelessWidget {
  const _CountryMenu({required this.selected, required this.onPick});

  final _Country selected;
  final ValueChanged<_Country> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: AppColors.shadow.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 18)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in _countries)
            Pressable(
              onTap: () => onPick(c),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: c == selected ? AppColors.selectedRow : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        c.iso,
                        style: AppText.sans(12, weight: FontWeight.w700, color: const Color(0xFF4A5568)),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c.name,
                        style: AppText.sans(15, weight: FontWeight.w600, color: AppColors.navyInk),
                      ),
                    ),
                    Text(
                      c.code,
                      style: AppText.sans(15, weight: FontWeight.w600, color: AppColors.blue),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
