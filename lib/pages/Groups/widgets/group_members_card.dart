import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picorix/config/themedata.dart';

class GroupMemberCard extends StatefulWidget {
  final VoidCallback manageUser;
  final Map user;
  final bool added;
  final bool? isMember;
  final bool? interact;
  const GroupMemberCard(
      {super.key,
      required this.user,
      required this.added,
      required this.manageUser,
      this.isMember,
      this.interact});

  @override
  State<GroupMemberCard> createState() => _GroupMemberCardState();
}

class _GroupMemberCardState extends State<GroupMemberCard> {
  bool isAdded = false;
  @override
  void initState() {
    isAdded = widget.added;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: InkWell(
        onTap: widget.interact != null && widget.interact == false
            ? () {}
            : () {
                setState(() {
                  isAdded = !isAdded;
                  widget.manageUser();
                });
              },
        onLongPress: () {
          Navigator.pushNamed(context, "/profile",
              arguments: {"uid": widget.user['uid']});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAdded
                ? Color.fromARGB(255, 218, 238, 255)
                : Colors.transparent,
          ),
          width: double.infinity,
          child: Row(children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: profileImage(widget.user['profilePictureUrl']),
                  ),
                ),
                !isAdded
                    ? const SizedBox()
                    : Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                          child: Center(
                              child: Container(
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/Icons/tick.svg",
                                height: 14,
                                colorFilter: ColorFilter.mode(
                                    Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          )),
                        ))
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.user["userName"],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            widget.isMember != null
                ? !widget.isMember!
                    ? Container(
                        height: 30,
                        width: 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(255, 217, 237, 253),
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 109, 161, 204))),
                        child: const Center(
                          child: Text(
                            "Admin",
                            style: TextStyle(
                                color: Color.fromARGB(255, 109, 161, 204),
                                fontSize: 12),
                          ),
                        ),
                      )
                    : const SizedBox()
                : const SizedBox()
          ]),
        ),
      ),
    );
  }
}

profileImage(snapshotData) {
  return ExtendedImage.network(
    snapshotData,
    fit: BoxFit.cover,
    // enableLoadState: false,
    gaplessPlayback: true,

    cache: true,
    loadStateChanged: (ExtendedImageState state) {
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          return SvgPicture.asset("assets/app/userPlaceholder.svg");
        case LoadState.completed:
          return state.completedWidget;
        case LoadState.failed:
          return SvgPicture.asset("assets/app/userPlaceholder.svg");
      }
    },
  );
}
