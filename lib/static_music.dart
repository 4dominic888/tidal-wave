import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class StaticMusic {
    static List<Music> musicas = [
      //* Musicas semi locales en assets, NO VAN GUARDADOS EN EL DISPOSITIVO ANDROID
      Music(
        index: 0,
        titulo: 'Babaroque (WHAT Ver.)',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Babaroque (WHAT Ver.).mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg'),
        duration: const Duration(minutes: 1, seconds: 11)
      ),
      Music(
        index: 1,
        titulo: 'Phone Me First',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg'),
        duration: const Duration(minutes: 2, seconds: 47)
      ),
      Music(
        index: 2,
        titulo: 'Eight O\'Eigh',
        artista: 'Demonicity',
        musica: Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 16)
      ),

      //* Musicas sacadas de internet
      Music(
        index: 3,
        titulo: '-Haunted-woods-',
        artista: 'WaterFlame',
        musica: Uri.parse('https://cdn.discordapp.com/attachments/1099395357160505397/1238381102591246367/478283_-Haunted-woods-.mp3?ex=663f13c6&is=663dc246&hm=0bc33c684796a332a3b31bf6d5028a25c89d6e1c32c4c9a3c177b95b125983e7&'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/JrCxzH7CoHE/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 5)
      ),
      Music(
        index: 4,
        titulo: 'Oye Mujer',
        artista: 'Ke Personajes',
        musica: Uri.parse('https://firebasestorage.googleapis.com/v0/b/loginapp-2b19d.appspot.com/o/Musica%2FKe%20Personajes%20-%20Oye%20Mujer.mp3?alt=media&token=eee7faf5-74c3-4cb4-a654-077824f4a477'),
        favorito: false,
        imagen: Uri.parse('https://firebasestorage.googleapis.com/v0/b/loginapp-2b19d.appspot.com/o/Imaguen%20Artista%2Ffondo-evento.jpg?alt=media&token=6be2a2b0-246a-45ef-addf-56d7fe98d383'),
        duration: const Duration(minutes: 3, seconds: 47)
      ),
      Music(
        index: 5,
        titulo: 'Shiawase Remix',
        artista: 'razaplaysgmd',
        musica: Uri.parse('https://cdn.discordapp.com/attachments/1099395357160505397/1238382574875840513/1296027_Shiawase-Remix.mp3?ex=663f1525&is=663dc3a5&hm=53bc97cfbfc7889fa3e851cc45cbaa35673d39731a4289b9207000740f3ef18f&'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/G-9EEDWvg9E/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 2)
      ),
    ];
}