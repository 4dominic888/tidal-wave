import 'package:flutter/material.dart';

class TextFieldFind extends StatefulWidget {
  final String? hintText;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  const TextFieldFind({super.key, this.hintText, this.suffixIcon, this.onChanged});

  @override
  State<TextFieldFind> createState() => _TextFieldFindState();
}

class _TextFieldFindState extends State<TextFieldFind> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.white
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(300),
            borderSide: const BorderSide(color: Colors.transparent)
          ),
          fillColor: const Color.fromRGBO(171, 196, 248, 0.2),
          filled: true,
          suffixIcon: widget.suffixIcon,
          contentPadding: const EdgeInsets.all(15),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(300),
            borderSide: const BorderSide(color: Color.fromRGBO(171, 196, 248, 0.6))
          ),
        ),
        autocorrect: false,
        enableSuggestions: false,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        onChanged: widget.onChanged ?? (_){},
    );
  }
}