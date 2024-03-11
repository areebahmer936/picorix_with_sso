import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

class VideoContainer extends StatefulWidget {
  final String url;
  final int user;
  const VideoContainer({super.key, required this.url, required this.user});

  @override
  State<VideoContainer> createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  late VideoPlayerController controller;
  String videoFileName = "";
  String videoFileUrl = "";
  bool playing = false;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          print("video player initialized");
          isLoading = false;
        });
      });
    controller.setLooping(true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.grey.shade400,
        title: Text(
          Uri.parse(widget.url).pathSegments.last.split("/").last,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Center(
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                    playing = false;
                  } else {
                    controller.play();
                    playing = true;
                  }
                });
              },
              child: ClipRRect(
                child: controller.value.isInitialized
                    ? Stack(
                        children: [
                          Hero(
                            tag:
                                'videoHero${DateTime.now().millisecondsSinceEpoch}',
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          ),
                          !playing
                              ? AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.4),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 4, sigmaY: 4),
                                      child: Center(
                                          child: Container(
                                        height: 60,
                                        width: 60,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: Colors.grey.shade200),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/Icons/play.svg",
                                            colorFilter: ColorFilter.mode(
                                                Colors.grey, BlendMode.srcIn),
                                            height: 25,
                                          ),
                                        ),
                                      )),
                                    ),
                                  ),
                                )
                              : const SizedBox()
                        ],
                      )
                    : Container(),
              ),
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
