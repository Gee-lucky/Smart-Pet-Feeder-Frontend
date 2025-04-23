import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final String labelText;
  final Icon? icon;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    required this.hintText,
    required this.labelText,
    this.icon,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
  });

  static Widget passwordField(
      String hintText,
      String labelText,
      Icon icon, {
        required TextEditingController controller,
        required bool obscureText,
        required String? Function(String?) validator,
        required Widget suffixIcon,
      }) {
    return InputField(
      hintText: hintText,
      labelText: labelText,
      icon: icon,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: icon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}