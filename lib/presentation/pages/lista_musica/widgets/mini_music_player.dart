import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tidal_wave/presentation/bloc/music_cubit.dart';
import 'package:tidal_wave/presentation/pages/reproductor_musica/screens/reproductor_musica_screen.dart';
import 'package:tidal_wave/presentation/utils/function_utils.dart';
import 'package:tidal_wave/presentation/utils/music_state_util.dart';
class MiniMusicPlayer extends StatelessWidget {

  final void Function()? externalSetState;

  const MiniMusicPlayer({super.key, this.externalSetState});

  Widget _circularImage(AudioPlayer state){
    return StreamBuilder<SequenceState?>(
      stream: state.sequenceStateStream.asBroadcastStream(),
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

        return InkWell(
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
                image: mediaItem.artUri != null ? 
                getImage(mediaItem.artUri!, isOnline: isURL(mediaItem.artUri.toString())) : Image.asset('assets/placeholder/music-placeholder.png').image,
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
        stream: state.sequenceStateStream.asBroadcastStream(),
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data?.currentSource?.tag as MediaItem?;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(scrollDirection: Axis.horizontal,
                child: Text(mediaItem?.title ?? '',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600))
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
                stream: state.positionStream.asBroadcastStream(),
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
                    stream: state.currentIndexStream.asBroadcastStream(),
                    builder: (context, snapshot) {
                      return MusicStateUtil.previousReturns<Widget>(snapshot.data, 
                        active: IconButton(onPressed: state.seekToPrevious, icon: const Icon(Icons.skip_previous_sharp), color: Colors.grey.shade500),
                        noActive: IconButton(onPressed: (){}, icon: const Icon(Icons.skip_previous_sharp), color: Colors.grey.shade800)
                      );
                    }
                  ),

                  //* Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: state.playerStateStream.asBroadcastStream(),
                    builder: (context, snapshot) {
                      return MusicStateUtil.playReturns<Widget>(snapshot.data,
                        playCase: IconButton(onPressed: state.play, icon: Icon(Icons.play_arrow_rounded, color: Colors.grey.shade500)),
                        stopCase: IconButton(onPressed: state.stop, icon: Icon(Icons.pause_rounded, color: Colors.grey.shade500)),
                        playStatic: Icon(Icons.play_arrow_rounded, color: Colors.grey.shade800)
                      );
                    }
                  ),
                  
                  //* Next
                  StreamBuilder<int?>(
                    stream: state.currentIndexStream.asBroadcastStream(),
                    builder: (context, snapshot) {
                      return MusicStateUtil.nextReturns<Widget>(snapshot.data, state,
                        active: IconButton(onPressed: state.seekToNext, icon: const Icon(Icons.skip_next_rounded), color: Colors.grey.shade500),
                        noActive: IconButton(onPressed: (){}, icon: Icon(Icons.skip_next_rounded, color: Colors.grey.shade800))
                      );
                    }
                  ),

                  IconButton(
                    icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                    onPressed: (){
                      context.read<MusicCubit>().stopMusic(externalSetState);
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