import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: context.pagePadding,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppHeader(title: 'Forgot password'),

                if (auth.error != null)
                  Text(auth.error!, style: const TextStyle(color: Colors.red)),

              
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

              context.gap40,

                auth.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          await context.read<AuthProvider>().resetPassword(
                            emailCtrl.text.trim(),
                          );
                        },
                        child: Text(
                          'Send reset link',
                           style: appTextStyle(
                                fontSize: 14,
                                color: AppColors.backgroundColor,
                              ),
                        ),
                      ),

                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.login),
                  child: Text('Back to login', style: context.text.bodySmall),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
