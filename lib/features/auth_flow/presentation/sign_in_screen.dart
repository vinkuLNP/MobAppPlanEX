import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:provider/provider.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: context.pagePadding,
              child: Form(
                key: formKey,
                autovalidateMode: provider.autoValidate
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppHeader(title: "Welcome back"),

                    if (provider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    AppInputField(
                      label: "Email",
                      controller: provider.signInEmailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      hint: "example@gmail.com",
                      validator: provider.validateEmail,
                      onChanged: (_) {
                        if (provider.autoValidate) {
                          formKey.currentState?.validate();
                        }
                      },
                    ),

                    AppPasswordField(
                      label: "Password",
                      controller: provider.signInPassCtrl,
                      obscure: provider.signInObscure,
                      onToggle: provider.toggleSignInObscure,
                      validator: provider.validatePassword,
                      onChanged: (_) {
                        if (provider.autoValidate) {
                          formKey.currentState?.validate();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    provider.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              AppLogger.logString('Dattta Tappped');
                              final valid =
                                  formKey.currentState?.validate() ?? false;
                              AppLogger.logString(
                                'Form Valid---------------->.  $valid',
                              );
                              if (!valid) {
                                provider.enableAutoValidate();
                                return;
                              }

                              final ok = await provider.signIn();

                              if (ok && context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.verifyEmail,
                                );
                              }
                            },
                            child: Text(
                              "Sign In",
                              style: appTextStyle(
                                fontSize: 14,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            provider.clearError();
                            Navigator.pushNamed(context, AppRoutes.signup);
                          },
                          child: Text(
                            "Create account",
                            style: context.text.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearError();
                            Navigator.pushNamed(context, AppRoutes.forgot);
                          },
                          child: Text(
                            "Forgot password?",
                            style: context.text.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
