import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool centered;
  const AppHeader({super.key, required this.title, this.centered = true});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 9.5),

        Image.asset(
          height: 100,
          appLogoWithOutBg,
          color: isDark ? Colors.white : Colors.black,
        ),
        context.gap20,
        Text(title, style: context.text.headlineMedium),
         context.gap20,
      ],
    );
  }
}
