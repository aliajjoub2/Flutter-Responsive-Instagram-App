// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AudioPlayerBackgroundPlaylist extends StatefulWidget {
  @override
  _AudioPlayerBackgroundPlaylistState createState() =>
      _AudioPlayerBackgroundPlaylistState();
}

class _AudioPlayerBackgroundPlaylistState
    extends State<AudioPlayerBackgroundPlaylist> {
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 500,
                child: ListView.builder(
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
                    })),
            
            Container(
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
          ],
        ),
      ),
    );
  }
}
