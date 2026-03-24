class TimeFormatter {
  TimeFormatter._();

  /// Format milliseconds as MM:SS.cc (centiseconds)
  static String format(int? ms) {
    if (ms == null) return '00:00.00';
    final int totalSeconds = ms ~/ 1000;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final int centis = (ms % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centis.toString().padLeft(2, '0')}';
  }
}
