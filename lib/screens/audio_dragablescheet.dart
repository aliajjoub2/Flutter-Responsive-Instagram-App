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


  List <Audio> myAudios = [];

  
  double speed = 1.0;
  bool volumeOn = true;
  bool loop = false;
  setupPlaylist(myIndex) async {
    audioPlayer.open(
      Playlist(audios: myAudios),
      showNotification: true,
      autoStart: true,
      loopMode: LoopMode.playlist
    );
  }

  finished() {
    audioPlayer.playlistFinished.listen((finished) {
     
      print('+++++++++++++++++++ finished');
    });
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

  playSpeed(speed) async {
    await audioPlayer.setPlaySpeed(speed);
  }

  addAudio() async {
    var audioInformation = await FirebaseFirestore.instance
        .collection('audios')
        .orderBy('title')
        .get();

   setState(() {
      for (var element in audioInformation.docs) {
        myAudios.add(Audio.network(
          element['path'], metas: Metas(title: element['title'], artist: element['artist'])
         
        ));
        print('for ali');
        print(myAudios);
      }
   });
    // informationsss.add(audioInformation);
    // setState(() {
    //   informationsss = audioInformation.docs;
    //   setupPlaylist(myIndex);
    // });
    //finished();

    // print(audioInformation.docs);
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
        slider(realtimePlayingInfos),
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

  getplaySpeed() {
    return Column(
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
    );
  }

  getforwardorrewind() {
    return Column(
      children: [
        Text(double.parse((speed).toStringAsFixed(2)).toString()),
        IconButton(
          onPressed: () {
            setState(() {
              speed += 0.4;
              audioPlayer.forwardOrRewind(speed);
            });
          },
          icon: const Icon(Icons.fast_rewind),
        )
      ],
    );
  }

  getPitch() {
    return Column(
      children: [
        Text('pitch'),
        IconButton(
            onPressed: () {
              audioPlayer.setPitch(1.2);
            },
            icon: const Icon(Icons.piano)),
      ],
    );
  }

  getVolume() {
    return Column(
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
    );
  }

  getSingleLoop() {
    return Column(
      children: [
        Text('Loop'),
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
      ],
    );
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
                    // Text(builderIsPlaying.current.audio.audio.metas.title),
                    // Text(informationsss[myIndex]['artist']),
                    IconButton(
                        iconSize: 50,
                        icon: Icon(Icons.skip_previous_rounded),
                        onPressed: () {
                          // (myIndex == 0)
                          //     ? setState(() {
                          //         myIndex == 0;
                          //         setupPlaylist(myIndex);
                          //         skipPrevious();
                          //       })
                          //     : setState(() {
                          //         myIndex--;
                          //         setupPlaylist(myIndex);
                          //         skipPrevious();
                          //       });
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
                          // myIndex == (informationsss.length - 1)
                          //     ? setState(() {
                          //         myIndex == (informationsss.length - 1);
                          //         setupPlaylist(myIndex);
                          //         skipNext();
                          //         //playMusic();
                          //       })
                          //     : setState(() {
                          //         myIndex++;
                          //         setupPlaylist(myIndex);
                          //         skipNext();
                          //       });
                          //playMusic();
                        }),
                    getplaySpeed(),
                    getPitch(),
                    getVolume(),
                    getforwardorrewind(),
                    //getSingleLoop(),
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
                  itemCount: myAudios.length,
                  itemBuilder: (BuildContext context, int index) {
                    return audioPlayer.builderIsPlaying(
                        builder: (context, isPlaying) {
                      return ListTile(
                        onTap: () {
                        
                        },
                        title: Text(myAudios[index].metas.artist.toString()),
                        subtitle: Text(myAudios[index].metas.title.toString()),
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
