import 'package:flutter/material.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';

import '../Widgets/NDrawer.dart';

class NotesPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.NOTES_PAGE),
      bottomSheet: MiniPlayer(),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Container(
          decoration: new BoxDecoration(
              shape: BoxShape.rectangle, color: Colors.yellow[200]),
          child: Center(
            child: TextField(
              style: TextStyle(color: Colors.black),
              maxLines: 100,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'For your NNNotes',
                  hintStyle: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ),
    );
  }
}
