import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:picorix/config/themedata.dart';

class AudioWidget extends StatefulWidget {
  final int user;
  final String uri;
  const AudioWidget({super.key, required this.uri, required this.user});

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  late FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  final DefaultCacheManager myCacheManager = DefaultCacheManager();
  bool isPlaying = false;
  late String path;
  late String url;
  late String duration;

  @override
  void initState() {
    _audioPlayer.openPlayer();
    url = widget.uri.split(":::")[0].trim();
    duration = widget.uri.split(":::")[1].trim();
    loadAudioFromUrl(url);

    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AudioWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.uri != widget.uri) {
      // If the 'uri' property has changed, re-initialize the audio player
      _audioPlayer.closePlayer();
      _audioPlayer = FlutterSoundPlayer();
      _audioPlayer.openPlayer();
      loadAudioFromUrl(widget.uri.split(":::")[0].trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            height: 50,
            width: 240,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(width: 8),
              isPlaying
                  ? InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        setState(() {
                          pausePlaying();
                          isPlaying = false;
                        });
                      },
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/Icons/pause.svg",
                            colorFilter: ColorFilter.mode(
                                widget.user == 0 ? Colors.white : primaryColor,
                                BlendMode.srcIn),
                            height: 20,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        setState(() {
                          _audioPlayer.isPaused
                              ? resumePlaying()
                              : startPlaying(path);
                          isPlaying = true;
                        });
                      },
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/Icons/play.svg",
                            colorFilter: ColorFilter.mode(
                                widget.user == 0 ? Colors.white : primaryColor,
                                BlendMode.srcIn),
                            height: 20,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Lottie.asset(
                  widget.user == 0
                      ? "assets/app/audioWhiteLowPadding.json"
                      : "assets/app/audioBlueLowPadding.json",
                  frameRate: FrameRate.max,
                  animate: isPlaying),
              const SizedBox(width: 2),
              Lottie.asset(
                  widget.user == 0
                      ? "assets/app/audioWhiteLowPadding.json"
                      : "assets/app/audioBlueLowPadding.json",
                  frameRate: FrameRate.max,
                  animate: isPlaying)
            ])),
        Positioned(
            right: 12,
            bottom: 4,
            child: Text(
              duration,
              style: TextStyle(
                fontSize: 11,
                color: widget.user == 0 ? Colors.white : primaryColor,
              ),
            ))
      ],
    );
  }

  Future loadAudioFromUrl(String url) async {
    File file = await myCacheManager.getSingleFile(url);

    // Now you can use 'file' for playback, upload, etc.
    print('File loaded from cache or downloaded: ${file.path}');
    path = file.path;
  }

  Future<void> startPlaying(path) async {
    try {
      await _audioPlayer.startPlayer(
          fromURI: path,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() {
              isPlaying = false;
            });
          });
    } catch (e) {
      print('Error starting playback: $e');
    }
  }

  Future<void> resumePlaying() async {
    try {
      await _audioPlayer.resumePlayer();
    } catch (e) {
      print('Error starting playback: $e');
    }
  }

  Future<void> pausePlaying() async {
    try {
      await _audioPlayer.pausePlayer();
    } catch (e) {
      print('Error starting playback: $e');
    }
  }
}
