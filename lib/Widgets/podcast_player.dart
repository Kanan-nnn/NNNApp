import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

mixin AudioMethodsMixin {
  final AudioHandler _audioHandler = GetIt.instance<AudioHandler>();

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          _audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<PodcastPlayerState> get _podcastPlayerStateStream =>
      Rx.combineLatest2<MediaState, PlaybackState, PodcastPlayerState>(
          _mediaStateStream,
          _audioHandler.playbackState,
          (mediaState, playback) => PodcastPlayerState(mediaState, playback));

  rewind(Duration? currentPosition, int secondsToRewind) {
    if (currentPosition == null) return;
    var totalOffset = (currentPosition.inSeconds - secondsToRewind);
    // print("total offset $totalOffset");
    _audioHandler.seek(Duration(seconds: totalOffset < 0 ? 0 : totalOffset));
  }

  play() => _audioHandler.play();

  stop() => _audioHandler.stop();

  pause() => _audioHandler.pause();

  seek(interval) => _audioHandler.seek(interval);
}

class MiniPlayer extends StatelessWidget with AudioMethodsMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PodcastPlayerState>(
      stream: _podcastPlayerStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          print("Stream has no data");
          return SizedBox(
            height: 0,
          );
        }
        //Current Media Item
        final currentMediaItem = snapshot.data?.mediaState.mediaItem;
        if (currentMediaItem == null)
          return SizedBox(
            height: 0,
          );
        var title = currentMediaItem.title;
        var imageUrl = currentMediaItem.artUri;
        //Current Playback state
        final currentPlaybackState = snapshot.data?.playbackState;
        var playing = currentPlaybackState?.playing ?? false;
        // var processingState = currentPlaybackState?.processingState ??
        // AudioProcessingState.stopped;
        //Current Media State
        final mediaState = snapshot.data?.mediaState;
        return SizedBox(
          height: 150,
          child: Card(
              margin: EdgeInsets.all(10),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(children: [
                  if (imageUrl != null) Image.network(imageUrl.toString()),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Expanded(
                          child: ControlButtons(
                              mediaState: mediaState, playing: playing),
                        ),
                        SeekBar(
                          duration:
                              mediaState?.mediaItem?.duration ?? Duration.zero,
                          position: mediaState?.position ?? Duration.zero,
                          onChangeEnd: (newPosition) {
                            _audioHandler.seek(newPosition);
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
              )),
        );
      },
    );
  }
}

class ControlButtons extends StatelessWidget with AudioMethodsMixin {
  final MediaState? mediaState;
  final bool playing;

  ControlButtons({Key? key, required this.mediaState, required this.playing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: IconButton(
              icon: Icon(
                Icons.replay_5,
                size: 40,
              ),
              onPressed: () {
                rewind(mediaState?.position, 5);
              }),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
              icon: Icon(Icons.replay_10, size: 40),
              onPressed: () {
                rewind(mediaState?.position, 10);
              }),
        ),
        playing
            ? Flexible(
                flex: 1,
                child: IconButton(
                    icon: Icon(Icons.pause, size: 40), onPressed: pause))
            : Flexible(
                flex: 1,
                child: IconButton(
                    icon: Icon(Icons.play_arrow, size: 40), onPressed: play),
              ),
        Flexible(
          flex: 1,
          child: IconButton(
              icon: Icon(Icons.replay_30, size: 40),
              onPressed: () {
                rewind(mediaState?.position, 30);
              }),
        ),
        Flexible(
          flex: 1,
          child: IconButton(
              icon: Icon(Icons.night_shelter, size: 40),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SleepTimerSheet();
                    });
              }),
        ),
      ],
    );
  }
}

class BigPodcastPlayer extends StatelessWidget with AudioMethodsMixin {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PodcastPlayerState>(
      stream: _podcastPlayerStateStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: Text(
            "Choose an epiosde",
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
          ));
        }
        //Current Media Item
        final currentMediaItem = snapshot.data?.mediaState.mediaItem;
        if (currentMediaItem == null) return Container();
        var title = currentMediaItem.title;
        var imageUrl = currentMediaItem.artUri;
        //Current Playback state
        final currentPlaybackState = snapshot.data?.playbackState;
        var playing = currentPlaybackState?.playing ?? false;
        //Current Media State
        final mediaState = snapshot.data?.mediaState;
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (imageUrl != null)
                    Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            SizedBox(child: Image.network(imageUrl.toString())),
                          ],
                        )),
                  // SizedBox(
                  //   width: 5,
                  // ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "NOW PLAYING",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ControlButtons(mediaState: mediaState, playing: playing),
            ),
            SeekBar(
              duration: mediaState?.mediaItem?.duration ?? Duration.zero,
              position: mediaState?.position ?? Duration.zero,
              onChangeEnd: (newPosition) {
                AudioService.seekTo(newPosition);
              },
            ),
          ],
        );
      },
    );
  }
}

class PodcastPlayerState {
  final MediaState mediaState;
  final PlaybackState playbackState;

  PodcastPlayerState(this.mediaState, this.playbackState);
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
        widget.duration.inMilliseconds.toDouble());
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      children: [
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragging = false;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                      .firstMatch("$_remaining")
                      ?.group(1) ??
                  '$_remaining',
              style: Theme.of(context).textTheme.caption),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

class SleepTimerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Colors.red.shade200])),
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          Text("Sleep Timer",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          TextButton(
              onPressed: () {
                setSleepTimer(context, 15);
              },
              child: Text("15 minutes",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
          TextButton(
              onPressed: () {
                setSleepTimer(context, 30);
              },
              child: Text("30 minutes",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
          TextButton(
              onPressed: () {
                setSleepTimer(context, 45);
              },
              child: Text("45 minutes",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
          TextButton(
              onPressed: () {
                setSleepTimer(context, 60);
              },
              child: Text("60 minutes",
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20))),
        ],
      ),
    );
  }

  void setSleepTimer(BuildContext context, int duration) {
    Navigator.pop(context);
    Provider.of<PodcastData>(context, listen: false).setSleepTimer(duration);
  }
}
