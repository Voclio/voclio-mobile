import 'dart:math';

class IdGenerator {
  static String generate() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(100000);
    return '$now-$random';
  }
}
