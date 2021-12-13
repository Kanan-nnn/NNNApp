import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:provider/provider.dart';

class EpisodeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastData>(
      builder: (context, podcastData, child) {
        // return Container(child: Text("SNAPSHOT DATA IS : ${snapshot.data}"));
        if (podcastData.episodes.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        List<MediaItem> episodes = podcastData.episodes;
        return ListView.builder(
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(4),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: ListTile(
                onTap: () {
                  print(episodes[index].id);
                  GetIt.instance<AudioHandler>().playMediaItem(episodes[index]);
                },
                title: Text(
                  episodes[index].displayTitle!,
                ),
                subtitle: Text(
                  episodes[index].displayDescription!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
          itemCount: episodes.length,
        );
      },
    );
  }
}
