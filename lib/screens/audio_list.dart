import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Episode6PlaylistView extends StatefulWidget {
  @override
  _Episode6PlaylistViewState createState() => _Episode6PlaylistViewState();
}

class _Episode6PlaylistViewState extends State<Episode6PlaylistView> {
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  double screenHeight = 0;
  double screenWidth = 0;
  final Color mainColor = Color(0xff181c27);
  final Color inactiveColor = Color(0xff5d6169);
  List informationsss = [
    {'path': '', 'title': '', 'artist': ''},
  ];
  int index = 0;
  // List<Audio> audioList = [
  //   Audio.network(informationsss[index],
  //       metas: Metas(
  //           title: informationsss[index]['title'],
  //           artist: informationsss[index]['artist'])),

  //  Audio.network(
  //         'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
  //         metas: Metas(
  //             title: 'ali2',
  //             artist: 'loti2')
  //       ),
  //   Audio.network(
  //         'https://firebasestorage.googleapis.com/v0/b/instegram-454c4.appspot.com/o/audios%2FSoundHelix-Song-1.mp3?alt=media&token=aeffaa5b-db7f-490c-8c6b-8f83344d2182',
  //         metas: Metas(
  //             title: 'ali3',
  //             artist: 'loti3')
  //       ),
  //       Audio.network(
  //         'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
  //         metas: Metas(
  //             title: 'ali4',
  //             artist: 'loti4')
  //       ),
  //  Audio.network(
  //         'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
  //         metas: Metas(
  //             title: 'ali5',
  //             artist: 'loti5')
  //       ),
  //   Audio.network(
  //         'https://firebasestorage.googleapis.com/v0/b/instegram-454c4.appspot.com/o/audios%2FSoundHelix-Song-1.mp3?alt=media&token=aeffaa5b-db7f-490c-8c6b-8f83344d2182',
  //         metas: Metas(
  //             title: 'ali6',
  //             artist: 'loti6')
  //       ),
  // ];


  addAudio() async {
    var audioInformation = await FirebaseFirestore.instance
        .collection('audios')
        .orderBy('title')
        .get();
    // informationsss.add(audioInformation);
    setState(() {
      informationsss = audioInformation.docs;
      setupPlaylist(index);
    });
    print(audioInformation.docs);
  }

  setupPlaylist(index) async {
    audioPlayer.open(
        Playlist(audios: [
          Audio.network(
            informationsss[index]['path'],
            // metas: Metas(
            //     title: informationsss[index]['title'],
            //     artist: informationsss[index]['artist'])
          )
        ]),
        autoStart: false,
        loopMode: LoopMode.playlist,
         showNotification: true,);
  }

  Widget playlistImage() {
    return Container(
      height: screenHeight * 0.25,
      width: screenHeight * 0.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.asset(
          'assets/background_circular.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget playlistTitle() {
    return Text(
      'Chill Playlist',
      style: TextStyle(
          fontFamily: 'Barlow',
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold),
    );
  }

  Widget playButton() {
    return Container(
      width: screenWidth * 0.25,
      child: TextButton(
          onPressed: () => audioPlayer.playlistPlayAtIndex(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: mainColor,
              ),
              SizedBox(width: 5),
              Text(
                'Play',
                style: TextStyle(color: mainColor),
              ),
            ],
          ),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              )))),
    );
  }

  Widget playlist(RealtimePlayingInfos realtimePlayingInfos) {
    return Container(
      height: screenHeight * 0.35,
      alignment: Alignment.bottomLeft,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: informationsss.length,
          itemBuilder: (context, index) {
            return playlistItem(index);
          }),
    );
  }

  Widget playlistItem(index) {
    return InkWell(
      onTap: () => audioPlayer.playlistPlayAtIndex(index),
      splashColor: Colors.transparent,
      highlightColor: mainColor,
      child: Container(
        height: screenHeight * 0.07,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: [
              Text(
                '0${index + 1}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Barlow'),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      informationsss[index].title,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Barlow'),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      informationsss[index].artist,
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff5d6169),
                          fontFamily: 'Barlow'),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.menu_rounded,
                color: inactiveColor,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomPlayContainer(RealtimePlayingInfos realtimePlayingInfos) {
    return Container(
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            // Container(
            //   height: screenHeight * 0.08,
            //   width: screenHeight * 0.08,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(20.0),
            //     child: Image.asset(
            //       realtimePlayingInfos.current!.audio.audio.metas.image!.path,
            //       fit: BoxFit.cover,
            //     ),
            //   ),
            // ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    realtimePlayingInfos.current!.audio.audio.metas.title
                        .toString(),
                    style: TextStyle(
                        fontSize: 15,
                        color: mainColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Barlow'),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    realtimePlayingInfos.current!.audio.audio.metas.artist
                        .toString(),
                    style: TextStyle(
                        fontSize: 13, color: mainColor, fontFamily: 'Barlow'),
                  )
                ],
              ),
            ),
            Icon(
              Icons.favorite_outline_rounded,
              color: mainColor,
            ),
            SizedBox(
              width: screenWidth * 0.03,
            ),
            IconButton(
                icon: Icon(realtimePlayingInfos.isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_fill_rounded),
                iconSize: screenHeight * 0.07,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                color: mainColor,
                onPressed: () => audioPlayer.playOrPause())
          ],
        ),
      ),
    );
  }

  /// List of placeholder icon buttons used for the bottom navigation bar
  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: mainColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: inactiveColor,
      iconSize: screenWidth * 0.07,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded), label: 'Library'),
        BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_rounded), label: 'Hotlist')
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    addAudio();
    setupPlaylist(index);
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: mainColor,
        // bottomNavigationBar: Container(
        //   height: screenHeight * 0.1,
        //   color: Colors.white,
        //   child: ClipRRect(
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(20.0),
        //       topRight: Radius.circular(20.0),
        //     ),
        //     child: bottomNavigationBar(),
        //   ),
        // ),
        body: audioPlayer.builderRealtimePlayingInfos(
            builder: (context, realtimePlayingInfos) {
          if (realtimePlayingInfos != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //playlistImage(),
                SizedBox(height: screenHeight * 0.02),
                playlistTitle(),
                SizedBox(height: screenHeight * 0.02),
                playButton(),
                SizedBox(height: screenHeight * 0.02),
                playlist(realtimePlayingInfos),
                bottomPlayContainer(realtimePlayingInfos)
              ],
            );
          } else {
            return Column();
          }
        }));
  }
}
