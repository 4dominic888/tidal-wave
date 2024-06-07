Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  List<String> parts = s.split(':');

  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  seconds = int.parse(parts[parts.length - 1]);

  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

String toStringDurationFormat(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

bool isURL(String cadena) {
  return cadena.startsWith('http://') || cadena.startsWith('https://');
}