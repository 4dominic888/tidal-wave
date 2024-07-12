// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class PopupSelect extends StatelessWidget{
  final List<Map<String, void Function()>> actions;

  const PopupSelect({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: actions.map((e) =>
                ListTile(
                  title: Text(e.keys.first),
                  onTap: e.values.first,
                )).toList(),
            ),
          )
        ],
      )
    );
  }
}

class PopupMessage extends StatelessWidget {

  final String title;
  final String description;
  final void Function()? onClose;

  const PopupMessage({super.key, required this.title, required this.description, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(onPressed: () { onClose == null ?  Navigator.of(context).pop() : onClose?.call(); },
        child: const Text('Cerrar'))
      ],
    );
  }
}

class PopupDialog extends StatelessWidget {

  final String title;
  final String description;
  final void Function()? onOK;
  final void Function()? onCancel;

  const PopupDialog({super.key, required this.title, required this.description, this.onOK, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(onPressed: () { onOK == null ?  Navigator.of(context).pop() : onOK?.call(); },
        child: const Text('Si')),
        
        TextButton(onPressed: () { onCancel == null ?  Navigator.of(context).pop() : onCancel?.call(); },
        child: const Text('No'))
      ],
    );
  }
}