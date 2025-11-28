import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/routes/auth_flow_navigation.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
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
    return PopScope(
      canPop: false,
      child: Consumer<AuthUserProvider>(
        builder: (context, provider, _) {
          final accountProvider = context.read<AccountProvider>();
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
                                  const AppHeader(
                                    title: "Your Personal Productivity Companion",
                                    onTap: false,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (provider.error != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: textWidget(
                                              context: context,
                                              text: provider.error!,
                                              color: AppColors.errorColor,
                                            ),
                                          ),
                                        AppInputField(
                                          label: "Email",
                                          controller: provider.signInEmailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hint: "example@gmail.com",
                                          validator: provider.validateEmail,
                                          onChanged: (_) {
                                            if (provider.autoValidate) {
                                              formKey.currentState?.validate();
                                            }
                                          },
                                        ),
                                        context.gap8,
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
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              provider.clearError();
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.forgot,
                                              );
                                            },
                                            child: textWidget(
                                              context: context,
                                              text: "Forgot password?",
                                              fontSize: 14,
                                              color: AppColors.authThemeColor,
                                              textDecorationColor:
                                                  AppColors.authThemeColor,
                                              textDecoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        AppButton(
                                          text: "Login",
                                          onTap: () async {
                                            AppLogger.logString('Button tapped');
                                            final valid =
                                                formKey.currentState
                                                    ?.validate() ??
                                                false;
                                            AppLogger.logString(
                                              'Form Valid: $valid',
                                            );
                                            if (!valid) {
                                              provider.enableAutoValidate();
                                              return;
                                            }
      
                                            final status = await provider
                                                .signIn();
                                            if (status == "verified") {
                                              provider.signInEmailCtrl.clear();
                                              provider.signInPassCtrl.clear();
      
                                              await accountProvider
                                                  .loadAccountBasicInfo();
                                              await accountProvider
                                                  .loadSettingsData();
                                              if (context.mounted) {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoutes.home,
                                                );
                                              }
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
                                            authFlowNavigate(
                                              context,
                                              AppRoutes.signup,
                                            );
                                          },
                                          child: RichText(
                                            text: TextSpan(
                                              text: "Didn't have an account? ",
                                              style: appTextStyle(
                                                context: context,
                                                color: Theme.of(context).hintColor
                                                    .withValues(alpha: 0.6),
                                                fontSize: 14,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Sign Up!",
                                                  style: appTextStyle(
                                                    context: context,
                                                    fontSize: 14,
                                                    textDecorationColor:
                                                        AppColors.authThemeColor,
                                                    color:
                                                        AppColors.authThemeColor,
                                                    textDecoration:
                                                        TextDecoration.underline,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 80,
                                                child: Divider(
                                                  color: AppColors.greyishColor,
                                                  thickness: 1,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                child: textWidget(
                                                  context: context,
                                                  text: "or",
                                                  color: AppColors.greyishColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 80,
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
                                            if (status == "success") {
                                              await accountProvider
                                                  .loadAccountBasicInfo();
                                              await accountProvider
                                                  .loadSettingsData();
                                              if (context.mounted) {
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoutes.home,
                                                );
                                              }
                                            } else if (status == "cancelled" &&
                                                context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: textWidget(
                                                    context: context,
                                                    text:
                                                        "Google Sign-In cancelled",
                                                    color: AppColors.whiteColor,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: textWidget(
                                                      context: context,
                                                      text: status,
                                                      color: AppColors.whiteColor,
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          image: googleLogo,
                                          imageSize: 20,
                                          iconLeftMargin: 10,
                                          buttonBackgroundColor:
                                              AppColors.whiteColor,
                                          borderColor: AppColors.black,
                                          textColor: AppColors.black,
                                          isBorder: true,
                                        ),
                                        const SizedBox(height: 16),
                                        if (Platform.isIOS)
                                          AppButton(
                                            text: "Login with Apple",
                                            onTap: () async {
                                              final status = await provider
                                                  .appleSignIn();
      
                                              if (status == "success") {
                                                await accountProvider
                                                    .loadAccountBasicInfo();
                                                await accountProvider
                                                    .loadSettingsData();
                                                if (context.mounted) {
                                                  Navigator.pushReplacementNamed(
                                                    context,
                                                    AppRoutes.home,
                                                  );
                                                }
                                              } else if (status == "cancelled" &&
                                                  context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: textWidget(
                                                      context: context,
                                                      text:
                                                          "Apple Sign-In cancelled",
                                                      color: AppColors.whiteColor,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: textWidget(
                                                        context: context,
                                                        text: status,
                                                        color:
                                                            AppColors.whiteColor,
                                                      ),
                                                    ),
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
                                            buttonBackgroundColor:
                                                AppColors.whiteColor,
                                            borderColor: AppColors.black,
                                            textColor: AppColors.black,
                                            isBorder: true,
                                          ),
                                      ],
                                    ),
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
      ),
    );
  }
}
