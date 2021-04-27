import 'dart:async';

import 'package:chhabrain_task_songslistener/utils/manageFile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

class PlayMusic extends StatefulWidget {
  static const routeName = "playMusic";
  @override
  _PlayMusicState createState() => _PlayMusicState();
}

enum PlayerState { stopped, playing, paused }

class _PlayMusicState extends State<PlayMusic> {
  ManageFiles _manageFiles = ManageFiles();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play(String url) async {
    await audioPlayer.play(url);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = Duration();
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  bool _isLiked(var args, List likedBy, String userEmail) {
    if (likedBy != null) {
      if (likedBy.contains(userEmail)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    List likedBy = args["likedBy"];
    String userEmail = _firebaseAuth.currentUser.email;
    bool isLike = _isLiked(args, likedBy, userEmail);
    print(args);
    return Scaffold(
      floatingActionButton: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.26),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          child: Icon(
            isLike ? Icons.favorite : Icons.favorite_outline,
            color: Colors.red[700],
            size: 40,
          ),
          onPressed: () {
            bool fav = _isLiked(args, likedBy, userEmail);
            if (fav) {
              likedBy.remove(userEmail);
              _manageFiles.manageFavorite(likedBy, args["id"], false);
              setState(() {
                isLike = false;
              });
            } else {
              if (likedBy == null) {
                likedBy = [];
              }
              likedBy.add(userEmail);
              _manageFiles.manageFavorite(likedBy, args["id"], true);
              setState(() {
                isLike = true;
              });
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      backgroundColor: Colors.black,
      appBar: AppBar(
          automaticallyImplyLeading: true, backgroundColor: Colors.transparent),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.95,
                child: Marquee(
                  text: args["name"],
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 20),
                  blankSpace: 40,
                  velocity: 30,
                ),
              ),
              Container(
                height: 20,
                width: 200,
                child: Marquee(
                  text: "Uploaded By: ${args["uploadedBy"]}",
                  style: GoogleFonts.roboto(color: Colors.white, fontSize: 15),
                  blankSpace: 40,
                  velocity: 40,
                ),
              ),
              Expanded(child: Image.asset("assets/happyMusic.png")),
              Material(
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPlaying && duration == null)
                        Text(
                          "Loading...",
                          style: GoogleFonts.aBeeZee(
                              fontSize: 14, color: Colors.white),
                        ),
                      if (duration != null)
                        Slider(
                            value: position?.inMilliseconds?.toDouble() ?? 0.0,
                            onChanged: (double value) {
                              return audioPlayer
                                  .seek((value / 1000).roundToDouble());
                            },
                            min: 0.0,
                            max: duration.inMilliseconds.toDouble()),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          position != null
                              ? "${positionText ?? ''} / ${durationText ?? ''}"
                              : duration != null
                                  ? durationText
                                  : '',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                      ),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          onPressed: isPlaying
                              ? null
                              : () => play(args["downloadUrl"]),
                          iconSize: 50.0,
                          icon: Icon(Icons.play_arrow),
                          color: Colors.cyan,
                        ),
                        IconButton(
                          onPressed: isPlaying ? () => pause() : null,
                          iconSize: 50.0,
                          icon: Icon(Icons.pause),
                          color: Colors.cyan,
                        ),
                        IconButton(
                          onPressed:
                              isPlaying || isPaused ? () => stop() : null,
                          iconSize: 50.0,
                          icon: Icon(Icons.stop),
                          color: Colors.cyan,
                        ),
                      ]),
                    ],
                  ),
                ),
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
