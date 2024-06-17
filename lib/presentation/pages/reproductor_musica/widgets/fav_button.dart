import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavIcon extends StatefulWidget {

  final Color constrastColor;
  final bool? fav;

  const FavIcon({super.key, required this.constrastColor, this.fav});

  @override
  State<FavIcon> createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {

  //TODO Este atributo debe debe depender del atributo de la cancion a pasar
  late bool tempFav;

  @override
  void initState() {
    super.initState();
    tempFav = widget.fav ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(tempFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: widget.constrastColor, size: 30), onPressed: () {
      setState(() {
        tempFav = !tempFav;
      });
    });
  }
}