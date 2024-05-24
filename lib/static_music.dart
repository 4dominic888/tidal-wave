import 'package:tidal_wave/modules/reproductor_musica/classes/musica.dart';

class StaticMusic {
    static List<Music> musicas = [
      Music(
        0,
        titulo: 'Babaroque (WHAT Ver.)',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Babaroque (WHAT Ver.).mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/jXy6YCpJnQM/hqdefault.jpg'),
        duration: const Duration(minutes: 1, seconds: 11)
      ),
      Music(
        1,
        titulo: 'Phone Me First',
        artista: 'cYsmix',
        musica: Uri.parse('asset:/assets/music/cYsmix - Phone Me First.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/uDYdecWY85w/hqdefault.jpg'),
        duration: const Duration(minutes: 2, seconds: 47)
      ),
      Music(
        2,
        titulo: 'Eight O\'Eigh',
        artista: 'Demonicity',
        musica: Uri.parse('asset:/assets/music/Demonicity - Eight O\'Eight.mp3'),
        favorito: false,
        imagen: Uri.parse('https://i.ytimg.com/vi/ksZb4xKOdzI/hqdefault.jpg'),
        duration: const Duration(minutes: 3, seconds: 16)
      ),
      //* Primera musica sacada de firebase
      Music(
        3,
        titulo: 'Oye Mujer',
        artista: 'Ke Personajes',
        musica: Uri.parse('https://firebasestorage.googleapis.com/v0/b/loginapp-2b19d.appspot.com/o/Musica%2FKe%20Personajes%20-%20Oye%20Mujer.mp3?alt=media&token=eee7faf5-74c3-4cb4-a654-077824f4a477'),
        favorito: false,
        imagen: Uri.parse('https://firebasestorage.googleapis.com/v0/b/loginapp-2b19d.appspot.com/o/Imaguen%20Artista%2Ffondo-evento.jpg?alt=media&token=6be2a2b0-246a-45ef-addf-56d7fe98d383'),
        duration: const Duration(minutes: 4, seconds: 19)
      ),
    ];
}