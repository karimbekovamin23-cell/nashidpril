import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/nasheed.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._();
  factory PlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  Nasheed? _currentNasheed;
  List<Nasheed> _queue = [];
  int _queueIndex = 0;

  PlayerService._();

  AudioPlayer get player => _player;
  Nasheed? get currentNasheed => _currentNasheed;
  List<Nasheed> get queue => _queue;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<bool> get playingStream => _player.playingStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> playNasheed(Nasheed nasheed, {List<Nasheed>? queue}) async {
    _currentNasheed = nasheed;
    if (queue != null) {
      _queue = queue;
      _queueIndex = queue.indexOf(nasheed);
    }

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(nasheed.audioUrl),
        tag: MediaItem(
          id: nasheed.id,
          title: nasheed.title,
          artist: nasheed.artist?.name ?? 'Unknown',
          artUri: nasheed.coverUrl != null ? Uri.parse(nasheed.coverUrl!) : null,
        ),
      ),
    );
    await _player.play();
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToNext() async {
    if (_queueIndex < _queue.length - 1) {
      _queueIndex++;
      await playNasheed(_queue[_queueIndex], queue: _queue);
    }
  }

  Future<void> seekToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_queueIndex > 0) {
      _queueIndex--;
      await playNasheed(_queue[_queueIndex], queue: _queue);
    }
  }

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);
  Future<void> setShuffleMode(bool enabled) => _player.setShuffleModeEnabled(enabled);

  Future<void> stop() async {
    await _player.stop();
    _currentNasheed = null;
  }

  void dispose() => _player.dispose();
}
