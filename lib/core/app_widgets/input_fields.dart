import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';

class AppInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;
  final Function(String?)? onFieldSubmitted;

  final String? hint;
  final int? maxLength;
  final int? maxLines;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  final AutovalidateMode? autovalidateMode;

  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const AppInputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters = const [],
    this.onChanged,
    this.readOnly = false,
    this.hint,
    this.maxLength,
    this.onTap,
    this.focusNode,
    this.autovalidateMode,
    this.maxLines,
    super.key,
    this.onFieldSubmitted
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(
          text: label,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          context: context,
        ),
        const SizedBox(height: 8),
        TextFormField(
          focusNode:focusNode ,
          onTap: onTap,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: autovalidateMode,
          controller: controller,
          style: appTextStyle(context: context, fontSize: 12),
          keyboardType: keyboardType,
          readOnly: readOnly!,
          maxLength: maxLength,
          maxLines: maxLength != null ? 1 : maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            filled: readOnly,
            fillColor: readOnly!
                ? Theme.of(context).highlightColor.withValues(alpha: 0.4)
                : Theme.of(context).hintColor,
            errorStyle: appTextStyle(
              context: context,
              fontSize: 12,
              color: Colors.red,
            ),
            hintStyle: appTextStyle(
              context: context,
              fontSize: 12,
              color: Theme.of(context).hintColor,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.authThemeColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: maxLines != null ? 4 : 0,
            ),
          ),

          validator: validator,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}

class AppPasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onTap;
  final Function(String?)? onFieldSubmitted;

  final AutovalidateMode? autovalidateMode;
  final VoidCallback onToggle;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;
  const AppPasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(
          text: label,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          context: context,
        ),

        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          focusNode: focusNode,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          style: appTextStyle(context: context, fontSize: 12),
          decoration: InputDecoration(
            hintText: '******',
            hintStyle: appTextStyle(
              context: context,
              fontSize: 12,
              color: Colors.grey,
            ),
            errorStyle: appTextStyle(
              context: context,
              fontSize: 12,
              color: Colors.red,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.authThemeColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 0,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color:Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.6): Colors.black.withValues(alpha: 0.6),
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
