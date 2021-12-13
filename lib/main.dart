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
      home: PowerOnPage(),
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
