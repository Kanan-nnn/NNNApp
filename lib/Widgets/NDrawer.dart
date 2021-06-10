import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:nnn_app/Screens/HealthySocialMedia.dart';
import 'package:nnn_app/Screens/friendship_screen.dart';
import 'package:nnn_app/Screens/podcast_select_screen.dart';

import '../Screens/NotesPage.dart';
import '../Screens/PowerOnPage.dart';
import '../Screens/ThoughtFTT.dart';

// ignore: must_be_immutable
class NDrawer extends StatelessWidget {
  var currentPage = 0;
  static final NOTES_PAGE = 2;
  static final PODCAST_PAGE = 1;
  static final TFTT = 3;
  static final HEALTHY_SOCIAL_MEDIA = 4;
  static final PODCAST_SELECT = 5;
  static final FRIENDSHIP = 6;

  NDrawer(this.currentPage);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Image.asset("images/NNNLogo.png"),
              decoration: BoxDecoration(
                  // color: Colors.red[200],
                  ),
            ),
            ListTile(
              selected: currentPage == PODCAST_SELECT,
              leading: Icon(Icons.restaurant_outlined),
              title: Text('Podcast Select'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PodcastSelect()));
              },
            ),
            ListTile(
              selected: currentPage == NOTES_PAGE,
              leading: Icon(Icons.sticky_note_2_outlined),
              title: Text('Notes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesPage()),
                );
              },
            ),
            ListTile(
              selected: currentPage == TFTT,
              leading: Icon(Icons.anchor_sharp),
              title: Text('Thought For The Day'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThoughtFTT()),
                );
              },
            ),
            ListTile(
              selected: currentPage == HEALTHY_SOCIAL_MEDIA,
              leading: Icon(Icons.healing),
              title: Text('Healthy Social Media'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthySocialMedia()),
                );
              },
            ),
            ListTile(
              selected: currentPage == FRIENDSHIP,
              leading: Icon(Icons.ballot_outlined),
              title: Text('FriendShip'),
              onTap: () {
                AudioService.pause();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => FriendshipScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new_sharp),
              title: Text('Shutdown'),
              onTap: () {
                AudioService.pause();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PowerOnPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
