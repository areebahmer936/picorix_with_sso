import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:picorix/config/themedata.dart';

class AudioWidgetLocal extends StatefulWidget {
  final String path;
  final String duration;
  const AudioWidgetLocal(
      {super.key, required this.path, required this.duration});

  @override
  State<AudioWidgetLocal> createState() => _AudioWidgetLocalState();
}

class _AudioWidgetLocalState extends State<AudioWidgetLocal> {
  late FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    audioPlayer.openPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            height: 50,
            width: 240,
            // constraints: BoxConstraints(maxHeight: 50, maxWidth: 180),
            decoration: BoxDecoration(
                color: primaryColor, borderRadius: BorderRadius.circular(15)),
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
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            height: 20,
                          ),
                        ),
                      ),
                    )
                  : InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        setState(() {
                          audioPlayer.isPaused
                              ? resumePlaying()
                              : startPlaying(widget.path);
                          isPlaying = true;
                        });
                      },
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/Icons/play.svg",
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            height: 20,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 10),
              Lottie.asset("assets/app/audioWhiteLowPadding.json",
                  frameRate: FrameRate.max, animate: isPlaying),
              SizedBox(width: 2),
              Lottie.asset("assets/app/audioWhiteLowPadding.json",
                  frameRate: FrameRate.max, animate: isPlaying)
            ])),
        Positioned(
            right: 12,
            bottom: 4,
            child: Text(
              widget.duration,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ))
      ],
    );
  }

  Future<void> startPlaying(path) async {
    try {
      await audioPlayer.startPlayer(
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
      await audioPlayer.resumePlayer();
    } catch (e) {
      print('Error starting playback: $e');
    }
  }

  Future<void> pausePlaying() async {
    try {
      await audioPlayer.pausePlayer();
    } catch (e) {
      print('Error starting playback: $e');
    }
  }
}
