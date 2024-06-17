import 'package:flutter/material.dart';

class TitleContainer extends StatefulWidget {
  final String text;
  const TitleContainer({super.key, required this.text});

  @override
  State<TitleContainer> createState() => _TitleContainerState();
}

class _TitleContainerState extends State<TitleContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black.withOpacity(0.2),Colors.white.withOpacity(0.2)]
        )
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 5),
            child: Icon(Icons.multitrack_audio_sharp, size: 40, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40, left: 40, top: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(widget.text,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )
        ],
      ),
    );
  }
}