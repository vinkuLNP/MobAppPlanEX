import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(
        context,
        listen: false,
      ).loadAccountBasicInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final user = provider.user;
        return Scaffold(
          backgroundColor: AppColors.screenBackgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showPickAvatarSheet(provider),
                            child: _avatarImage(provider),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showPickAvatarSheet(provider),
                            child: textWidget(text: 'Change avatar'),
                          ),
                          textWidget(
                            text: 'JPG, GIF or PNG. 1MB max.',
                            fontSize: 12,
                            color: AppColors.greyishColor,
                          ),

                          const SizedBox(height: 16),
                          AppInputField(
                            label: 'Full Name',
                            controller: provider.nameController,
                          ),

                          const SizedBox(height: 10),
                          AppInputField(
                            label: 'Email',
                            controller: provider.emailController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Save Changes',
                            onTap: provider.saveName,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textWidget(
                            text: 'Subscriptions',
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 6),
                          textWidget(
                            text: user?.isPaid ?? false
                                ? 'Premium features with unlimited storage'
                                : 'Basic features with limited storage',
                            fontSize: 13,
                            color: AppColors.greyishColor,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Chip(
                                label: textWidget(
                                  text: user?.isPaid ?? false
                                      ? 'Premium User'
                                      : 'Free User',
                                ),
                                backgroundColor: user?.isPaid ?? false
                                    ? AppColors.premiumColor
                                    : AppColors.lightGrey,
                              ),
                              const Spacer(),
                              if (user != null && !user.isPaid)
                                Expanded(
                                  child: AppButton(
                                    text: 'Upgrade',
                                    onTap: provider.upgrade,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textWidget(
                            text: 'Danger Zone',
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 6),
                          textWidget(
                            text: 'Irreversible and destructive action.',
                            fontSize: 13,
                            color: AppColors.greyishColor,
                          ),

                          const SizedBox(height: 12),

                          AppButton(
                            text: 'Delete Account Forever',
                            onTap: () => _confirmDelete(provider),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (provider.accountLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [CircularProgressIndicator(strokeWidth: 6)],
                    ),
                  ),
                ),

              if (provider.processing)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 6,
                          color: AppColors.authThemeColor,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(AccountProvider provider) async {
    final want = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: textWidget(text: 'Delete account'),
        content: textWidget(
          text:
              'This will permanently delete your account and all its data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: textWidget(text: 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: textWidget(text: 'Delete', color: AppColors.errorColor),
          ),
        ],
      ),
    );
    if (want != true) return;

    final resultCode = await provider.deleteAccount(passwordForReauth: null);
    if (resultCode == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: textWidget(text: 'Account deleted')));
      }
    } else if (resultCode == 'requires-recent-login' ||
        resultCode == 'user-not-found') {
      _showReauthDialog(provider);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: textWidget(text: 'Delete failed: $resultCode')),
        );
      }
    }
  }

  void _showReauthDialog(AccountProvider provider) {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: textWidget(text: 'Re-authenticate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            textWidget(
              text:
                  'For security, please enter your password to delete the account.',
            ),
            TextField(controller: passwordCtrl, obscureText: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: textWidget(text: 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final res = await provider.deleteAccount(
                passwordForReauth: passwordCtrl.text.trim(),
              );
              if (res == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: textWidget(text: 'Account deleted')),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: textWidget(text: 'Delete failed: $res')),
                  );
                }
              }
            },
            child: textWidget(text: 'Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }

  Widget _avatarImage(AccountProvider provider) {
    if (provider.localImagePath != null) {
      return CircleAvatar(
        radius: 38,
        backgroundImage: FileImage(File(provider.localImagePath!)),
      );
    }

    if (provider.avatarUrl != null) {
      return CircleAvatar(
        radius: 38,
        backgroundImage: NetworkImage(provider.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.authThemeColor.withValues(alpha: 0.4),
      child: const Icon(Icons.person, color: AppColors.authThemeColor),
    );
  }

  void _showPickAvatarSheet(AccountProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: textWidget(text: 'Choose from gallery'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.pickAndUploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: textWidget(text: 'Take a photo'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.pickAndUploadAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
