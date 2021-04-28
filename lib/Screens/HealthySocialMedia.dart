import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';

class HealthySocialMedia extends StatefulWidget {
  @override
  _HealthySocialMediaState createState() => _HealthySocialMediaState();
}

class _HealthySocialMediaState extends State<HealthySocialMedia> {
  List<HealthyPerson> healthyPeople = HealthyPerson.getPeople();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NAppBar(),
      drawer: NDrawer(NDrawer.HEALTHY_SOCIAL_MEDIA),
      bottomSheet: MiniPlayer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: healthyPeople.length,
              itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          if (!healthyPeople[index].isLiked)
                            healthyPeople[index].isLiked = true;
                          else
                            healthyPeople[index].isLiked = false;
                        });
                      },
                      child: Card(
                        elevation: 10,
                        child: Column(
                          children: [
                            Container(
                              child: Center(
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 100),
                                  opacity: healthyPeople[index].isLiked ? 1 : 0,
                                  child: Icon(
                                    Icons.healing,
                                    size: 100,
                                  ),
                                ),
                              ),
                              height: 400,
                              color: Colors.grey,
                            ),
                            Container(
                              height: 50,
                              color: Colors.blueGrey,
                            ),
                          ],
                        ),
                        // color: Colors.grey,
                      ),
                    ),
                  )),
        ),
      ),
    );
  }
}

class HealthyPerson {
  bool isLiked;

  HealthyPerson(this.isLiked);

  static List<HealthyPerson> getPeople() {
    List<HealthyPerson> healthyPeople = <HealthyPerson>[];
    for (int k = 0; k < 1000; k++) {
      HealthyPerson healthyPerson = HealthyPerson(false);
      healthyPeople.add(healthyPerson);
    }
    return healthyPeople;
  }
}
