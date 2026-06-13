import 'package:audioplayers/audioplayers.dart';
import '../constants/focus_ambient_sounds.dart';

class FocusAmbientPlayer {
  final AudioPlayer _player = AudioPlayer();
  String? _activeSoundId;

  Future<void> play(String? soundId, int volume) async {
    if (soundId == null || soundId.isEmpty) {
      await stop();
      return;
    }

    if (_activeSoundId == soundId) {
      await _player.setVolume(volume / 100);
      return;
    }

    final sound = FocusAmbientSounds.byId(soundId);
    final url = sound?.url;
    if (url == null) {
      await stop();
      return;
    }

    await stop();
    _activeSoundId = soundId;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(volume / 100);
    await _player.play(UrlSource(url));
  }

  Future<void> setVolume(int volume) async {
    await _player.setVolume(volume / 100);
  }

  Future<void> stop() async {
    _activeSoundId = null;
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
