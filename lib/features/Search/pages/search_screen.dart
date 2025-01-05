import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubetube/cores/widgets/custom_button.dart';
import 'package:tubetube/features/Model/user_model.dart';
import 'package:tubetube/features/Model/video_model.dart';
import 'package:tubetube/features/Provider/search_provider.dart';
import 'package:tubetube/features/Search/widgets/search_channel_tile.dart';
import 'package:tubetube/features/content/Long_video/parts/post.dart';
import 'package:tubetube/features/content/bottom_navigation.dart';
import 'package:tubetube/home_page.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List foundItems = [];

  filterList(String keyWordSelected) async {
    List results = [];
    List<UserModel> users = await ref.watch(allChannelsProvider);
    List<VideoModel> videos = await ref.watch(allVideoProvider);
    final foundChannels = users.where((user) {
      return user.displayName
          .toString()
          .toLowerCase()
          .contains(keyWordSelected);
    }).toList();
    results.addAll(foundChannels);
    final foundVideos = videos.where((video) {
      return video.title.toString().toLowerCase().contains(keyWordSelected);
    }).toList();
    results.addAll(foundVideos);

    setState(() {
      results.shuffle();
      foundItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(
                    height: 50,
                    width: 270,
                    child: TextFormField(
                      onChanged: (value) async {
                        await filterList(value);
                      },
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm ...",
                        border: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xfff2f2f2),
                        contentPadding: EdgeInsets.only(left: 13, bottom: 12),
                        hintStyle: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 39,
                    width: 65,
                    child: CustomButton(
                        iconData: Icons.search, onTap: () {}, haveColor: true),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: foundItems.length,
                  itemBuilder: (context, index) {
                    List<Widget> itemsWidget = [];
                    final selectedItem = foundItems[index];
                    if (selectedItem.type == "video") {
                      itemsWidget.add(Post(video: selectedItem));
                    }
                    if (selectedItem.type == "user") {
                      itemsWidget.add(SearchChannelTile(user: selectedItem));
                    }
                    if (foundItems.isEmpty) {
                      return const SizedBox();
                    }
                    return itemsWidget[0];
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
