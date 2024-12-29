import 'package:flutter/material.dart';
import 'package:tubetube/cores/widgets/flat_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
class UserChannelPage extends StatefulWidget {
  const UserChannelPage({super.key});

  @override
  State<UserChannelPage> createState() => _UserChannelPageState();
}

class _UserChannelPageState extends State<UserChannelPage> {
  bool haveVideos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/images/flutter background.png"),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UserName',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 26),
                        ),
                        const Text(
                          '@UserName',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.blueGrey),
                        ),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.blueGrey),
                            children: [
                              TextSpan(text: "No subcription  "),
                              TextSpan(text: "No videos"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: FlatButton(
                  text: "Đăng Ký", onPressed: () {}, colour: Colors.black),
            ),
            haveVideos
                ? const SizedBox()
                : Center(
                    child: Padding(
                      padding:  EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.2),
                      child:const Text(
                        "Không có Video",
                        style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
