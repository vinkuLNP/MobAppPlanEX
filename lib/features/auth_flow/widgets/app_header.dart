import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_widgets.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final AuthUserProvider authUserProvider;
  const AppHeader({
    super.key,
    required this.title,
    required this.authUserProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        context.gap40,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              margin: EdgeInsets.only(right: 4, top: 8),
              decoration: BoxDecoration(
                color: AppColors.authThemeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: textWidget(
                text: 'LNP',
                context: context,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
            Image.asset(appLogoBlack, height: 70, color: AppColors.black),
          ],
        ),
        context.gap20,
        textWidget(context: context, text: title),
        context.gap20,
        if (authUserProvider.error != null)
          authErrorTextWidget(context: context, provider: authUserProvider),
      ],
    );
  }
}
