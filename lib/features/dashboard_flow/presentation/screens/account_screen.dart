import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/input_fields.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
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
        return Scaffold(
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
                            onTap: () {
                              if (provider.localImagePath != null ||
                                  provider.avatarUrl != null) {
                                _viewAvatar(context, provider);
                              } else {
                                _showPickAvatarSheet(provider);
                              }
                            },
                            child: _avatarImage(provider),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showPickAvatarSheet(provider),
                            child: textWidget(
                              context: context,
                              text: 'Change avatar',
                            ),
                          ),
                          textWidget(
                            context: context,
                            text: 'JPG, GIF or PNG. 1MB max.',
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.6),
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
                            onTap: () => provider.saveName(context),
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
                            context: context,
                            text: 'Danger Zone',
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 6),
                          textWidget(
                            context: context,
                            text: 'Irreversible and destructive action.',
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).hintColor.withValues(alpha: 0.6),
                          ),

                          const SizedBox(height: 12),

                          AppButton(
                            text: 'Delete Account Forever',
                            onTap: () => _confirmDelete(provider, context),
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

  Future<void> _confirmDelete(
    AccountProvider provider,
    BuildContext mainContext,
  ) async {
    final want = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: textWidget(context: context, text: 'Delete account'),
        content: textWidget(
          context: context,
          text:
              'This will permanently delete your account and all its data. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: textWidget(context: context, text: 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
            },
            child: textWidget(
              context: context,
              text: 'Delete',
              color: AppColors.errorColor,
            ),
          ),
        ],
      ),
    );
    if (want != true) return;
    if (mainContext.mounted) {
      final resultCode = await provider.deleteAccount(
        mainContext,
        passwordForReauth: null,
      );
      AppLogger.logString(resultCode.toString());
      if (resultCode == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black,
              content: textWidget(
                context: context,
                color: Colors.white,
                text: 'Account deleted',
              ),
            ),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        }
      } else if (resultCode == 'requires-recent-login' ||
          resultCode == 'user-not-found') {
        _showReauthDialog(provider);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: textWidget(
                context: context,
                color: Theme.of(context).cardColor,
                text: 'Delete failed: $resultCode',
              ),
            ),
          );
        }
      }
    }
  }

  void _showReauthDialog(AccountProvider provider) {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: textWidget(context: context, text: 'Re-authenticate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            textWidget(
              context: context,
              text:
                  'For security, please enter your password to delete the account.',
            ),
            AppPasswordField(
              label: '',
              controller: passwordCtrl,
              obscure: provider.accountPassObscure,

              onToggle: provider.toggleAccountPassObscure,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: textWidget(context: context, text: 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(true);
              final res = await provider.deleteAccount(
                context,
                passwordForReauth: passwordCtrl.text.trim(),
              );
              if (res == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: textWidget(
                        context: context,
                        color: Theme.of(context).cardColor,
                        text: 'Account deleted',
                      ),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: textWidget(
                        context: context,
                        color: Theme.of(context).cardColor,
                        text: 'Delete failed: $res',
                      ),
                    ),
                  );
                }
              }
            },
            child: textWidget(context: context, text: 'Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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

  void _viewAvatar(BuildContext context, AccountProvider provider) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: PhotoView(
          imageProvider: provider.localImagePath != null
              ? FileImage(File(provider.localImagePath!))
              : NetworkImage(provider.avatarUrl!) as ImageProvider,
        ),
      ),
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
                title: textWidget(
                  context: context,
                  text: 'Choose from gallery',
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.pickAndUploadAvatar(ImageSource.gallery, context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: textWidget(context: context, text: 'Take a photo'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  provider.pickAndUploadAvatar(ImageSource.camera, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}