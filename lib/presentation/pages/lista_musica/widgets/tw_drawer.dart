import 'package:flutter/material.dart';

class TWDrawer extends StatelessWidget {
  final List<Map<String, void Function()>> options;
  const TWDrawer({
    super.key, required this.options,
  });

  @override
  Widget build(BuildContext context) {

    final List<Widget> widgetList = [];

    widgetList.insert(0,
      const DrawerHeader(
        child: Center(
          //* Poner el futuro logo de Tidal Wave
          child: FlutterLogo(size: 250, style: FlutterLogoStyle.horizontal, textColor: Colors.white)
        ),
      )
    );

    widgetList.addAll(options.map((e) => ListTile(
      title: Text(e.keys.firstOrNull!),
      onTap: e.values.first,
    )));

    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.4),
      child: ListView(
        children: widgetList        
      ),
    );
  }
}