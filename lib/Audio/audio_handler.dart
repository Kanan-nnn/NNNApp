import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.myapp.audio',
      androidNotificationChannelName: 'NNN',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  AudioPlayerHandler() {
    _loadEmptyPlaylist();
    // Broadcast that we're loading, and what controls are available.
    playbackState.add(PlaybackState(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.loading,
    ));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());
    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  @override
  Future<void> playMediaItem(MediaItem newMediaItem) async {
    playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause],
        playing: true,
        updatePosition: Duration.zero,
        processingState: AudioProcessingState.ready));

    mediaItem.add(newMediaItem);

    await _player.setUrl(newMediaItem.id);

    _player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
    playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.play],
        playing: false,
        processingState: AudioProcessingState.ready));
    _player.pause();
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause],
        playing: true,
        processingState: AudioProcessingState.ready));
    _player.play();
  }

  @override
  Future<void> seek(Duration position) async {
    _player.seek(position);
    playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.pause],
        playing: true,
        updatePosition: position,
        processingState: AudioProcessingState.ready));
  }

  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
    ));
  }
}
