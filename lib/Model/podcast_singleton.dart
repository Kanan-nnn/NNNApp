// import 'dart:async';

// import 'package:audio_service/audio_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dart_rss/dart_rss.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:html/parser.dart';
// import 'package:http/http.dart' as http;

// class PodcastSingleton {
//   static final PodcastSingleton _instance = PodcastSingleton._internal();
//   final _episodeController = StreamController<List<MediaItem>>.broadcast();
//   final _podcastListController =
//       StreamController<List<PodcastItem>>.broadcast();

//   List<MediaItem> _episodes = [];
//   List<PodcastItem> _podcasts = [];
//   List<String> _thoughts = [];
//   Timer? _timer;

//   //Getters
//   List<MediaItem> get episodes => _episodes;
//   List<PodcastItem> get podcastList => _podcasts;
//   List<String> get thoughtFtt => _thoughts;
//   Stream<List<MediaItem>> get episodeStream => _episodeController.stream;
//   Stream<List<PodcastItem>> get podcastStream => _podcastListController.stream;
//   String get podcastName => podcastName;

//   factory PodcastSingleton() {
//     return _instance;
//   }

//   PodcastSingleton._internal() {
//     print("Singleton created");
//   }

//   closeSinks() {
//     _episodeController.close();
//     _podcastListController.close();
//   }

//   loadThoughtsFromFirebase() async {
//     var thougtsFromFirebase = FirebaseFirestore.instance.collection('Thoughts');
//     await thougtsFromFirebase.get().then((value) {
//       value.docs.forEach((element) {
//         print("${element.data()['thought']}");
//         _thoughts.add(element.data()['thought']);
//       });
//     });
//   }

//   loadPodcastsFromFirebase() async {
//     await Firebase.initializeApp();

//     _podcasts.clear();

//     var podcastFromFirebase = FirebaseFirestore.instance.collection('Podcasts');
//     await podcastFromFirebase.get().then((value) {
//       value.docs.forEach((element) {
//         print("${element.data()['name']}  ${element.data()['feed_link']}");
//         PodcastItem podcastItem = PodcastItem(element.data()['name'],
//             element.data()['feed_link'], element.data()['image_url']);

//         _podcasts.add(podcastItem);
//         // print("podcasts length ${_podcasts.length}");
//       });
//       _podcastListController.sink.add(_podcasts);
//     });

//     await loadThoughtsFromFirebase();
//   }

//   _parseHtmlString(String htmlString) {
//     final document = parse(htmlString);
//     final String parsedString =
//         parse(document.body!.text).documentElement!.text;

//     return parsedString;
//   }

//   parseRSS(String url) async {
//     final client = http.Client();

//     var response = await client.get(Uri.parse(url));
//     var channel = RssFeed.parse(response.body);

//     return channel;
//   }

//   updateEpisodes(String selectedPodcastUrl) async {
//     var _podcast = await parseRSS(selectedPodcastUrl) as RssFeed;

//     _episodes.clear();

//     //Populate Media Items For Audio Service
//     _podcast.items.forEach((currentEpisode) {
//       // print("${currentEpisode.title} ${currentEpisode.enclosure?.url} ");
//       var mediaItem = MediaItem(
//         displayTitle: currentEpisode.title,
//         displayDescription: _parseHtmlString(currentEpisode.description!),
//         title: currentEpisode.title!,
//         album: _podcast.title!,
//         id: currentEpisode.enclosure!.url!,
//         artUri: Uri.parse(currentEpisode.itunes?.image?.href ?? ""),
//         duration: currentEpisode.itunes?.duration ?? Duration(minutes: 0),
//       );
//       _episodes.add(mediaItem);
//       _episodeController.sink.add(_episodes);
//       // print("Episodes length : ${_episodes.length}");
//     });
//   }

//   setSleepTimer(int duration) {
//     if (_timer == null || _timer!.isActive) _timer!.cancel();
//     _timer = Timer(Duration(minutes: duration), () {
//       print("this line is printed after $duration");
//       if (AudioService.running) AudioService.pause();
//     });
//   }
// }

// class PodcastItem {
//   final String name;
//   final String feedLink;
//   final String imageUrl;

//   PodcastItem(this.name, this.feedLink, this.imageUrl);
// }
