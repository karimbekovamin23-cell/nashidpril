import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/nasheed.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';

class PlayerState {
  final Nasheed? nasheed;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final bool isLoading;
  final LoopMode loopMode;
  final bool shuffleEnabled;

  const PlayerState({
    this.nasheed,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration,
    this.isLoading = false,
    this.loopMode = LoopMode.off,
    this.shuffleEnabled = false,
  });

  PlayerState copyWith({
    Nasheed? nasheed,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLoading,
    LoopMode? loopMode,
    bool? shuffleEnabled,
  }) =>
      PlayerState(
        nasheed: nasheed ?? this.nasheed,
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isLoading: isLoading ?? this.isLoading,
        loopMode: loopMode ?? this.loopMode,
        shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      );
}

class PlayerNotifier extends Notifier<PlayerState> {
  late final PlayerService _service = PlayerService();
  int _listenedSeconds = 0;

  @override
  PlayerState build() {
    _service.playerStateStream.listen((ps) {
      state = state.copyWith(
        isPlaying: ps.playing,
        isLoading: ps.processingState == ProcessingState.loading ||
            ps.processingState == ProcessingState.buffering,
      );
    });

    _service.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      _listenedSeconds++;
      if (_listenedSeconds % 30 == 0 && state.nasheed != null) {
        ApiService().recordPlay(state.nasheed!.id, duration: _listenedSeconds);
      }
    });

    _service.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    return const PlayerState();
  }

  Future<void> play(Nasheed nasheed, {List<Nasheed>? queue}) async {
    _listenedSeconds = 0;
    state = state.copyWith(nasheed: nasheed, isLoading: true);
    await _service.playNasheed(nasheed, queue: queue);
  }

  Future<void> togglePlay() => _service.togglePlay();
  Future<void> seek(Duration pos) => _service.seek(pos);
  Future<void> next() => _service.seekToNext();
  Future<void> previous() => _service.seekToPrevious();

  Future<void> toggleLoop() async {
    final next = state.loopMode == LoopMode.off
        ? LoopMode.all
        : state.loopMode == LoopMode.all
            ? LoopMode.one
            : LoopMode.off;
    await _service.setLoopMode(next);
    state = state.copyWith(loopMode: next);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffleEnabled;
    await _service.setShuffleMode(enabled);
    state = state.copyWith(shuffleEnabled: enabled);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, PlayerState>(() => PlayerNotifier());
