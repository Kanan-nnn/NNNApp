import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PodcastData with ChangeNotifier {
  List<MediaItem> _episodes = [];
  List<PodcastItem> _podcasts = [];
  List<String> _thoughts = [];
  Timer? _timer;
  Database? _database;

  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;
  static final friendTable = 'FRIEND';
  static final statisticsTable = 'STATS';
  static final columnId = 'ID';
  static final columnName = 'NAME';
  static final columnPercentage = 'PERCENTAGE';
  static final columnTotalDrowned = 'TOTAL_DROWNED';

  List<Map<String, dynamic>> _allFriends = [];

  int _numberOfFriends = 0;

  int _overflowPercentage = 0;

  int _drownedCount = 0;

  //Getters
  List<MediaItem> get episodes => _episodes;
  List<PodcastItem> get podcastList => _podcasts;
  List<String> get thoughtFtt => _thoughts;
  String get podcastName => podcastName;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await initDatabase();
    return _database!;
  }

  bool get isOverflow => checkOverflow();
  int get overflowPercentage => _overflowPercentage;
  int get numberOfFriends => _numberOfFriends;
  List<Map<String, dynamic>> get allFriends => _allFriends;
  int get drownedCount => _drownedCount;

  loadPodcastsFromFirebase() async {
    await Firebase.initializeApp();

    _podcasts.clear();

    var podcastFromFirebase = FirebaseFirestore.instance.collection('Podcasts');
    await podcastFromFirebase.get().then((value) {
      value.docs.forEach((element) {
        print("${element.data()['name']}  ${element.data()['feed_link']}");
        PodcastItem podcastItem = PodcastItem(element.data()['name'],
            element.data()['feed_link'], element.data()['image_url']);

        _podcasts.add(podcastItem);
      });
    });

    notifyListeners();
  }

  _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  parseRSS(String url) async {
    final client = http.Client();

    var response = await client.get(Uri.parse(url));
    var channel = RssFeed.parse(response.body);

    return channel;
  }

  updateEpisodes(String selectedPodcastUrl) async {
    var _podcast = await parseRSS(selectedPodcastUrl) as RssFeed;

    _episodes.clear();

    //Populate Media Items For Audio Service
    _podcast.items.forEach((currentEpisode) {
      // print("${currentEpisode.title} ${currentEpisode.enclosure?.url} ");
      var mediaItem = MediaItem(
        displayTitle: currentEpisode.title,
        displayDescription: _parseHtmlString(currentEpisode.description!),
        title: currentEpisode.title!,
        album: _podcast.title!,
        id: currentEpisode.enclosure!.url!,
        artUri: Uri.parse(currentEpisode.itunes?.image?.href ?? ""),
        duration: currentEpisode.itunes?.duration ?? Duration(minutes: 0),
      );
      _episodes.add(mediaItem);
      // print("Episodes length : ${_episodes.length}");
    });
    notifyListeners();
  }

  setSleepTimer(int duration) {
    if (_timer != null && _timer!.isActive) _timer!.cancel();
    _timer = Timer(Duration(minutes: duration), () {
      print("this line is printed after $duration");
      if (AudioService.running) AudioService.pause();
    });
  }

  updateOverflowPercentage() async {
    _allFriends = await queryAllRows();

    _allFriends.forEach((element) {
      print(element);
    });
    _numberOfFriends = _allFriends.length;
    Random random = new Random();

    if (_numberOfFriends == 0)
      _overflowPercentage = 0;
    else {
      var lowerLimit = _overflowPercentage;
      _overflowPercentage =
          random.nextInt((_numberOfFriends * 10)) + lowerLimit;
    }
    notifyListeners();
  }

  checkOverflow() {
    print("Overflow $_overflowPercentage");

    Random r = new Random();
    double falseProbability = (100 - _overflowPercentage) / 100;
    return r.nextDouble() > falseProbability;
  }

  //DB Methods
  // this opens the database (and creates it if it doesn't exist)
  initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $friendTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnName TEXT NOT NULL,
            $columnPercentage INTEGER NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $statisticsTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,           
            TOTAL_DROWNED INTEGER NOT NULL
          )
          ''');
  }

  Future createStatsTable() async {
    var db = await database;

    await db.execute('''
          CREATE TABLE $statisticsTable (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,           
            TOTAL_DROWNED INTEGER NOT NULL
          )
          ''');
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    var db = await database;
    return await db.insert(friendTable, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    var db = await database;
    return await db.query(friendTable);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  queryRowCount() async {
    var db = await database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $friendTable'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _database!
        .update(friendTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Updates drowned count, or creates if it doesn't exist
  updateDrownedCount(int numberDrowned) async {
    var db = await database;
    var result = await db.query(statisticsTable);
    if (result.isEmpty) {
      db.insert(statisticsTable, {'$columnTotalDrowned': 1});
      _drownedCount = 1;
    } else {
      _drownedCount = (result.first['$columnTotalDrowned'] as int) + numberDrowned;
      await db.rawQuery(
          'UPDATE $statisticsTable SET $columnTotalDrowned = $_drownedCount');
      
    }
    notifyListeners();
  }

  //Get drowned count
  // getDrownedCount() async {
  //   var db = await database;
  //   var result = await db.rawQuery(
  //       'SELECT $columnTotalDrowned FROM $statisticsTable WHERE $columnId =1');
  //   if (result.isEmpty) return 0;
  //   int drowned = result.first['$columnTotalDrowned'] as int;
  //   return drowned;
  // }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    var db = await database;
    return await db
        .delete(friendTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteAll() async {
    var db = await database;
    return await db.delete(friendTable);
  }
}

class PodcastItem {
  final String name;
  final String feedLink;
  final String imageUrl;

  PodcastItem(this.name, this.feedLink, this.imageUrl);
}
