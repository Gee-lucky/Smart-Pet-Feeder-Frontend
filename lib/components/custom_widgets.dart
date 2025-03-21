import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final Icon icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool obscureText;

  const InputField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.icon,
    required this.controller,
    this.validator,
    this.suffixIcon,
    this.onSuffixPressed,
    this.obscureText = false,
  });

  factory InputField.passwordField(
    String hintText,
    String labelText,
    Icon icon, {
    bool obscureText = true,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    VoidCallback? onPressed,
    required TextEditingController controller,
    required Icon prefixIcon,
  }) {
    return InputField(
      hintText: hintText,
      labelText: labelText,
      icon: icon,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      suffixIcon: suffixIcon,
      onSuffixPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: icon,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: suffixIcon!,
                onPressed: onSuffixPressed,
              )
            : null,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
      ),
      validator: validator,
    );
  }
}
