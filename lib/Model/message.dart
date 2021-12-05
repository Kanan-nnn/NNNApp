import 'dart:async';
import 'dart:convert';
import "dart:math";

import 'package:http/http.dart' as http;

// API ops for https://foaas.com/
var urlListFn = (from, name) => [
      'back/$name/$from',
      'anyway/$name/$from',
      'bag/$from',
      'because/$from',
      'blackadder/$name/$from',
      'bucket/$from',
      'cocksplat/$name/$from',
      'cup/$from',
      'deraadt/$name/$from',
      'donut/$name/$from',
      'dumbledore/$from',
      'family/$from',
      'fascinating/$from',
      'fewer/$name/$from',
      'gfy/$name/$from',
      'keep/$name/$from',
      'king/$name/$from',
      'linus/$name/$from',
      'nugget/$name/$from',
      'shakespeare/$name/$from'
    ];

Future<Message> fetchMessage(String from, String name) async {
  final _random = new Random();
  var urlList = urlListFn(from, name);
  var url = urlList[_random.nextInt(urlList.length)];
  print(url);
  final response = await http.get(Uri.parse('https://foaas.com/$url'),
      headers: {'Accept': 'application/json'});

  if (response.statusCode == 200) {
    return Message.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load Message');
  }
}

class Message {
  final String message;
  final String subtitle;

  Message({
    required this.message,
    required this.subtitle,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'],
      subtitle: json['subtitle'],
    );
  }
}
