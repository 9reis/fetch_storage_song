import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {super.key, required this.songModel, required this.audioPlayer});
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = Duration();
  Duration _position = Duration();

  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.songModel.uri!),
        ),
      );
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log('Cannot Parse Son g' as num);
    }
    widget.audioPlayer.durationStream.listen((d) {
      _duration = d!;
    });

    widget.audioPlayer.positionStream.listen((p) {
      _position = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 100,
                    child: Icon(
                      Icons.music_note,
                      size: 80,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    widget.songModel.artist.toString() == "<Unknown>"
                        ? '<Unknown Artist>'
                        : widget.songModel.artist.toString(),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.songModel.displayNameWOExt,
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(_position.toString().split('.')[0]),
                      Expanded(
                        child: Slider(
                          min: Duration(milliseconds: 0).inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble(),
                          value: _position.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              changeToSeconds(value.toInt());
                              value = value;
                            });
                          },
                        ),
                      ),
                      Text(_duration.toString().split('.')[0]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: Icon(Icons.skip_previous, size: 40),
                          onPressed: () {}),
                      IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }
                              _isPlaying = !_isPlaying;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.skip_next, size: 40),
                          onPressed: () {}),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }
}
