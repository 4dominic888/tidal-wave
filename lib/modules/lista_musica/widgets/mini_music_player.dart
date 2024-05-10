import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:tidal_wave/bloc/music_cubit.dart';
import 'package:tidal_wave/modules/reproductor_musica/screens/reproductor_musica_screen.dart';
class MiniMusicPlayer extends StatelessWidget {

  const MiniMusicPlayer({super.key});

  Widget _circularImage(AudioPlayer state){
    return StreamBuilder<SequenceState?>(
      stream: state.sequenceStateStream,
      builder: (context, snapshot) {        
        final state = snapshot.data;
        if (state?.sequence.isEmpty ?? true) {
          return Container(
            padding: const EdgeInsets.all(36.0),
            width: 50,
            decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          ); 
        }
        final mediaItem = state!.currentSource!.tag as MediaItem;

        return GestureDetector(
          onTapUp: (_) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReproductorMusicaScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(36.0),
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape:BoxShape.circle,
              image: DecorationImage(
                image: CachedNetworkImageProvider(mediaItem.artUri.toString()),
                fit: BoxFit.cover
              )),
          ),
        );
      }
    );
  }

  Widget _titleAndArtist(AudioPlayer state){
    return Expanded(
      child: StreamBuilder<SequenceState?>(
        stream: state.sequenceStateStream,
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data?.currentSource?.tag as MediaItem?;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Text(mediaItem?.title ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w600))
              ),
              
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Text(mediaItem?.artist ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 16.0))
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, AudioPlayer>(
      builder: (context, state) {
        return Container(
          color: Colors.black,
          child: Column(
            children: [

              //? Progress bar musica
              StreamBuilder<Duration>(
                stream: state.positionStream,
                builder: (context, snapshot) {
                  final percent = (snapshot.data?.inMilliseconds ?? 0) / (state.duration?.inMilliseconds ?? 1);
                  return LinearProgressIndicator(
                    value: percent,
                    color: Colors.blue.shade400,
                    backgroundColor: Colors.grey.shade400,
                  );
                }
              ),
        
        
              Row(
                children: [
                  const SizedBox(width: 10),
                  //? Imagen circular
                  _circularImage(state),
                  
                  const SizedBox(width: 10),
        
                  //? Texto de titulo y artista de la musica
                  _titleAndArtist(state),
        
                  
                  //* Previous
                  StreamBuilder<int?>(
                    stream: state.currentIndexStream,
                    builder: (context, snapshot) {
                      if ((snapshot.data ?? 0) == 0) {
                        return IconButton(onPressed: (){}, icon: const Icon(Icons.skip_previous_sharp), color: Colors.grey.shade800);                        
                      }
                      return IconButton(onPressed: state.seekToPrevious, icon: const Icon(Icons.skip_previous_sharp), color: Colors.grey.shade500);
                    }
                  ),

                  //* Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: state.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      final playing = playerState?.playing;
                      if(!(playing ?? false)){
                        return IconButton(onPressed: state.play, icon: Icon(Icons.play_arrow_rounded, color: Colors.grey.shade500));
                      }
                      else if(processingState != ProcessingState.completed){
                        return IconButton(onPressed: state.stop, icon: Icon(Icons.pause_rounded, color: Colors.grey.shade500));
                      }
                      else {
                        return Icon(Icons.play_arrow_rounded, color: Colors.grey.shade800);
                      }
                    }
                  ),
                  
                  //* Next
                  StreamBuilder<int?>(
                    stream: state.currentIndexStream,
                    builder: (context, snapshot) {
                      if ((snapshot.data ?? 0) == (state.sequence?.length ?? 0)-1 ) {
                        return IconButton(onPressed: (){}, icon: Icon(Icons.skip_next_rounded, color: Colors.grey.shade800));
                      }
                      return IconButton(onPressed: state.seekToNext, icon: const Icon(Icons.skip_next_rounded), color: Colors.grey.shade500);
                    }
                  )
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}