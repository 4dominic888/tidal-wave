import 'package:flutter/material.dart';

class TWDropdownbuttonField extends StatefulWidget {

  final Icon? icon;
  final String label;
  final List<Map<String, String>> items;
  final TextEditingController? controller;

  const TWDropdownbuttonField({super.key, required this.label, required this.items, this.controller, this.icon});

  @override
  State<TWDropdownbuttonField> createState() => _TWDropdownbuttonFieldState();
}

class _TWDropdownbuttonFieldState extends State<TWDropdownbuttonField> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.grey.shade900,
      decoration: InputDecoration(
        suffixIcon: widget.icon,
        suffixIconColor: Colors.grey.shade500,
        label: Text(widget.label, style: TextStyle(color: Colors.grey.shade600)),
        filled: true,
        fillColor: Colors.grey.shade900,
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
      items: widget.items.map((e) => DropdownMenuItem<String>(
        value: e.values.first,
        child: Text(e.keys.first, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
      )).toList(),
      onChanged: (value) => setState(() {widget.controller?.text = value!;}),
      validator: (value) {
        if(value == null) return 'Debes seleccionar una de las opciones';
        return null;
      },
    );
  }
}