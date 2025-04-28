import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final Icon icon;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const InputField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
  });

  factory InputField.passwordField(
      String hintText,
      String labelText,
      Icon icon, {
        required TextEditingController controller,
        required bool obscureText,
        required String? Function(String?)? validator,
        Widget? suffixIcon,
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
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: _glowAnimation.value / 4 * 0.1),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                obscureText: widget.obscureText,
                validator: widget.validator,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  labelStyle: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  hintStyle: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                  prefixIcon: IconTheme(
                    data: IconThemeData(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    child: widget.icon,
                  ),
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.grey[800]!.withValues(alpha: 0.8 + _animationController.value * 0.2)
                      : Colors.grey[100]!.withValues(alpha: 0.8 + _animationController.value * 0.2),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 16.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2.0,
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}