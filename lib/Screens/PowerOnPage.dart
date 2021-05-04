import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:connectivity/connectivity.dart';
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
  final snackBarNoInternet = SnackBar(content: Text('No internet connection'));
  final snackBarLoading = SnackBar(content: Text('Fetching podcast details'));

  @override
  initState() {
    super.initState();
  }

  _init() async {
    // print("initialising");
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    await Provider.of<PodcastData>(context, listen: false)
        .loadPodcastsFromFirebase();

    if (!AudioService.running)
      await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'No New Notifications',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
      );
  }

  isConnectedToInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) return false;
    return true;
  }

  loadPodcastsAndNavigate() async {
    if (!await isConnectedToInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarNoInternet);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(snackBarLoading);
      await _init();
      setState(() {
        powerButtonColor = Colors.greenAccent[400]!;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PodcastSelect()),
      );
    }
  }

  @override
  void dispose() {
    // AudioService.stop();
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
              loadPodcastsAndNavigate();
            },
          ),
        ),
      ),
    );
  }
}
