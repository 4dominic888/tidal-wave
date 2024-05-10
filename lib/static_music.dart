import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class StaticMusic {
    static List<Music> musicas = [
      //* Musicas semi locales en assets, NO VAN GUARDADOS EN EL DISPOSITIVO ANDROID
      Music(
        titulo: 'Babaroque (WHAT Ver.)',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Babaroque (WHAT Ver.).mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg'),
        duration: const Duration(minutes: 1, seconds: 11)
      ),
      Music(
        titulo: 'Phone Me First',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg'),
        duration: const Duration(minutes: 2, seconds: 47)
      ),
      Music(
        titulo: 'Eight O\'Eigh',
        artista: 'Demonicity',
        musica: Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 16)
      ),

      //* Musicas sacadas de internet
      Music(
        titulo: '-Haunted-woods-',
        artista: 'WaterFlame',
        musica: Uri.parse('https://cdn.discordapp.com/attachments/1099395357160505397/1238381102591246367/478283_-Haunted-woods-.mp3?ex=663f13c6&is=663dc246&hm=0bc33c684796a332a3b31bf6d5028a25c89d6e1c32c4c9a3c177b95b125983e7&'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/JrCxzH7CoHE/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 5)
      ),
      Music(
        titulo: '-RUN-',
        artista: 'WaterFlame',
        musica: Uri.parse('https://cdn.discordapp.com/attachments/1099395357160505397/1238381570369523773/475234_-Run-.mp3?ex=663f1436&is=663dc2b6&hm=1ccb53652ea11afa08f61c7eca88e9c2345b419d081e6ad0e2ac20da078efd02&'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/WbLBKn5MOqs/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 47)
      ),
      Music(
        titulo: 'Shiawase Remix',
        artista: 'razaplaysgmd',
        musica: Uri.parse('https://cdn.discordapp.com/attachments/1099395357160505397/1238382574875840513/1296027_Shiawase-Remix.mp3?ex=663f1525&is=663dc3a5&hm=53bc97cfbfc7889fa3e851cc45cbaa35673d39731a4289b9207000740f3ef18f&'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/G-9EEDWvg9E/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 2)
      ),
    ];
}