import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/episode_list.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';

class PodcastUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NAppBar(),
        drawer: NDrawer(NDrawer.PODCAST_PAGE),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [BigPodcastPlayer(), Expanded(child: EpisodeList())],
          ),
        ));
  }
}
