import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class AudioPlayerDragablesheet extends StatefulWidget {
  const AudioPlayerDragablesheet({Key? key}) : super(key: key);

  @override
  State<AudioPlayerDragablesheet> createState() =>
      _AudioPlayerDragablesheetState();
}

class _AudioPlayerDragablesheetState extends State<AudioPlayerDragablesheet> {
  final AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();
  List informationsss = [
    {'path': '', 'title': '', 'artist': ''},
  ];

  int myIndex = 0;

  setupPlaylist(myIndex) async {
    audioPlayer.open(
        Playlist(audios: [
          Audio.network(
            informationsss[myIndex]['path'],
            // metas: Metas(
            //     title: informationsss[myIndex]['title'],
            //     artist: informationsss[myIndex]['artist'])
          )
        ]),
        showNotification: true,
        autoStart: true,
        loopMode: LoopMode.playlist);
  }

  playMusic() async {
    await audioPlayer.play();
  }

  pauseMusic() async {
    await audioPlayer.pause();
  }

  skipPrevious() async {
    await audioPlayer.previous();
  }

  skipNext() async {
    await audioPlayer.next();
  }

  addAudio() async {
    var audioInformation = await FirebaseFirestore.instance
        .collection('audios')
        .orderBy('title')
        .get();
    // informationsss.add(audioInformation);
    setState(() {
      informationsss = audioInformation.docs;
      setupPlaylist(myIndex);
    });
    print(audioInformation.docs);
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
            onChanged: (value) {
              audioPlayer.seek(Duration(seconds: value.toInt()));
            }));
  }
// start progress line time

  Widget audioPlayerUI(RealtimePlayingInfos realtimePlayingInfos) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        getTimeText(realtimePlayingInfos.currentPosition),
        // linearProgressBar(realtimePlayingInfos.currentPosition,
        //     realtimePlayingInfos.duration),
        slider( realtimePlayingInfos),
        getTimeText(realtimePlayingInfos.duration)
      ],
    );
  }
// progress 
  Widget linearProgressBar(Duration currentPosition, Duration duration) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: LinearPercentIndicator(
        width: 250,
        backgroundColor: Colors.grey,
        percent: currentPosition.inSeconds / duration.inSeconds,
        progressColor: Colors.white,
      ),
    );
  }

  // get Time the audio
    Widget getTimeText(Duration seconds) {
    return Text(
      transformString(seconds.inSeconds),
      style: TextStyle(color: Colors.white),
    );
  }

  String transformString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString'; // Returns a string with the format mm:ss
  }
  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  @override
  void initState() {
    super.initState();
    // setupPlaylist(myIndex);

    addAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      height: 700,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 70,
            //bottom: 150,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child:
                  audioPlayer.builderIsPlaying(builder: (context, isPlaying) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(informationsss[myIndex]['title']),
                    Text(informationsss[myIndex]['artist']),
                    IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.skip_previous_rounded),
                        onPressed: () {
                          (myIndex == 0)
                              ? setState(() {
                                  myIndex == 0;
                                  setupPlaylist(myIndex);
                                  skipPrevious();
                                })
                              : setState(() {
                                  myIndex--;
                                  setupPlaylist(myIndex);
                                  skipPrevious();
                                });
                        }),
                    IconButton(
                        iconSize: 50,
                        icon: Icon(isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        onPressed: () =>
                            isPlaying ? pauseMusic() : playMusic()),
                    IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.skip_next_rounded),
                        onPressed: () {
                          myIndex == (informationsss.length - 1)
                              ? setState(() {
                                  myIndex == (informationsss.length - 1);
                                  setupPlaylist(myIndex);
                                  skipNext();
                                  //playMusic();
                                })
                              : setState(() {
                                  myIndex++;
                                  setupPlaylist(myIndex);
                                  skipNext();
                                });
                          //playMusic();
                        })
                  ],
                );
              }),
            ),
          ),
          Positioned(
             top: 140,
            //bottom: 150,
            left: 0,
            right: 0,
            child: audioPlayer.builderRealtimePlayingInfos(
                  builder: (context, realtimePlayingInfos) {
                    if (realtimePlayingInfos != null) {
                      return audioPlayerUI(realtimePlayingInfos);
                    } else {
                      return Column();
                    }
                  }),
          ),
         
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.99,
            builder: (BuildContext context, ScrollController scrollController) {
              return ListView.builder(
                  controller: scrollController,
                  itemCount: informationsss.length,
                  itemBuilder: (BuildContext context, int index) {
                    return audioPlayer.builderIsPlaying(
                        builder: (context, isPlaying) {
                      return ListTile(
                        onTap: () {
                          myIndex = index;

                          setState(() {
                            setupPlaylist(myIndex);
                          });
                          audioPlayer.play();
                        },
                        title: Text(informationsss[index]['title']),
                        subtitle: Text(informationsss[index]['title']),
                      );
                    });
                  });
            },
          )
        ],
      ),
    ));
  }
}
