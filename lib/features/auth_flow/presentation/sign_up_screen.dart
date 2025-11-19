import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Stack(
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
                          child: Form(
                            key: formKey,
                            autovalidateMode: provider.autoValidate
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppHeader(title: "Create your account"),

                                if (provider.error != null)
                                  Text(
                                    provider.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),

                                AppInputField(
                                  label: "Full Name",
                                  hint: "Full Name",
                                  controller: provider.signUpNameCtrl,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? "Required"
                                      : null,
                                ),

                                AppInputField(
                                  label: "Email",
                                  controller: provider.signUpEmailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  hint: "example@gmail.com",
                                  validator: provider.validateEmail,
                                ),

                                AppPasswordField(
                                  label: "Password",
                                  controller: provider.signUpPassCtrl,
                                  obscure: provider.signUpObscure,
                                  onToggle: provider.toggleSignUpObscure,
                                  validator: provider.validatePassword,
                                ),

                                AppPasswordField(
                                  label: "Confirm Password",
                                  controller: provider.signUpConfirmCtrl,
                                  obscure: provider.signUpConfirmObscure,
                                  onToggle: provider.toggleSignUpConfirmObscure,
                                  validator: provider.validateConfirm,
                                ),

                                const SizedBox(height: 16),

                                AppButton(
                                  onTap: () async {
                                    final valid =
                                        formKey.currentState?.validate() ??
                                        false;

                                    if (!valid) {
                                      provider.enableAutoValidate();
                                      return;
                                    }

                                    final ok = await provider.signUp();

                                    if (ok && context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.verifyEmail,
                                      );
                                    }
                                  },
                                  text: "Sign Up",
                                ),

                                TextButton(
                                  onPressed: () {
                                    provider.clearError();
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: textWidget(
                                    text: "Already have an account? Sign In",
                                    color: AppColors.greyishColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.greyishColor,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: textWidget(
                                          text: "or",
                                          color: AppColors.greyishColor,
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.greyishColor,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                AppButton(
                                  text: "Sign Up with Google",
                                  onTap: () async {
                                    final status = await provider
                                        .googleSignIn();

                                    if (status == "success" &&
                                        context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.home,
                                      );
                                    } else if (status == "cancelled" &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Google Sign-Up cancelled",
                                          ),
                                        ),
                                      );
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(status)),
                                        );
                                      }
                                    }
                                  },
                                  image: googleLogo,
                                  imageSize: 20,
                                  iconLeftMargin: 10,
                                  buttonBackgroundColor: AppColors.whiteColor,
                                  borderColor: AppColors.black,
                                  textColor: AppColors.black,
                                  isBorder: true,
                                ),

                                const SizedBox(height: 16),

                                AppButton(
                                  text: "Sign Up with Apple",
                                  onTap: () async {
                                   
                                  },
                                  icon: const Icon(
                                    Icons.apple,
                                    color: Colors.black,
                                  ),
                                  imageSize: 20,
                                  iconLeftMargin: 10,
                                  showIcon: true,
                                  buttonBackgroundColor: AppColors.whiteColor,
                                  borderColor: AppColors.black,
                                  textColor: AppColors.black,
                                  isBorder: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (provider.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.authThemeColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
