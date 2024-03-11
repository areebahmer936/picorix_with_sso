import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/models/app_user.dart';

class UserCard extends StatefulWidget {
  final int unreadCount;
  final AppUser? user;
  final Map? group;
  final bool isOnline;
  final bool isSelected;
  final String lastMessage;
  final String lastMessageTime;
  final VoidCallback onHold;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageTime,
    this.user,
    required this.isSelected,
    required this.unreadCount,
    required this.onHold,
    required this.onDelete,
    required this.onTap,
    this.group,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8.0),
      child: Material(
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          splashFactory: InkRipple.splashFactory,
          splashColor: Colors.blue.withOpacity(0.2),
          enableFeedback: true,
          radius: 300,
          onLongPress: () {
            widget.onHold();
            print(widget.isSelected);

            // setState(() {
            //   isSelected = !isSelected;
            // });
          },
          onTap: () {
            widget.onTap();
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: SizedBox(
                  height: 85,
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height * 0.08,
                          width: size.height * 0.08,
                          child: Stack(
                            children: [
                              Container(
                                height: size.height * 0.08,
                                width: size.height * 0.08,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  color: widget.group == null
                                      ? Colors.white
                                      : Color.fromARGB(255, 3, 37, 67),
                                ),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100)),
                                    child: profileImage(
                                        widget.group == null
                                            ? widget.user!.profilePictureUrl
                                            : widget.group!['pictureUrl'],
                                        group: widget.group == null
                                            ? false
                                            : true)),
                              ),
                              widget.isOnline
                                  ? Align(
                                      alignment: const Alignment(0.9, 0.9),
                                      child: Container(
                                        height: 15,
                                        width: 15,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.green),
                                      ))
                                  : const SizedBox()
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                //width: size.width * 0.65,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.group == null
                                          ? widget.user!.userName
                                          : widget.group!["groupName"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                                    // Column(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: [
                                    //     Text(
                                    //       widget.group == null
                                    //           ? widget.user!.userName
                                    //           : widget.group!["groupName"],
                                    //       style: const TextStyle(
                                    //           fontWeight: FontWeight.w600,
                                    //           fontSize: 18),
                                    //     ),
                                    //     widget.group == null
                                    //         ? Text(
                                    //             " (${widget.user!.classInfo})",
                                    //             style: TextStyle(fontSize: 11),
                                    //           )
                                    //         : SizedBox()
                                    //   ],
                                    // ),
                                    const Spacer(),
                                    Text(
                                      widget.lastMessageTime == ""
                                          ? ""
                                          : formatUtcTimeString(
                                              widget.lastMessageTime),
                                      style:
                                          const TextStyle(color: primaryColor),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 30,
                                        child: Text(widget.lastMessage,
                                            maxLines: 1,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey.shade400),
                                            overflow: TextOverflow.fade),
                                      ),
                                    ),
                                    widget.unreadCount > 0
                                        ? Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Center(
                                                child: Text(
                                              widget.unreadCount.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12),
                                            )),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                ),
              ),
              widget.isSelected
                  ? ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                        child: Container(
                          height: 85,
                          width: size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.blue.shade200.withOpacity(0.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Container(
                                //   height: 40,
                                //   width: 40,
                                //   decoration: BoxDecoration(
                                //       color: Colors.black,
                                //       borderRadius: BorderRadius.circular(15)),
                                //   child: Center(
                                //     child: SvgPicture.asset(
                                //       "assets/Icons/notification.svg",
                                //       colorFilter: const ColorFilter.mode(
                                //           Colors.white, BlendMode.srcIn),
                                //       height: 30,
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => widget.onDelete(),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.red.shade400,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/Icons/delete.svg",
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
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

  profileImage(snapshotData, {group = false}) {
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
}
