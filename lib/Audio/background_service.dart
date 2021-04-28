import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class AudioServiceTask extends BackgroundAudioTask {
  final _player = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    //Connecting
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: true,
        processingState: AudioProcessingState.connecting);

    // await _player.setUrl(
    //     "https://mcdn.podbean.com/mf/web/3bhqcs/NNN29_Audio_Levelled.mp3");

    // _player.play();

    //Connected
    AudioServiceBackground.setState(
        controls: [MediaControl.pause, MediaControl.stop],
        playing: false,
        processingState: AudioProcessingState.ready);
  }

  @override
  Future<void> onStop() async {
    await _player.stop();
    // Super call shuts down isolate
    AudioServiceBackground.setState(
        controls: [],
        playing: false,
        processingState: AudioProcessingState.stopped);

    return super.onStop();
  }

  @override
  Future<void> onPause() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.play, MediaControl.rewind],
        playing: false,
        processingState: AudioProcessingState.ready);
    _player.pause();
  }

  @override
  Future<void> onPlay() async {
    AudioServiceBackground.setState(
        controls: [MediaControl.pause],
        playing: true,
        processingState: AudioProcessingState.ready);
    _player.play();
  }

  @override
  Future<void> onPlayMediaItem(MediaItem mediaItem) async {
    AudioServiceBackground.setState(
        controls: [MediaControl.pause],
        playing: true,
        position: Duration.zero,
        processingState: AudioProcessingState.ready);
    AudioServiceBackground.setMediaItem(mediaItem);

    await _player.setUrl(mediaItem.id);

    _player.play();
  }

  @override
  Future<void> onPlayFromMediaId(String mediaId) async {
    await _player.setUrl(mediaId);
    _player.play();
    AudioServiceBackground.setState(
        controls: [MediaControl.pause],
        playing: true,
        position: _player.position,
        processingState: AudioProcessingState.ready);
  }

  @override
  Future<void> onSeekTo(Duration position) async {
    _player.seek(position);
    AudioServiceBackground.setState(
        controls: [MediaControl.pause],
        playing: true,
        position: position,
        processingState: AudioProcessingState.ready);
  }
}
