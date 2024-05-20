import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/bloc/music_color_cubit.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/position_data.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/controls.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/fav_button.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/media_meta_data.dart';
import 'package:tidal_wave/shared/color_util.dart';

class ReproductorMusicaScreen extends StatefulWidget {
  
  const ReproductorMusicaScreen({super.key});

  @override
  State<ReproductorMusicaScreen> createState() => _ReproductorMusicaScreenState();
}

class _ReproductorMusicaScreenState extends State<ReproductorMusicaScreen> {
  
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
            BlocBuilder<MusicColorCubit, ImportantColors>(
              builder: (context, snapshot) {
                return FavIcon(constrastColor: snapshot.constrastColor, fav: false);
              }
            )
          ],
        ),
        leading: Row(
          children: [
            BlocBuilder<MusicColorCubit, ImportantColors>(
              builder: (context, snapshot) {
                return IconButton(
                  icon: Icon(Icons.arrow_back, color: snapshot.constrastColor, size: 30),
                  onPressed: () => Navigator.pop(context),
                );
              }
            ),
          ],
        ),
      ),
      body: BlocBuilder<MusicColorCubit, ImportantColors>(
        builder: (context, colorSnapshot) {
          return Container(
                padding: const EdgeInsets.all(20),
                height: double.infinity,
                width: double.infinity,
                //* background color
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[colorSnapshot.dominanColor1, colorSnapshot.dominanColor2]
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //* campo de informacion de la cancion
                    StreamBuilder<SequenceState?>(
                      stream: context.read<MusicCubit>().state.sequenceStateStream.asBroadcastStream(),
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if(state?.sequence.isEmpty ?? true){
                          context.read<MusicColorCubit>().updateByImgUrl();
                          return const SizedBox();
                        }
                        final metaData = state!.currentSource!.tag as MediaItem;
                        final importantColors = ImportantColors(colorSnapshot.dominanColor1, colorSnapshot.dominanColor2, colorSnapshot.constrastColor);
                          context.read<MusicColorCubit>().updateByImgUrl(url: metaData.artUri.toString()).then((value) {
                            if (importantColors.dominanColor1 != value.dominanColor1) {
                              context.read<MusicColorCubit>().update(value.dominanColor1, value.dominanColor2, value.constrastColor);
                            }
                          });
                        return MediaMetaData(
                          imgUrl: metaData.artUri.toString(),
                          title: metaData.title,
                          artist: metaData.artist ?? '',
                          color: colorSnapshot.constrastColor
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    //* barra de progreso de la cancion
                    StreamBuilder<PositionData>(
                      stream: context.read<MusicCubit>().positionDataStream.asBroadcastStream(),
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return Column(
                          children: [
                            ProgressBar(
                              barHeight: 8,
                              baseBarColor: Colors.grey.shade600,
                              bufferedBarColor: Colors.grey,
                              progressBarColor: ColorUtil.darken(colorSnapshot.dominanColor1, amount: 0.3),
                              thumbColor: ColorUtil.darken(colorSnapshot.dominanColor2, amount: 0.3),
                              timeLabelTextStyle: TextStyle(color: colorSnapshot.constrastColor, fontWeight: FontWeight.w600),
                                        
                              progress: positionData?.position ?? Duration.zero,
                              buffered: positionData?.bufferedPosition ?? Duration.zero,
                              total: positionData?.duration ??  Duration.zero,
                              onSeek: context.read<MusicCubit>().state.seek,
                            ),
                            ((positionData?.duration ?? Duration.zero) == Duration.zero) ? SizedBox(
                              height: 15,
                              child: CircularProgressIndicator(color: colorSnapshot.constrastColor
                            )) : const SizedBox()
                          ],
                        );
                      },
                    ),
                    
                    //* controles
                    Controls(audioPlayer: context.read<MusicCubit>().state, color: colorSnapshot.constrastColor)
                  ],
                )
          );
        }
      ),
    );
  }
}