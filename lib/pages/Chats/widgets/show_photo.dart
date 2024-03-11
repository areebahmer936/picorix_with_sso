import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';

class ShowImage extends StatelessWidget {
  final String imageUrl;
  const ShowImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey.withOpacity(0.3),
          title: const Text(
            "Photo",
            // style: TextStyle(color: Colors.white),
          )),
      body: SafeArea(
        child: Center(
            child: Hero(
          tag: 'imageHero${DateTime.now().millisecondsSinceEpoch}',
          child: imageMessage(imageUrl),
        )),
      ),
    );
  }

  imageMessage(snapshotData) {
    return ExtendedImage.network(
      snapshotData,
      fit: BoxFit.cover,
      // enableLoadState: false,
      gaplessPlayback: true,

      cache: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return SvgPicture.asset("assets/app/userPlaceholder.svg");
        }
      },
    );
  }
}
