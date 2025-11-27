import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final accountProvider = context.read<AccountProvider>();

          return Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 440,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: context.pagePadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const AppHeader(title: 'Verify your email'),
                          textWidget(
                            context: context,
                            text: 'A verification link was sent to your email.',
                          ),
                          context.gap40,
                          auth.isLoading
                              ? const CircularProgressIndicator()
                              : AppButton(
                                  onTap: () async {
                                    await context
                                        .read<AuthProvider>()
                                        .sendVerification();
                                  },
                                  text: 'Resend verification email',
                                ),
                          context.gap40,
                          AppButton(
                            onTap: () async {
                              final authProvider = context.read<AuthProvider>();
                              final verified = await authProvider
                                  .checkEmailVerified();

                              if (verified) {
                                await accountProvider.loadAccountBasicInfo();
                                await accountProvider.loadSettingsData();
                                if (context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.home,
                                  );
                                }
                              } else {
                                if (authProvider.error != null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: textWidget(
                                          context: context,
                                          text: authProvider.error!,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            text: "I've verified my email",
                            fontSize: 14,
                            textColor: AppColors.backgroundColor,
                          ),
                          context.gap20,
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                            child: textWidget(
                              context: context,
                              text: 'Back to Sign Up',
                              textDecoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                              textDecorationColor: AppColors.authThemeColor,
                              color: AppColors.authThemeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
