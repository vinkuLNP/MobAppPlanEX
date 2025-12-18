import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/routes/auth_flow_navigation.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<AuthUserProvider>();
        provider.clearError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthUserProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: context.pagePadding,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppHeader(title: 'Forgot password', authUserProvider: auth),
                  AppInputField(
                    label: "Email",
                    controller: auth.signInEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    hint: "example@gmail.com",
                    validator: auth.validateEmail,
                    onChanged: (_) {
                      if (auth.autoValidate) {
                        formKey.currentState?.validate();
                      }
                    },
                  ),
                  context.gap20,

                  if (auth.resetLinkSent)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          textWidget(
                            text: "Reset link sent successfully!",
                            color: AppColors.authThemeColor,
                            fontWeight: FontWeight.w600,
                            context: context,
                          ),
                          const SizedBox(height: 4),
                          textWidget(
                            text:
                                "Please check your email and return to login.",
                            color: Colors.grey,
                            context: context,
                          ),
                        ],
                      ),
                    ),

                  context.gap20,
                  auth.isLoading
                      ? const CircularProgressIndicator()
                      : AppButton(
                          onTap: (auth.cooldown > 0)
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;

                                  final success = await context
                                      .read<AuthUserProvider>()
                                      .resetPassword(
                                        auth.signInEmailCtrl.text.trim(),
                                      );
                                  if (success && context.mounted) {
                                    auth.startCooldown();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Password reset link has been sent to your email",
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else {
                                    auth.startCooldown();

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(auth.error.toString()),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                          text: auth.cooldown > 0
                              ? "Resend in ${auth.cooldown}s"
                              : 'Send Reset Link',
                          fontSize: 14,
                          textColor: AppColors.backgroundColor,
                        ),
                  context.gap10,
                  TextButton(
                    onPressed: () => authFlowNavigate(context, AppRoutes.login),
                    child: textWidget(
                      text: 'Back to Sign In',
                      textDecoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      textDecorationColor: AppColors.authThemeColor,
                      color: AppColors.authThemeColor,
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
