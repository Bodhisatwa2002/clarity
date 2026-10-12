import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/glass.dart';
import '../shared/widgets/layout.dart';
import 'legal_content.dart';

/// Privacy policy / Terms of use, opened from sign-up and from Settings.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      sheetTop: 132,
      header: Row(
        spacing: 14,
        children: [
          GlassIconButton(
            icon: AppIcon.back,
            iconSize: 20,
            semanticLabel: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          Text(doc.title, style: AppText.screenTitle()),
        ],
      ),
      sheet: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 48),
        children: [
          Text('Last updated ${LegalInfo.lastUpdated}', style: AppText.meta()),
          const SizedBox(height: 12),
          Text(doc.intro, style: AppText.sans(15, height: 1.55, color: AppColors.text)),
          for (final section in doc.sections) _Section(section),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.section);

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final body = AppText.sans(14, height: 1.55, color: AppColors.textSoft);
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            section.heading,
            style: AppText.sans(16, weight: FontWeight.w700, color: AppColors.ink),
          ),
          for (final block in section.blocks)
            switch (block) {
              LegalParagraph() => Text(block.text, style: body),
              LegalBullet() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text('•', style: body),
                  Expanded(child: Text(block.text, style: body)),
                ],
              ),
            },
        ],
      ),
    );
  }
}
