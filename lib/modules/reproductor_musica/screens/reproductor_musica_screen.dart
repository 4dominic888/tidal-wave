import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tidal_wave/modules/reproductor_musica/classes/position_data.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/controls.dart';
import 'package:tidal_wave/modules/reproductor_musica/widgets/media_meta_data.dart';

class ReproductorMusicaScreen extends StatefulWidget {
  const ReproductorMusicaScreen({super.key});

  @override
  State<ReproductorMusicaScreen> createState() => _ReproductorMusicaScreenState();
}

class _ReproductorMusicaScreenState extends State<ReproductorMusicaScreen> {

  late AudioPlayer _audioPlayer;
  late final ConcatenatingAudioSource _playList;
  List<Color> dominanColors = [const Color.fromARGB(255, 30, 114, 138),const Color(0xFF071A2C)];
  Color constrastColor = Colors.white;

  Stream<PositionData> get _positionDataStream => 
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
      _audioPlayer.positionStream, _audioPlayer.bufferedPositionStream, _audioPlayer.durationStream,
      (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero)
    );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _init().then((value) => print("listoooo"));
  }

  Future<void> _init() async{
    await _audioPlayer.setLoopMode(LoopMode.all);
    _playList = ConcatenatingAudioSource(children: [
        AudioSource.uri(
        Uri.parse('asset:/assets/music/cYsmix - Babaroque (WHAT Ver.).mp3'),
          tag: MediaItem(
            id: '0',
            title: 'Babaroque (WHAT Ver.)',
            artist: 'cYsmix',
            artUri: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg')
          )
        ),
        AudioSource.uri(
          Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
          tag: MediaItem(
            id: '1',
            title: 'Phone Me First',
            artist: 'cYsmix',
            artUri: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg')
          )
        ),
        AudioSource.uri(
          Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
          tag: MediaItem(
            id: '2',
            title: 'Eight O\'Eigh',
            artist: 'Demonicity',
            artUri: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg')
          )      
        )        
      ]);

    await _audioPlayer.setAudioSource(_playList);
  }

  void _adjustColorBy({String? imgUrl}) async {
    if(imgUrl != null){
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(imgUrl),
        size: const Size(300, 300),
        maximumColorCount: 2
      );
      setState(() {
        dominanColors = paletteGenerator.colors.take(2).toList();
      });      
    }
    else{
      setState(() {
        dominanColors = [const Color.fromARGB(255, 30, 114, 138),const Color(0xFF071A2C)];        
      });
    }
    setState(() {
      constrastColor = dominanColors[1].computeLuminance() > 0.5 ? Colors.black : Colors.white;
    });
  }

  Color _darken(Color color, {double amount = .1}){
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: (){},
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
            colors: dominanColors
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<SequenceState?>(
              stream: _audioPlayer.sequenceStateStream,
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
                  title: metaData.artist ?? '',
                  artist: metaData.title,
                  color: constrastColor
                );
              },
            ),
            const SizedBox(height: 20),
            
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  barHeight: 8,
                  baseBarColor: Colors.grey.shade600,
                  bufferedBarColor: Colors.grey,
                  progressBarColor: _darken(dominanColors[0], amount: 0.3),
                  thumbColor: _darken(dominanColors[1], amount: 0.3),
                  timeLabelTextStyle: TextStyle(color: constrastColor, fontWeight: FontWeight.w600),

                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ??  Duration.zero,
                  onSeek: _audioPlayer.seek,
                );
              },
            ),
            
            Controls(audioPlayer: _audioPlayer, color: constrastColor)
          ],
        ),
      ),
    );
  }
}