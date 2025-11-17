import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/extensions/context_extensions.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/auth_flow/widgets/app_header.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: context.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppHeader(title: 'Verify your email'),
              const SizedBox(height: 12),
              Text(
                'A verification link was sent to your email.',
                style: context.text.bodyMedium,
              ),

              const SizedBox(height: 20),

              auth.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        await context.read<AuthProvider>().sendVerification();
                      },
                      child: const Text('Resend verification email'),
                    ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final verified = await authProvider.checkEmailVerified();

                  if (verified && context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  } else {
                    if (authProvider.error != null) {
                      if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authProvider.error!)),
                      );
                      }
                    
                    }
                  }
                },
                child: const Text("I've verified my email"),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
