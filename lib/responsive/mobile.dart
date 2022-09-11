import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../provider/user_provider.dart';
import '../screens/add_post.dart';
import '../screens/audio_dragablescheet.dart';
import '../screens/audio_list.dart';
import '../screens/audio_player.dart';
import '../screens/chatHome.dart';
import '../screens/home.dart';
import '../screens/myProfile.dart';
import '../screens/profile.dart';
import '../screens/search.dart';
import '../shared/colors.dart';

class MobileScerren extends StatefulWidget {
  const MobileScerren({Key? key}) : super(key: key);

  @override
  State<MobileScerren> createState() => _MobileScerrenState();
}

class _MobileScerrenState extends State<MobileScerren> {
  final PageController _pageController = PageController(initialPage: 0);

  int currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     
     
    return Scaffold(
      bottomNavigationBar: CupertinoTabBar(
          backgroundColor: mobileBackgroundColor,
          onTap: (index) {
            // navigate to the tabed page
            _pageController.jumpToPage(index);
            setState(() {
              currentPage = index;
            });

            // print(   "---------------    $index "  );
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: currentPage == 0 ? primaryColor : secondaryColor,
                ),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  color: currentPage == 1 ? primaryColor : secondaryColor,
                ),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add_circle,
                  color: currentPage == 2 ? primaryColor : secondaryColor,
                ),
                label: ""),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat,
                  color: currentPage == 3 ? primaryColor : secondaryColor,
                ),
                label: ""),
            // BottomNavigationBarItem(
            //     icon: Icon(
            //       Icons.person,
            //       color: currentPage == 4 ? primaryColor : secondaryColor,
            //     ),
            //     label: ""),
                BottomNavigationBarItem(
                icon: Icon(
                  Icons.auto_awesome_mosaic_rounded,
                  color: currentPage == 5 ? primaryColor : secondaryColor,
                ),
                label: ""),
          ]),
      body: PageView(
        onPageChanged: (index) {
          print("------- $index");
        },
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          
          Home(),
          Search(),
          AddPost(),
          Chatshome(),
          //MyProfile(),
           //AudioPlayerBackgroundPlaylist(),
          //Episode6PlaylistView(),
          AudioPlayerDragablesheet(),
        ],
      ),
    );
  }
}