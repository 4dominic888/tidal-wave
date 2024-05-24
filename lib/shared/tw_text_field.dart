// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class TWTextField extends StatelessWidget {

  final String hintText;
  final TextInputType? textInputType;
  final Icon? icon;
  final String? Function(String? value)? validator;
  final TextEditingController? controller;

  const TWTextField({
    super.key, required this.hintText, this.textInputType, this.icon, this.validator, this.controller
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: textInputType,
      obscureText: textInputType==TextInputType.visiblePassword,
      cursorColor: Colors.grey.shade500,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: Colors.grey.shade500),
      decoration: InputDecoration(
        suffixIcon: icon,
        suffixIconColor: Colors.grey,
        filled: true,
        fillColor: Colors.grey.shade900,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.transparent)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade600)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red.shade800)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.red.shade400)
        ),
      ),
    );
  }
}
