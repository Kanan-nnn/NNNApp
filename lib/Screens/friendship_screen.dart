import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nnn_app/Model/db_models.dart';
import 'package:nnn_app/Model/podcast_provider.dart';
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class FriendshipScreen extends StatefulWidget {
  @override
  _FriendshipScreenState createState() => _FriendshipScreenState();
}

class _FriendshipScreenState extends State<FriendshipScreen> {
  Artboard? _riveArtboard;
  SMIInput<bool>? friendAdded;
  SMIInput<bool>? friendOverflow;
  SMIInput<bool>? restart;
  final formKey = GlobalKey<FormState>();
  int overflowPercentage = 0;
  bool deathScreen = false;
  StateMachineController? stateMachineController;
  int numberOfFriends = 0;
  List<Map<String, dynamic>> allFriends = [];
  bool toggleAddFriend = true;
  bool shipSunk = false;

  var friendController = TextEditingController();

  double deathScreenOpacity = 0;

  SimpleAnimation? wriggleController;
  SimpleAnimation? _youDiedController;

  Artboard? _wriggleArtboard;
  Artboard? _youDiedArtboard;

  @override
  void initState() {
    super.initState();
    _init();

    rootBundle.load('images/ship.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final riveFile = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = riveFile.mainArtboard;
        stateMachineController =
            StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (stateMachineController != null) {
          artboard.addController(stateMachineController!);
          friendAdded = stateMachineController!.findInput('friendAdded');
          friendOverflow = stateMachineController!.findInput('friendOverflow');
          restart = stateMachineController!.findInput('restart');
          friendOverflow?.value = false;
        }
        setState(() => _riveArtboard = artboard);
      },
    );

    rootBundle.load('images/friendwriggle.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard.instance();

        // Add a controller to play back a known animation on the main/default
        // artboard. We store a reference to it so we can toggle playback.
        artboard
            .addController(wriggleController = SimpleAnimation('Animation 1'));
        setState(() => _wriggleArtboard = artboard);
      },
    );

    rootBundle.load('images/you_died.riv').then(
      (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard.instance();
        // Add a controller to play back a known animation on the main/default
        // artboard. We store a reference to it so we can toggle playback.
        artboard
            .addController(_youDiedController = SimpleAnimation('You Died'));
        setState(() => _youDiedArtboard = artboard);
      },
    );
  }

  _init() async {
    updateOverflowPercentage();
  }

  updateOverflowPercentage() async {
    allFriends = await Provider.of<PodcastData>(this.context, listen: false)
        .queryAllRows();

    allFriends.forEach((element) {
      print(element);
    });
    numberOfFriends = allFriends.length;
    Random random = new Random();
    setState(() {
      if (numberOfFriends == 0)
        overflowPercentage = 0;
      else {
        // print("number of friends $numberOfFriends");
        overflowPercentage =
            random.nextInt((numberOfFriends * 10)) + overflowPercentage;
      }
    });
  }

  isOverflow() {
    print("Overflow $overflowPercentage");

    Random r = new Random();
    double falseProbability = (100 - overflowPercentage) / 100;
    return r.nextDouble() > falseProbability;
  }

  get isPlaying => stateMachineController!.isActive;

  void _toggleWriggle() {
    if (wriggleController == null) {
      return;
    }
    setState(() => wriggleController!.isActive = true);
  }

  void _playYouDied() {
    if (_youDiedController == null) return;
    _youDiedController!.instance!.reset();
    setState(() {
      _youDiedController!.isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.FRIENDSHIP),
      bottomSheet: MiniPlayer(),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: _riveArtboard == null ? SizedBox() : animatedShip(),
            ),
            AnimatedCrossFade(
              crossFadeState: toggleAddFriend
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
              firstChild: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: shipLog(),
                  )),
              secondChild: Align(
                alignment: Alignment.topCenter,
                child: AnimatedCrossFade(
                  crossFadeState: shipSunk
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 500),
                  firstChild: SizedBox(),
                  secondChild: addFriendForm(context),
                ),
              ),
            ),
            Positioned(
              bottom: 180,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedCrossFade(
                  crossFadeState: shipSunk
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 1000),
                  firstChild: totalDrowned(context),
                  secondChild: overloadMessage(),
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: waterDragTarget(context)),
            _youDiedArtboard == null
                ? SizedBox()
                : shipSunk
                    ? youDiedScreen()
                    : SizedBox(),
          ],
        ),
      ),
    );
  }

  DragTarget<int> waterDragTarget(BuildContext context) {
    return DragTarget(
      onAccept: (int object) {
        print("Dropped $object");
        Provider.of<PodcastData>(context, listen: false).delete(object);
        Provider.of<PodcastData>(context, listen: false).updateDrownedCount(1);
        setState(() {
          updateOverflowPercentage();
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          // color: Colors.red,
          height: MediaQuery.of(context).size.height / 2,
        );
      },
    );
  }

  GestureDetector youDiedScreen() {
    return GestureDetector(
      onTap: () {
        if (shipSunk) {
          print("Ship sunk");
          friendOverflow?.value = false;
          restart?.value = true;
          _youDiedController!.isActive = false;
          setState(() {
            shipSunk = false;
          });
        }
      },
      child: SizedBox(
        // height: 350,
        child: Rive(
          fit: BoxFit.cover,
          artboard: _youDiedArtboard!,
        ),
      ),
    );
  }

  Row overloadMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$overflowPercentage %",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
          flex: 3,
          child: Text(
            "Chance that adding this friend\n might overload your ship.",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Row totalDrowned(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${Provider.of<PodcastData>(context).drownedCount}",
          style: TextStyle(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          "Total Friends Drowned.",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Container addFriendForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Form(
            // autovalidateMode: AutovalidateMode.always,
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: friendController,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Enter your friend's name";
                  return null;
                },
                maxLines: 1,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(width: 2, color: Colors.pink.shade400)),
                    hintStyle:
                        TextStyle(color: Colors.pink.shade300, fontSize: 20),
                    hintText: "Enter Friends Name..."),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 20)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(width: 2, color: Colors.grey))),
                  ),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    setState(() {
                      toggleAddFriend = !toggleAddFriend;
                    });
                    // restart?.value = true;
                    // formKey.currentState?.reset();
                    // friendController.clear();
                    // _printAllRows();
                    // Provider.of<PodcastData>(context,
                    //         listen: false)
                    //     .deleteAll();
                  }),
              TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.pink.shade300),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(horizontal: 20)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )),
                  ),
                  child: Text(
                    "ADD FRIEND",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();

                      if (!isOverflow()) {
                        print("No Overflow");

                        friendAdded?.value = true;
                        friendOverflow?.value = false;
                        Provider.of<PodcastData>(context, listen: false).insert(
                            Friend(
                                    name: friendController.text,
                                    percentage: overflowPercentage)
                                .toMap());
                      } else {
                        print("Overflow");
                        friendOverflow?.value = true;
                        friendAdded?.value = true;

                        Provider.of<PodcastData>(context, listen: false)
                            .deleteAll();
                        Provider.of<PodcastData>(context, listen: false)
                            .updateDrownedCount(numberOfFriends);
                        setState(() {
                          shipSunk = true;
                        });
                        _playYouDied();
                      }
                      updateOverflowPercentage();
                      formKey.currentState?.reset();
                      friendController.clear();
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget usageInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "+ Double tap to add a friend",
          style: TextStyle(
              color: Colors.pink.shade400,
              fontSize: 15,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text("- Drag a friend into the water to remove",
            style: TextStyle(
                color: Colors.blue.shade400,
                fontSize: 15,
                fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget shipLog() {
    return numberOfFriends == 0
        ? Column(
            children: [
              SizedBox(
                width: 175,
                child: Image.asset("images/TheFriendship.png"),
              ),
              usageInstructions()
            ],
          )
        : SizedBox(
            height: 150,
            // width: 100,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$numberOfFriends",
                      style: TextStyle(
                          color: Colors.pink.shade400,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      "friends on your ship",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: allFriends.length,
                    itemBuilder: (context, index) {
                      var row = allFriends[index];

                      return SizedBox(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: _wriggleArtboard == null
                              ? SizedBox()
                              : LongPressDraggable<int>(
                                  data: row["ID"],
                                  onDragStarted: () {
                                    _toggleWriggle();
                                  },
                                  feedback: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Rive(
                                        fit: BoxFit.cover,
                                        artboard: _wriggleArtboard!),
                                  ),
                                  child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.pink.shade300),
                                      padding: MaterialStateProperty.all<
                                              EdgeInsetsGeometry>(
                                          EdgeInsets.symmetric(horizontal: 10)),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      )),
                                    ),
                                    child: Text(
                                      "${row["NAME"]}",
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 3,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                usageInstructions(),
              ],
            ),
          );
  }

  GestureDetector animatedShip() {
    return GestureDetector(
      onDoubleTap: () {
        // if (shipSunk) {
        //   print("Ship sunk");
        //   friendOverflow?.value = false;
        //   restart?.value = true;
        // }
        setState(() {
          toggleAddFriend = !toggleAddFriend;
        });
      },
      child: SizedBox(
        // height: 350,
        child: Rive(
          fit: BoxFit.cover,
          artboard: _riveArtboard!,
        ),
      ),
    );
  }

  void _printAllRows() async {
    var allRows = await Provider.of<PodcastData>(this.context, listen: false)
        .queryAllRows();
    allRows.forEach((element) {
      element.forEach((key, value) {
        print("$key  $value");
      });
    });
  }
}
