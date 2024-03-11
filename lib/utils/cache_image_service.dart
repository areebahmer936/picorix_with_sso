import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

cachedProfilePicture(snapshotData, {group = false}) {
  return ExtendedImage.network(
    snapshotData,
    fit: BoxFit.cover,
    cache: true,
    cacheMaxAge: const Duration(days: 10),
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return group
              ? Center(
                  child: SvgPicture.asset(
                    "assets/app/groupPlaceholder.svg",
                    height: 50,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                )
              : SvgPicture.asset("assets/app/userPlaceholder.svg");
        case LoadState.completed:
          return state.completedWidget;
        case LoadState.failed:
          return group
              ? Center(
                  child: SvgPicture.asset(
                    "assets/app/groupPlaceholder.svg",
                    height: 50,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                )
              : SvgPicture.asset("assets/app/userPlaceholder.svg");
      }
    },
  );
}
