import 'package:flutter/material.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:nnn_app/Screens/podcast_play_screen.dart';
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';
import 'package:provider/provider.dart';

class PodcastSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.PODCAST_SELECT),
      bottomSheet: MiniPlayer(),
      body: Container(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        // color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PodcastSelectList(),
          ],
        ),
      ),
    );
  }
}

class PodcastSelectList extends StatelessWidget {
  const PodcastSelectList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // height: 400,
      child: Consumer<PodcastData>(
        builder: (context, podcastProvider, child) {
          return ListView.builder(
              itemCount: podcastProvider.podcastList.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Text("Welcome to the NNN Network",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ));
                }
                if (index == 1) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child:
                          Text("Please select a podcast from the list below.",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              )));
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: PodcastImageTile(
                      podcastProvider.podcastList[index - 2].imageUrl,
                      podcastProvider.podcastList[index - 2].feedLink,
                      podcastProvider.podcastList[index - 2].name),
                );
              });
        },
      ),
    );
  }
}

class PodcastImageTile extends StatelessWidget {
  PodcastImageTile(this.imageUrl, this.podcastLink, this.podcastName);

  final String imageUrl, podcastLink, podcastName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // updateEpisodes();
          Provider.of<PodcastData>(context, listen: false)
              .updateEpisodes(podcastLink);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PodcastUI()),
          );
        },
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.white10,
            child: ListTile(
              leading: Image.network(imageUrl),
              title: Text(
                podcastName,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ));
  }
}
