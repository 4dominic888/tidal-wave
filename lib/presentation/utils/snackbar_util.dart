import 'package:flutter/material.dart';
import 'package:tidal_wave/presentation/global_widgets/popup_message.dart';

class SnackbarUtil{
  static void successSnack(BuildContext context, {String? message = 'Correcto'}){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message!, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 5),
    ));
  }

  static void failureSnack(BuildContext context, {String? message = 'Error', String? details = 'none'}){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message!, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
      duration: const Duration(days: 1),
      action: SnackBarAction(
        label: 'detalles',
        onPressed: () {
          showDialog(context: context, builder: (context) => PopupMessage(
            title: 'Error',
            description: details!));
        },
      ),
    ));
  }
}
