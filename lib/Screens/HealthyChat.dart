import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:nnn_app/Model/message.dart' as msg;
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';

class HealthyChat extends StatefulWidget {
  @override
  _HealthyChatState createState() => _HealthyChatState();
}

class _HealthyChatState extends State<HealthyChat> {
  List<types.Message> _messages = [];
  final _god = const types.User(
      id: 'God',
      firstName: 'God 😇',
      imageUrl:
          'https://stat1.bollywoodhungama.in/wp-content/uploads/2016/03/50344498.jpg');
  var _me = const types.User(id: 'Kanan & Manek', firstName: 'Kanan & Manek');
  var _hatee = const types.User(id: 'Spotify', firstName: 'Spotify');
  var _recipient = const types.User(id: 'Gorboroth', firstName: 'Gorboroth');
  late Future<msg.Message> futureMessage;
  String hatee = 'Spotify';
  String me = 'Kanan & Manek';
  String recipient = 'Gorboroth';
  String dropdownValue = 'Hater';
  bool isHaterMode = true;
  var lReplies = [
    {'text': 'It is cold', 'author': 'user', 'type': 'image'},
    {'text': 'https://www.youtube.com/watch?v=uGwH-x4VoH8', 'author': 'user'},
    {
      'text': ''' Accept it: You've been ghosted . 
Following links "might" help: 
    https://youtu.be/OGbY8zFnfow
    https://youtu.be/KmYi1s5wByQ
Baaki khud dhundhle...
      ''',
      'author': 'god'
    },
    {
      'text':
          '''Seems like you are either jobless or desperate. In the former case,following links might help
  https://chroniclingamerica.loc.gov/lccn/sn82016413/1903-01-24/ed-1/seq-6/image_681x648_from_795,912_to_1603,1681.jpg
  https://i2.wp.com/dubaiunveiled.com/wp-content/uploads/2012/09/houseboy-ad.jpg
In the latter case, Khali haath aaye the tum khaali haath jaoge
    ''',
      'author': 'god'
    }
  ];
  var hReplies = [
    {
      'text':
          '''Seems like you are either jobless or have some serious anger issues. In case of both, you are a perfect candidate for some political party's IT Cell.''',
      'author': 'god'
    }
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => showMyDialog(context));
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _reply(message) async {
    final text = message['text'];
    final author = (message['author'] == 'god' ? _god : _recipient);
    if (message['type'] == 'image') {
      final message = types.ImageMessage(
        author: author,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: 427,
        id: const Uuid().v4(),
        name: '',
        size: 22856,
        uri:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Left_shoulder.jpg/640px-Left_shoulder.jpg',
        width: 640,
      );
      _addMessage(message);
    } else {
      final textMessage = types.TextMessage(
          author: author,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: text,
          roomId: _me.firstName);

      _addMessage(textMessage);
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    msg.Message m = isHaterMode
        ? await msg.fetchMessage(me, hatee)
        : msg.Message(message: message.text, subtitle: '');
    final text = m.message;
    final textMessage = types.TextMessage(
        author: _me,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: text);

    _addMessage(textMessage);
    if (!isHaterMode && (_messages.length % 3 == 0) && lReplies.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _reply(lReplies.removeAt(0));
        // sendReply = r.nextDouble() <= 0.2;
      });
    }
    if (isHaterMode && _messages.length > 10 && hReplies.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        _reply(hReplies.removeAt(0));
        // sendReply = r.nextDouble() <= 0.2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.HEALTHY_CHAT),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _me,
          showUserNames: true,
          showUserAvatars: true,
        ),
      ),
    );
  }

  void showMyDialog(BuildContext context) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 300,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Mode',
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.pink.shade300)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                          value: dropdownValue,
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                              isHaterMode = newValue == 'Hater';
                            });
                          },
                          items: <String>['Hater', 'Lover']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.pink.shade300)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(color: Colors.black),
                          labelText: 'Your Name',
                          hintText: 'Kanan & Manek'),
                      onChanged: (value) => {
                        setState(() {
                          me = value;
                          _me = types.User(id: value, firstName: value);
                        })
                      },
                    ),
                    SizedBox(height: 15),
                    isHaterMode
                        ? TextFormField(
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pink.shade300)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: "Enemy's name",
                                hintText: 'Spotify'),
                            onChanged: (value) => {
                              setState(() {
                                hatee = value;
                                _hatee =
                                    types.User(id: value, firstName: value);
                              })
                            },
                          )
                        : TextFormField(
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.pink.shade300)),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                labelStyle: TextStyle(color: Colors.black),
                                labelText: "Recipient's Name",
                                hintText: 'Gorboroth'),
                            onChanged: (value) => {
                              setState(() {
                                recipient = value;
                                _recipient =
                                    types.User(id: value, firstName: value);
                              })
                            },
                          ),
                    SizedBox(height: 20),
                    Text(
                      'Hint: ${(isHaterMode ? 'Type anything and just send.Your true feelings will be conveyed' : 'Be Desperate. Send atleast 3 messages to get a response.')}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 150,
                        height: 40,
                        alignment: Alignment.center,
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.pink.shade300,
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}
