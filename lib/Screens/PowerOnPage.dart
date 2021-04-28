import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:nnn_app/Audio/background_service.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:nnn_app/Screens/podcast_select_screen.dart';
import 'package:audio_session/audio_session.dart';
import 'package:provider/provider.dart';

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioServiceTask());
}

class PowerOnPage extends StatefulWidget {
  @override
  _PowerOnPageState createState() => _PowerOnPageState();
}

class _PowerOnPageState extends State<PowerOnPage> {
  var powerButtonColor = Colors.black;

  @override
  initState() {
    _init();
    super.initState();
  }

  _init() async {
    print("initialising");
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    // PodcastSingleton().loadPodcastsFromFirebase();
    await Provider.of<PodcastData>(context, listen: false)
        .loadPodcastsFromFirebase();

    if (!AudioService.running)
      AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'No New Notifications',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
      );
  }

  @override
  void dispose() {
    AudioService.stop();
    // PodcastSingleton().closeSinks();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey,
        child: Center(
          child: IconButton(
            splashColor: Colors.green,
            iconSize: 100,
            icon: Icon(
              Icons.power_settings_new_sharp,
              color: powerButtonColor,
            ),
            onPressed: () {
              setState(() {
                powerButtonColor = Colors.greenAccent[400]!;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PodcastSelect()),
              );
            },
          ),
        ),
      ),
    );
  }
}
