import 'dart:io';

import 'package:flutter/material.dart';

class MediaMetaData extends StatelessWidget {

  final String? imgUrl;
  final String title;
  final String artist;
  final Color color;
  final double? sizePercent;

  const MediaMetaData({super.key, this.imgUrl, required this.title, required this.artist, required this.color, this.sizePercent = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(decoration: BoxDecoration(
          boxShadow: const[BoxShadow(color: Colors.black12, offset: Offset(2, 4), blurRadius: 4)],
          borderRadius: BorderRadius.circular(10)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imgUrl != null ? 
            Image.file(
              File.fromUri(Uri.parse(imgUrl!)),
              height: 300 * sizePercent!,
              width: 300 * sizePercent!,
              fit: BoxFit.cover,
            ) : Container(
              color: Colors.grey.shade600,
              height: 300 * sizePercent!,
              width: 300 * sizePercent!,
            ),
          )
        ),

        SizedBox(height: 20 * sizePercent!),

        Text(
          artist,
          style: TextStyle(color: color, fontSize: 22 * sizePercent!, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        Text(
          title,
          style: TextStyle(color: color, fontSize: 20 * sizePercent!, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}