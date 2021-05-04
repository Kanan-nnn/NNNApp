import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nnn_app/Model/podcast_provider.dart';

import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';
import 'package:provider/provider.dart';

import '../Widgets/NDrawer.dart';

class ThoughtFTT extends StatelessWidget {
  final int min = 0, max = 4;
  final _random = new Random();

  int next(int min, int max) => min + _random.nextInt(max - min);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.TFTT),
      bottomSheet: MiniPlayer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection("Thoughts").get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Text(
                  "No thoughts",
                  style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                );
              List<String> thoughts =
                  snapshot.data!.docs.map((e) => "${e['thought']}").toList();
              if (!snapshot.hasData) return CircularProgressIndicator();
              return Text(
                thoughts[next(0, thoughts.length)],
                style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
              );
            },
          ),
        ),
      ),
    );
  }
}
