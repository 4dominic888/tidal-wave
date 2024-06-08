import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TWTextField extends StatelessWidget {

  final String hintText;
  final TextInputType? textInputType;
  final Icon? icon;
  final String? Function(String? value)? validator;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled ;
  final void Function(String)? onChanged;

  const TWTextField({
    super.key, required this.hintText, this.textInputType, this.icon, this.validator, this.controller, this.inputFormatters, this.onChanged, this.enabled = true
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      controller: controller,
      keyboardType: textInputType,
      obscureText: textInputType==TextInputType.visiblePassword,
      cursorColor: Colors.grey.shade500,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: Colors.grey.shade500),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        suffixIcon: icon,
        suffixIconColor: enabled! ? Colors.grey : Colors.grey.shade800,
        filled: true,
        fillColor: Colors.grey.shade900,
        hintText: hintText,
        hintStyle: TextStyle(color: enabled! ? Colors.grey.shade600 : Colors.grey.shade800),
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
