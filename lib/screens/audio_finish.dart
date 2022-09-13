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
  List<Audio> audioList = [];
  double speed = 1;
  bool volumeOn = true;
  bool loop = false;

  @override
  void initState() {
    super.initState();
    setupPlaylist();
  }

  void setupPlaylist() async {
    var audioInformation = await FirebaseFirestore.instance
        .collection('audios')
        .orderBy('title')
        .get();

    setState(() {
      for (var element in audioInformation.docs) {
        audioList.add(Audio.network(element['path'],
            metas: Metas(title: element['title'], artist: element['artist'])));
      }
    });
    print('for ali');
    print(audioList);
    audioPlayer.open(Playlist(audios: audioList),
        autoStart: false, loopMode: LoopMode.playlist);
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
          itemCount: audioList.length,
          itemBuilder: (context, index) {
            return playlistItem(index);
          }),
    );
  }

  Widget playlistItem(int index) {
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
                      audioList[index].metas.title.toString(),
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Barlow'),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      audioList[index].metas.artist.toString(),
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

  String transformString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString'; // Returns a string with the format mm:ss
  }

  Widget getTimeText(Duration seconds) {
    return Text(
      transformString(seconds.inSeconds),
      style: TextStyle(color: Colors.white),
    );
  }

  // slider to make seek
  Widget slider(RealtimePlayingInfos realtimePlayingInfos) {
    return SliderTheme(
        data: SliderThemeData(
            thumbColor: Colors.amber,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 1),
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey[800],
            overlayColor: Colors.transparent),
        child: Slider.adaptive(
            value: realtimePlayingInfos.currentPosition.inSeconds.toDouble(),
            max: realtimePlayingInfos.duration.inSeconds.toDouble(),
            min: 0,
            mouseCursor: MouseCursor.uncontrolled,
            autofocus: true,
            onChanged: (value) {
              audioPlayer.seek(Duration(seconds: value.toInt()));
            }));
  }
// start speed function
  playSpeed(speed) async {
    await audioPlayer.setPlaySpeed(speed);
  }

  // start progress line time
  Widget nextBackValueSpeedLoop() {
    return Row(
      children: [
        // start Lopp
        IconButton(
            onPressed: () {
              setState(() {
                loop = !loop;
                loop ? audioPlayer.setLoopMode(LoopMode.single) : null;
              });
            },
            icon: loop
                ? const Icon(
                    Icons.loop,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.loop,
                    color: Colors.white,
                  )),
        // start volume
        Column(
      children: [
        Text('volume'),
        IconButton(
            onPressed: () {
              setState(() {
                volumeOn = !volumeOn;
                volumeOn
                    ? audioPlayer.setVolume(1.0)
                    : audioPlayer.setVolume(0.0);
              });
            },
            icon: volumeOn ? Icon(Icons.volume_mute) : Icon(Icons.volume_off)),
      ],
    ),
        // Start previous
        IconButton(
            onPressed: () async {
              await audioPlayer.previous();
            },
            icon: const Icon(Icons.skip_previous)),
        // start next
        IconButton(
            onPressed: () async {
              await audioPlayer.next();
            },
            icon: const Icon(Icons.next_plan)),
        // Start speed
        Column(
          children: [
            Text(double.parse((speed).toStringAsFixed(2)).toString()),
            IconButton(
                onPressed: () {
                  setState(() {
                    speed += 0.1;
                    playSpeed(speed);
                  });
                },
                icon: const Icon(Icons.speed)),
          ],
        ),
      ],
    );
  }

  Widget audioPlayerUI(RealtimePlayingInfos realtimePlayingInfos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getTimeText(realtimePlayingInfos.currentPosition),
        // linearProgressBar(realtimePlayingInfos.currentPosition,
        //     realtimePlayingInfos.duration),
        slider(realtimePlayingInfos),
        getTimeText(realtimePlayingInfos.duration)
      ],
    );
  }

  Widget bottomPlayContainer(RealtimePlayingInfos realtimePlayingInfos) {
    return DraggableScrollableSheet(
        initialChildSize: 0.3,
        minChildSize: 0.2,
        maxChildSize: 0.99,
        builder: (BuildContext context, ScrollController scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              Container(
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
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
                      //       realtimePlayingInfos.current!.audio.audio.metas.image!.path.toString(),
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              realtimePlayingInfos
                                  .current!.audio.audio.metas.title
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: mainColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Barlow'),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              realtimePlayingInfos
                                  .current!.audio.audio.metas.artist
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: mainColor,
                                  fontFamily: 'Barlow'),
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
              ),
              audioPlayerUI(realtimePlayingInfos),
              nextBackValueSpeedLoop(),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: mainColor,
        body: audioPlayer.builderRealtimePlayingInfos(
            builder: (context, realtimePlayingInfos) {
          if (realtimePlayingInfos != null) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    //playlistImage(),
                    SizedBox(height: screenHeight * 0.02),
                    playlistTitle(),
                    SizedBox(height: screenHeight * 0.02),
                    playButton(),
                    SizedBox(height: screenHeight * 0.02),
                    playlist(realtimePlayingInfos),
                  ],
                ),
                bottomPlayContainer(realtimePlayingInfos),
              ],
            );
          } else {
            return Column();
          }
        }));
  }
}
