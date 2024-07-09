import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tidal_wave/data/abstractions/tw_enums.dart';

Duration parseDuration(String s) {

  if(s.isEmpty) return Duration.zero;
  
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  List<String> parts = s.split(':');

  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  seconds = int.parse(parts[parts.length - 1]);

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String toStringDurationFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

bool isURL(String cadena) {
  return cadena.startsWith('http://') || cadena.startsWith('https://');
}

final Map<DataSourceType,Icon> iconMapper = {
  DataSourceType.online: const Icon(Icons.language),
  DataSourceType.fromOnline: const Icon(Icons.cloud_done),
  DataSourceType.local : const Icon(Icons.save)
};

Future showLoadingDialog(BuildContext context, AsyncCallback action, {String message = "Cargando"}) {
  return showDialog(context: context, barrierDismissible: false, builder: (context) {
    action.call().then((value) {
      if(!context.mounted) return;
      Navigator.of(context).pop();
    });
    return PopScope(
      canPop: false,
      child: AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const CircularProgressIndicator(),
              Container(margin: const EdgeInsets.only(left: 12, right: 15), child: Text(message))
            ],
          )
        ),
      ),
    );
  });
}

ImageProvider getImage(Uri uri, {bool? isOnline = true}){
  if(isOnline!){
    return CachedNetworkImageProvider(uri.toString());
  }
  return Image.file(File(uri.toString())).image;
}

Widget getWidgetImage(Uri uri, {double? width, double? height, BoxFit? fit, bool? isOnline = true}){
  if(isOnline!){
    return CachedNetworkImage(imageUrl: uri.toString(), width: width, height: height, fit: fit);
  }
  return Image(image: FileImage(File(uri.toString())), width: width, height: height, fit: fit);
}