import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_assets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/routes/auth_flow_navigation.dart';
import 'package:plan_ex_app/features/auth_flow/data/enum.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
    return Consumer<AuthUserProvider>(
      builder: (context, provider, _) {
        final accountProvider = context.read<AccountProvider>();

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
                                  textWidget(
                                    context: context,
                                    text: provider.error!,
                                    color: Colors.red,
                                  ),

                                AppInputField(
                                  label: "Full Name",
                                  hint: "Full Name",
                                  controller: provider.signUpNameCtrl,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                      ? "Required"
                                      : v.length < 3
                                      ? "Atleast 3 characters req"
                                      : null,
                                ),
                                context.gap8,

                                AppInputField(
                                  label: "Email",
                                  controller: provider.signUpEmailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  hint: "example@gmail.com",
                                  validator: provider.validateEmail,
                                ),
                                context.gap8,

                                AppPasswordField(
                                  label: "Password",
                                  controller: provider.signUpPassCtrl,
                                  obscure: provider.signUpObscure,
                                  onToggle: provider.toggleSignUpObscure,
                                  validator: provider.validatePassword,
                                ),
                                context.gap8,

                                AppPasswordField(
                                  label: "Confirm Password",
                                  controller: provider.signUpConfirmCtrl,
                                  obscure: provider.signUpConfirmObscure,
                                  onToggle: provider.toggleSignUpConfirmObscure,
                                  validator: provider.validateConfirm,
                                ),

                                context.gap24,
                                AppButton(
                                  onTap: () async {
                                    final valid =
                                        formKey.currentState?.validate() ??
                                        false;

                                    if (!valid) {
                                      provider.enableAutoValidate();
                                      return;
                                    }

                                    final status = await provider.signUp();

                                    if (!context.mounted) return;

                                    if (status == SignUpStatus.success ||
                                        status ==
                                            SignUpStatus.unverifiedExisting ||
                                        status ==
                                            SignUpStatus.tooManyRequests) {
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
                                    authFlowNavigate(context, AppRoutes.login);
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Already have an account? ",
                                      style: appTextStyle(
                                        context: context,
                                        color: Theme.of(
                                          context,
                                        ).hintColor.withValues(alpha: 0.6),
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Sign In!",
                                          style: appTextStyle(
                                            context: context,
                                            fontSize: 14,

                                            textDecorationColor:
                                                AppColors.authThemeColor,
                                            color: AppColors.authThemeColor,
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
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 80,
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
                                  text: "Sign Up with Google",
                                  onTap: () async {
                                    final status = await provider
                                        .googleSignIn();

                                    if (status == "success") {

                                      accountProvider.startUserListener();
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.home,
                                        );

                                        provider.clearControllers();
                                      }
                                    } else if (status == "cancelled" &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: textWidget(
                                            context: context,
                                            text: "Google Sign-Up cancelled",
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
                                  buttonBackgroundColor: AppColors.whiteColor,
                                  borderColor: AppColors.black,
                                  textColor: AppColors.black,
                                  isBorder: true,
                                ),

                                const SizedBox(height: 16),
                                /*    if (Platform.isIOS)
                                  AppButton(
                                    text: "Sign Up with Apple",
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
                                        provider.clearControllers();
                                      } else if (status == "cancelled" &&
                                          context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: textWidget(
                                              context: context,
                                              text: "Apple Sign-In cancelled",
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
                             */
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
