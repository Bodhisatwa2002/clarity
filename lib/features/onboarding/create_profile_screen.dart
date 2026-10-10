import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../shared/widgets/controls.dart';
import '../shared/widgets/buttons.dart';
import '../shared/widgets/dashed_border.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import '../shared/widgets/pressable.dart';
import 'widgets/onboarding_widgets.dart';

/// 05 · Create profile — step 3 of sign-up.
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  /// Usernames the dummy backend reports as taken.
  static const takenUsernames = {'rahul', 'asha', 'priya', 'admin', 'clarity'};

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();

  String get _user => _username.text;
  bool get _validLength => _user.length >= 3;
  bool get _taken => _validLength && CreateProfileScreen.takenUsernames.contains(_user);
  bool get _available => _validLength && !_taken;
  bool get _ready => _available && _name.text.trim().length >= 2;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  void _continue() {
    context.appRead.completeProfile(name: _name.text, username: _user);
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, Routes.permissions);
  }

  @override
  Widget build(BuildContext context) {
    final initials = Fmt.initials(_name.text);
    final fieldStyle = AppText.sans(17, weight: FontWeight.w600, color: AppColors.navyInk);

    return SkyScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StepHeader(step: 3),
          const SizedBox(height: 22),
          const StepIntro(
            title: AccentTitle(lead: 'Make it ', accent: 'yours', textAlign: TextAlign.center),
            subtitle: 'Friends will see this on your map.',
          ),
          const SizedBox(height: 26),
          Center(child: _PhotoPicker(initials: initials)),
          const SizedBox(height: 10),
          Text(
            'Add a photo',
            textAlign: TextAlign.center,
            style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.white),
          ),
          const SizedBox(height: 22),
          _Label('Your name'),
          const SizedBox(height: 6),
          WhitePillField(
            child: BareTextField(
              controller: _name,
              hint: 'e.g. Bodhi Chakraborty',
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              maxLength: 40,
              onChanged: (_) => setState(() {}),
              style: fieldStyle,
            ),
          ),
          const SizedBox(height: 14),
          _Label('Username'),
          const SizedBox(height: 6),
          WhitePillField(
            padding: const EdgeInsets.only(left: 22, right: 8),
            child: Row(
              spacing: 2,
              children: [
                Text(
                  '@',
                  style: AppText.sans(17, weight: FontWeight.w600, color: AppColors.muted),
                ),
                Expanded(
                  child: BareTextField(
                    controller: _username,
                    hint: 'bodhi',
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    maxLength: 20,
                    onChanged: (v) {
                      final clean = v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9.]'), '');
                      if (clean != v) {
                        _username.value = TextEditingValue(
                          text: clean,
                          selection: TextSelection.collapsed(offset: clean.length),
                        );
                      }
                      setState(() {});
                    },
                    style: fieldStyle,
                  ),
                ),
                if (_available) const _AvailabilityTag(available: true),
                if (_taken) const _AvailabilityTag(available: false),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(child: _LinkPreview(username: _user)),
          const Spacer(),
          PrimaryButton(label: 'Continue', onPressed: _ready ? _continue : null),
          const SizedBox(height: 14),
          const Footnote('Lowercase letters, numbers and dots. You can change it later.'),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 18),
    child: Text(
      text,
      style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.white),
    ),
  );
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      semanticLabel: 'Add profile photo',
      onTap: () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Photo picker comes with the camera integration.'))),
      child: SizedBox(
        width: 116,
        height: 116,
        child: Stack(
          children: [
            GlassOrb(
              size: 116,
              dashedBorder: true,
              shadow: true,
              child: initials.isEmpty
                  ? const AppIconView(AppIcon.user, size: 34, color: AppColors.white, strokeWidth: 1.6)
                  : Text(
                      initials,
                      style: AppText.sans(38, weight: FontWeight.w700, letterSpacing: -1, color: AppColors.white),
                    ),
            ),
            Positioned(
              right: 2,
              bottom: 4,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: const AppIconView(AppIcon.camera, size: 16, color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityTag extends StatelessWidget {
  const _AvailabilityTag({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final fg = available ? AppColors.success : AppColors.takenFg;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: available ? AppColors.successBg : AppColors.takenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (available) AppIconView(AppIcon.check, size: 14, color: fg, strokeWidth: 2.6),
          Text(
            available ? 'Available' : 'Taken',
            style: AppText.sans(13, weight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

class _LinkPreview extends StatelessWidget {
  const _LinkPreview({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return DashedBorder(
      color: AppColors.navy.withValues(alpha: 0.55),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: AppColors.whiteA(0.6), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const AppIconView(AppIcon.link, size: 15, color: AppColors.navy),
            Text.rich(
              TextSpan(
                style: AppText.sans(13, weight: FontWeight.w600, color: AppColors.navy),
                children: [
                  const TextSpan(text: 'Your map link: '),
                  TextSpan(
                    text: 'clarity.in/${username.isEmpty ? 'you' : username}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
