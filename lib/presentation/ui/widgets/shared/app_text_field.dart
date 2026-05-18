import 'package:flutter/material.dart';
import 'package:street_team/core/config/theme/app_color.dart';
import 'package:street_team/core/config/theme/typography.dart';

class AppTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Local state to track visibility
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    // Initialize with the value passed from the constructor
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _isObscured, // Use the local state here
      cursorColor: AppColors.brandPrimary,
      cursorWidth: 2.0,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint,
        filled: true,
        // Add the eye icon only if obscureText was initially true
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary.withAlpha(150),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.brandPrimary,
            width: 1.5,
          ),
        ),
        fillColor: AppColors.placeholderText.withAlpha(25),
        hintStyle: AppTypography.captionSmall.copyWith(
          color: AppColors.textSecondary.withAlpha(120),
        ),
      ),
    );
  }
}
