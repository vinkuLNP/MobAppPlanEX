import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
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
                    const AppHeader(title: "Create your account"),
          
                    if (provider.error != null)
                      Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
          
                    AppInputField(
                      label: "Full Name",
                      hint:"Full Name" ,
                      controller: provider.signUpNameCtrl,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Required" : null,
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
          
                    provider.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              final valid =
                                  formKey.currentState?.validate() ?? false;
          
                              if (!valid) {
                                provider.enableAutoValidate();
                                return;
                              }
          
                              final ok = await provider.signUp(
          
          
                              );
          
                              if (ok && context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.verifyEmail,
                                );
                              }
                            },
                            child: Text(
                              "Sign Up",
                              style: appTextStyle(
                                fontSize: 14,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ),
          
                    const SizedBox(height: 16),
          
                    TextButton(
                      onPressed: () {
                        provider.clearError(); 
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        "Already have an account? Sign In",
                        style: context.text.bodySmall,
                      ),
                    )
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
