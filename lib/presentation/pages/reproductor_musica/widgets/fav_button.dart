import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tidal_wave/domain/use_case/interfaces/music_manager_use_case.dart';

class FavIcon extends StatefulWidget {

  final Color constrastColor;
  final bool? fav;
  final String musicId;

  const FavIcon({super.key, required this.constrastColor, this.fav, required this.musicId});

  @override
  State<FavIcon> createState() => _FavIconState();
}

class _FavIconState extends State<FavIcon> {

  //TODO Este atributo debe debe depender del atributo de la cancion a pasar
  late bool tempFav;

  final _musicManagerUserCase = GetIt.I<MusicManagerUseCase>();

  @override
  void initState() {
    super.initState();
    tempFav = widget.fav ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(tempFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: widget.constrastColor, size: 30), onPressed: () async {
      setState(() {
        tempFav = !tempFav;
      });
      await _musicManagerUserCase.establecerFavorito(widget.musicId, tempFav);
    });
  }
}