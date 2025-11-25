import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/pro_badge.dart';

class ProSwitchTile extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final bool isPremium;
  final Function(bool)? onChanged;
  final VoidCallback onUpgradeTap;

  const ProSwitchTile({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.isPremium,
    required this.onChanged,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isPremium ? null : onUpgradeTap,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            textWidget(text: title),
            const SizedBox(width: 8),
            if (!isPremium) const ProBadge(),
          ],
        ),
        subtitle: textWidget(
          text: description,
          fontSize: 13,
          color: Colors.grey,
        ),
        value: value,
        onChanged: isPremium ? onChanged : null,
      ),
    );
  }
}
