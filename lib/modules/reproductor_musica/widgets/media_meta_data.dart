import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaMetaData extends StatelessWidget {

  final String imgUrl;
  final String title;
  final String artist;

  const MediaMetaData({super.key, required this.imgUrl, required this.title, required this.artist});

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
            child: CachedNetworkImage(
              imageUrl: imgUrl,
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          )
        ),

        const SizedBox(height: 20),

        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        Text(
          artist,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}