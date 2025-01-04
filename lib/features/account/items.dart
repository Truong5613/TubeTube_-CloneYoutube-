import 'package:flutter/material.dart';
import 'package:tubetube/cores/widgets/image_item.dart';
import 'package:tubetube/features/channel/my_channel/pages/channel_setting.dart';

class Items extends StatelessWidget {
  const Items({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 9),
          SizedBox(
            height: 31,
            child: ImageItem(
              imageName: "your-data.png",
              itemClicked: () {

              },
              itemText: "Your data in Youtube",
              haveColor: false,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 6, bottom: 6),
            child: Divider(
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(
            height: 33,
            child: ImageItem(
              imageName: "settings.png",
              itemClicked: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyChannelSettings(),
                  ),
                );
              },
              itemText: "Settings",
              haveColor: false,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 35,
            child: ImageItem(
              imageName: "help.png",
              itemClicked: () {},
              itemText: "Help & feedback",
              haveColor: false,
            ),
          ),
        ],
      ),
    );
  }
}