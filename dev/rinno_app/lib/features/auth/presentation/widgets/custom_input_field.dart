// lib/features/auth/presentation/widgets/custom_input_field.dart
import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? hintText;

  const CustomInputField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.hintText,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  void _onFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onTap: () => _onFocusChange(true),
            onEditingComplete: () => _onFocusChange(false),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              labelStyle: TextStyle(
                color: _isFocused ? const Color(0xFF2E7D32) : Colors.grey,
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _isFocused ? const Color(0xFF2E7D32) : Colors.grey,
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD32F2F)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        );
      },
    );
  }
}