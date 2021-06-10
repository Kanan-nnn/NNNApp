import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/PowerOnPage.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => PodcastData(),
    child: MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      title: 'NNN App',
      //Double check scope of this widget
      home: AudioServiceWidget(child: PowerOnPage()),
      debugShowCheckedModeBanner: false,
      // routes: {
      //   'PowerOnPage': (context) => PowerOnPage(),
      //   'NotesPage': (context) => NotesPage(),
      //   'ThoughtForTheDay': (context) => ThoughtFTT(),
      //   'HealthySocialMedial': (context) => HealthySocialMedia(),
      // },
    ),
  ));
}
