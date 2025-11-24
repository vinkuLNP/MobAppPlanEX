import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool centered;
  final bool onTap;
  const AppHeader({
    super.key,
    required this.title,
    this.centered = true,
    this.onTap = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        context.gap40,
        Image.asset(
          height: 100,
          appLogoWithOutBg,
          color: isDark ? Colors.white : Colors.black,
        ),
        context.gap20,
        textWidget(text: title),
        context.gap40,
      ],
    );
  }
}
