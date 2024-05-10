import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/position_data.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/controls.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/media_meta_data.dart';
import 'package:tidal_wave/shared/color_util.dart';

class ReproductorMusicaScreen extends StatefulWidget {
  
  const ReproductorMusicaScreen({super.key});

  @override
  State<ReproductorMusicaScreen> createState() => _ReproductorMusicaScreenState();
}

class _ReproductorMusicaScreenState extends State<ReproductorMusicaScreen> {

  
  List<Color> dominanColors = const [ Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)];
  Color constrastColor = Colors.white;

  //TODO Este atributo debe debe depender del atributo de la cancion a pasar
  bool tempFav = false;

  void _adjustColorBy({String? imgUrl}) async {
    if(imgUrl != null){
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imgUrl),
        size: const Size(300, 300),
        maximumColorCount: 2
      );
      if (paletteGenerator.colors.length >= 2) {
        dominanColors = paletteGenerator.colors.take(2).toList();
      }
      else if (paletteGenerator.colors.length == 1) {
        dominanColors = [paletteGenerator.colors.first, Colors.black]; 
      }
      else{
        dominanColors = const [ Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)];
      }
    }
    else{
      dominanColors = const [Color.fromARGB(255, 30, 114, 138),Color(0xFF071A2C)];
    }
    setState(() {
      constrastColor = dominanColors.last.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      //* Parte superior
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Container()),
            IconButton(icon: Icon(tempFav ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: constrastColor, size: 30), onPressed: () {
              setState(() {
                tempFav = !tempFav;
              });
            })
          ],
        ),
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: constrastColor, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Container(
            padding: const EdgeInsets.all(20),
            height: double.infinity,
            width: double.infinity,
            //* background color
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dominanColors.take(2).toList()
              )
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //* campo de informacion de la cancion
                StreamBuilder<SequenceState?>(
                  stream: context.read<MusicCubit>().state.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    if(state?.sequence.isEmpty ?? true){
                      _adjustColorBy();
                      return const SizedBox();
                    }
                    final metaData = state!.currentSource!.tag as MediaItem;
                    _adjustColorBy(imgUrl: metaData.artUri.toString());
                    return MediaMetaData(
                      imgUrl: metaData.artUri.toString(),
                      title: metaData.title,
                      artist: metaData.artist ?? '',
                      color: constrastColor
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                //* barra de progreso de la cancion
                StreamBuilder<PositionData>(
                  stream: context.read<MusicCubit>().positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return Column(
                      children: [
                        ProgressBar(
                          barHeight: 8,
                          baseBarColor: Colors.grey.shade600,
                          bufferedBarColor: Colors.grey,
                          progressBarColor: ColorUtil.darken(dominanColors[0], amount: 0.3),
                          thumbColor: ColorUtil.darken(dominanColors[1], amount: 0.3),
                          timeLabelTextStyle: TextStyle(color: constrastColor, fontWeight: FontWeight.w600),
                                    
                          progress: positionData?.position ?? Duration.zero,
                          buffered: positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ??  Duration.zero,
                          onSeek: context.read<MusicCubit>().state.seek,
                        ),
                        ((positionData?.duration ?? Duration.zero) == Duration.zero) ? SizedBox(
                          height: 15,
                          child: CircularProgressIndicator(color: constrastColor
                        )) : const SizedBox()
                      ],
                    );
                  },
                ),
                
                //* controles
                Controls(audioPlayer: context.read<MusicCubit>().state, color: constrastColor)
              ],
            )
      ),
    );
  }
}