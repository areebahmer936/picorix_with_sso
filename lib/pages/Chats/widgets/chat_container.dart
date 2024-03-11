import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/models/message.dart';
import 'package:picorix/pages/Chats/widgets/audio_container.dart';
import 'package:picorix/pages/Chats/widgets/document_container.dart';
import 'package:picorix/pages/Chats/widgets/show_photo.dart';
import 'package:picorix/pages/Chats/widgets/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

chatContainer(
    BuildContext context,
    int user,
    Message msg,
    Function(String reaction) onReact,
    bool borderCurve,
    VoidCallback onDelete,
    externalDirectory,
    chatRoomId,
    {disable = false}) {
  Map<String, int> reactionRender = {};
  msg.reactions.forEach((_, reaction) {
    reactionRender[reaction] = (reactionRender[reaction] ?? 0) + 1;
  });
  var hasReactions = msg.reactions.isNotEmpty;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
    child: Column(
      children: [
        msg.isForwarded
            ? Row(
                mainAxisAlignment:
                    user == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: SvgPicture.asset(
                      "assets/Icons/forward.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade400, BlendMode.srcIn),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(0),
                    height: 20,
                    child: Text(
                      " Forwarded ",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        Align(
            alignment: user == 0 ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment:
                  user == 0 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Wrap(
                  verticalDirection:
                      user == 0 ? VerticalDirection.up : VerticalDirection.down,
                  crossAxisAlignment: user == 0
                      ? WrapCrossAlignment.start
                      : WrapCrossAlignment.end,
                  children: [
                    user == 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              "   ${formatUtcTimeString(msg.timeStamp.toString())}  ",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          )
                        : const SizedBox(),
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(borderCurve
                              ? 17
                              : user == 0
                                  ? 0
                                  : 17),
                          topLeft: Radius.circular(borderCurve
                              ? 17
                              : user == 0
                                  ? 17
                                  : 0),
                          bottomLeft: const Radius.circular(17),
                          bottomRight: const Radius.circular(17)),
                      child: Material(
                        color: user == 0
                            ? const Color(0xff3D4A7A)
                            : Colors.grey.shade100,
                        child: GestureDetector(
                          onLongPress: () {
                            msg.isDeleted || disable
                                ? () {}
                                : showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: user == 0 ? 250 : 200,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Container(
                                              height: user == 0 ? 180 : 120,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          35)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 3.0,
                                                        horizontal: 12),
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          reactionIcon(
                                                              context,
                                                              "like",
                                                              () =>
                                                                  onReact.call(
                                                                      "like")),
                                                          reactionIcon(
                                                              context,
                                                              "heart",
                                                              () =>
                                                                  onReact.call(
                                                                      "heart")),
                                                          reactionIcon(
                                                              context,
                                                              "laugh",
                                                              () =>
                                                                  onReact.call(
                                                                      "laugh")),
                                                          reactionIcon(
                                                              context,
                                                              "sad",
                                                              () => onReact
                                                                  .call("sad")),
                                                          reactionIcon(
                                                              context,
                                                              "shock",
                                                              () =>
                                                                  onReact.call(
                                                                      "shock")),
                                                          reactionIcon(
                                                              context,
                                                              "angry",
                                                              () =>
                                                                  onReact.call(
                                                                      "angry")),
                                                          reactionIcon(
                                                              context,
                                                              "cross",
                                                              () =>
                                                                  onReact.call(
                                                                      "cancel"))
                                                        ]),
                                                  ),
                                                  user == 0
                                                      ? Divider(
                                                          color: Colors
                                                              .grey.shade300,
                                                          endIndent: 10,
                                                          indent: 10,
                                                        )
                                                      : const SizedBox(),
                                                  user == 0
                                                      ? InkWell(
                                                          onTap: () {
                                                            onDelete();
                                                            Navigator.of(
                                                                    context,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop('dialog');
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    7.0),
                                                            child: Text(
                                                                "Delete Message"),
                                                          ),
                                                        )
                                                      : const SizedBox(),

                                                  Divider(
                                                    color: Colors.grey.shade300,
                                                    endIndent: 10,
                                                    indent: 10,
                                                  ),

                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pop('dialog');
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/forwardmessage",
                                                          arguments: {
                                                            "msgUid": msg.id,
                                                            "chatRoomId":
                                                                chatRoomId
                                                          });
                                                    },
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(7.0),
                                                      child: Text(
                                                          "Forward Message"),
                                                    ),
                                                  )

                                                  // const SizedBox(
                                                  //   width: 9,
                                                  // )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                          },
                          child: Container(
                            padding: msg.isDeleted
                                ? const EdgeInsets.only(
                                    right: 15, left: 15, top: 15, bottom: 15)
                                : msg.type == "video"
                                    ? const EdgeInsets.all(3)
                                    : msg.type == "document"
                                        ? const EdgeInsets.only(top: 15)
                                        : msg.type == "audio"
                                            ? const EdgeInsets.all(5)
                                            : const EdgeInsets.only(
                                                right: 15,
                                                left: 15,
                                                top: 15,
                                                bottom: 15),
                            color: Colors.transparent,
                            child: msg.isDeleted
                                ? const Text(
                                    "User has deleted the message",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  )
                                : msg.type == "video"
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: SizedBox(
                                              width: 250,
                                              child: imageMessage(
                                                  msg.content.split(":::")[1],
                                                  user: user,
                                                  height: 150),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          VideoContainer(
                                                              url: msg.content
                                                                  .split(
                                                                      ":::")[0],
                                                              user: user)));
                                            },
                                            child: Hero(
                                              tag:
                                                  'videoHero${DateTime.now().millisecondsSinceEpoch}',
                                              child: SizedBox(
                                                height: 150,
                                                width: 250,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 3, sigmaY: 3),
                                                    child: Center(
                                                      child: Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            color: Colors
                                                                .grey.shade300),
                                                        child: Center(
                                                            child: SvgPicture
                                                                .asset(
                                                          "assets/Icons/play.svg",
                                                          height: 20,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                  Colors.grey
                                                                      .shade600,
                                                                  BlendMode
                                                                      .srcIn),
                                                        )),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : msg.type == "document"
                                        ? DocumentContainer(
                                            key: ValueKey(msg.id),
                                            url: msg.content,
                                            extDir: externalDirectory)
                                        // ?  documentContainer(
                                        // msg.content, externalDirectory)
                                        : msg.type == "image"
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              ShowImage(
                                                                  imageUrl: msg
                                                                      .content)));
                                                },
                                                child: Hero(
                                                    tag:
                                                        'imageHero${DateTime.now().millisecondsSinceEpoch}',
                                                    child: imageMessage(
                                                        msg.content,
                                                        user: user,
                                                        height: 200)))
                                            : msg.type == "audio"
                                                ? AudioWidget(
                                                    user: user,
                                                    uri: msg.content)
                                                : Linkify(
                                                    onOpen: (link) async {
                                                      print(
                                                          "link is tapped ${link.url}");
                                                      if (!await launchUrl(
                                                          Uri.parse(link.url),
                                                          mode: LaunchMode
                                                              .externalApplication)) {
                                                        throw Exception(
                                                            'Could not launch ${link.url}');
                                                      }
                                                    },
                                                    linkStyle: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor: Colors
                                                            .blue.shade200,
                                                        color: user == 0
                                                            ? Colors
                                                                .blue.shade200
                                                            : Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 15),
                                                    text: msg.content,
                                                    style: TextStyle(
                                                        color: user == 0
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 15),
                                                  ),
                            // Text(
                            //     msg.content,
                            //     style: TextStyle(
                            //         color: user == 0
                            //             ? Colors.white
                            //             : Colors.black,
                            //         fontWeight:
                            //             FontWeight.w300,
                            //         fontSize: 15),
                            //   ),
                          ),
                        ),
                      ),
                    ),
                    user == 0
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              "   ${formatUtcTimeString(msg.timeStamp.toString())}  ",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          )
                  ],
                ),
                !hasReactions
                    ? const SizedBox()
                    : const SizedBox(
                        height: 5,
                      ),
                !hasReactions
                    ? const SizedBox()
                    : Align(
                        alignment:
                            user == 0 ? Alignment.topRight : Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          height: 30,
                          constraints: const BoxConstraints(minWidth: 30),
                          decoration: BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(color: grey12, blurRadius: 6)
                              // ],
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey.shade300),
                          child: msg.reactions.length == 1 &&
                                  reactionRender.values.toList()[0] == 1
                              ? SizedBox(
                                  child: SvgPicture.asset(
                                    "assets/Icons/${reactionRender.keys.toList()[0]}.svg",
                                    height: 20,
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: reactionRender.length,
                                  itemBuilder: ((context, index) {
                                    return SizedBox(
                                      child: Row(children: [
                                        SizedBox(
                                          child: SvgPicture.asset(
                                            "assets/Icons/${reactionRender.keys.toList()[index]}.svg",
                                            height: 20,
                                          ),
                                        ),
                                        Text(
                                            " ${reactionRender.values.toList()[index]} ")
                                      ]),
                                    );
                                  })),
                        ),
                      )
              ],
            )),
      ],
    ),
  );
}

reactionIcon(BuildContext context, String icon, VoidCallback reactCall) {
  return Material(
    child: InkWell(
      splashFactory: InkRipple.splashFactory,
      borderRadius: BorderRadius.circular(100),
      enableFeedback: true,
      splashColor: icon == "heart"
          ? Colors.red.withOpacity(0.3)
          : icon == "like"
              ? Colors.blue.withOpacity(0.3)
              : Colors.yellow.withOpacity(0.3),
      highlightColor: Colors.black.withOpacity(0.5),
      onTap: () {
        reactCall();
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Container(
        margin: EdgeInsets.all(icon == "heart" || icon == "like" ? 5 : 0),
        padding: const EdgeInsets.all(5),
        height: MediaQuery.of(context).size.width /
            (icon == "heart" || icon == "like"
                ? 12.5
                : 10), //icon == "heart" || icon == "like" ? 30 : 38,
        width: MediaQuery.of(context).size.width /
            (icon == "heart" || icon == "like"
                ? 12.5
                : 10), //icon == "heart" || icon == "like" ? 30 : 38,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: icon == "heart"
                ? Colors.red
                : icon == "like"
                    ? Colors.blue
                    : Colors.transparent),
        child: Center(
          child: icon == "heart"
              ? SvgPicture.asset(
                  "assets/Icons/heart.svg",
                  height: icon == "heart" || icon == "like" ? 20 : 25,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                )
              : icon == "like"
                  ? SvgPicture.asset(
                      "assets/Icons/like.svg",
                      height: 20,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    )
                  : SvgPicture.asset(
                      "assets/Icons/$icon.svg",
                    ),
        ),
      ),
    ),
  );
}

String formatUtcTimeString(String utcTimeString) {
  // Parse the UTC time string
  DateTime utcDateTime = DateTime.parse(utcTimeString).toLocal();

  // Format the DateTime object to a localized time string
  String formattedTimeString = DateFormat('hh:mm a').format(utcDateTime);

  return formattedTimeString;
}

void showImage(BuildContext context, imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: imageMessage(imageUrl),
        ),
      );
    },
  );
}

imageMessage(snapshotData, {double? height, int user = 0}) {
  return ExtendedImage.network(
    snapshotData,
    fit: BoxFit.cover,
    // enableLoadState: false,
    gaplessPlayback: true,
    height: height ?? double.minPositive,

    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return Center(
            child: CircularProgressIndicator(
              color: user == 0 ? Colors.white : primaryColor,
            ),
          );
        case LoadState.completed:
          return state.completedWidget;
        case LoadState.failed:
          return Center(
              child: SvgPicture.asset(
            "assets/Icons/image.svg",
            colorFilter: ColorFilter.mode(
                user == 0 ? Colors.grey.shade100 : Colors.grey,
                BlendMode.srcIn),
          ));
      }
    },
  );
}
