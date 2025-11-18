import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.whiteColor,
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
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const AppHeader(title: "Welcome Back"),

                                if (provider.error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: textWidget(
                                      text: provider.error!,
                                      color: AppColors.errorColor,
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
                                Align(
                                  alignment: AlignmentGeometry.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      provider.clearError();
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.forgot,
                                      );
                                    },
                                    child: textWidget(
                                      text: "Forgot password?",
                                      color: AppColors.greyishColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                AppButton(
                                  text: "Login",
                                  onTap: () async {
                                    AppLogger.logString('Button tapped');
                                    final valid =
                                        formKey.currentState?.validate() ??
                                        false;
                                    AppLogger.logString('Form Valid: $valid');
                                    if (!valid) {
                                      provider.enableAutoValidate();
                                      return;
                                    }

                                    final status = await provider.signIn();

                                    if (status == "verified" &&
                                        context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.home,
                                      );
                                    } else if (status == "unverified" &&
                                        context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.verifyEmail,
                                      );
                                    }
                                  },
                                ),

                                TextButton(
                                  onPressed: () {
                                    provider.clearError();
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.signup,
                                    );
                                  },
                                  child: textWidget(
                                    text: "Didn't have an account? Sign Up!",
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
                                  text: "Login with Google",
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
                                            "Google Sign-In cancelled",
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
                                  text: "Login with Apple",
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
                                            "Google Sign-In cancelled",
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
                        color: Colors.black.withValues(alpha:  0.4),
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
