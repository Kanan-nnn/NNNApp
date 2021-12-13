import 'package:flutter/material.dart';
import 'package:nnn_app/Widgets/NDrawer.dart';
import 'package:nnn_app/Widgets/nnn_app_bar.dart';
import 'package:nnn_app/Widgets/podcast_player.dart';

class KittyPartyHelper extends StatelessWidget {
  const KittyPartyHelper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NAppBar(),
        drawer: NDrawer(NDrawer.HEALTHY_SOCIAL_MEDIA),
        bottomSheet: MiniPlayer(),
        body: Container(
          child: Column(
            children: [
              MaterialButton(
                child: Text('Kitty Party Helper'),
                onPressed: () {
                  Navigator.pushNamed(context, '/kitty_party_helper');
                },
              ),
            ],
          ),
        ));
  }
}
