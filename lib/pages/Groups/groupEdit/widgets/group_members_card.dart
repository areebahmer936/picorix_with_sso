import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picorix/config/themedata.dart';

class GroupMemberCard extends StatefulWidget {
  final VoidCallback manageUser;
  final Map user;
  final bool added;
  final bool alreadyAdded;
  final VoidCallback removeUser;
  final bool disabled;
  const GroupMemberCard(
      {super.key,
      required this.user,
      required this.added,
      required this.manageUser,
      required this.alreadyAdded,
      required this.removeUser,
      required this.disabled});

  @override
  State<GroupMemberCard> createState() => _GroupMemberCardState();
}

class _GroupMemberCardState extends State<GroupMemberCard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isAdded = false;
  bool isRemoving = false;
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
        onTap: widget.disabled
            ? () {}
            : widget.alreadyAdded
                ? () {}
                : () {
                    setState(() {
                      isAdded = !isAdded;
                      widget.manageUser();
                    });
                  },
        onLongPress: () {
          Navigator.pushNamed(context, "/profile",
              arguments: {"uid": widget.user["uid"]});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isAdded
                ? Color.fromARGB(255, 218, 238, 255)
                : Colors.transparent,
          ),
          height: 60,
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
            widget.alreadyAdded
                ? InkWell(
                    onTap: widget.disabled
                        ? () {}
                        : () {
                            showConfirmationDialog(context);
                          },
                    child: Container(
                      height: 35,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  widget.disabled ? Colors.grey : Colors.red),
                          color: widget.disabled
                              ? Colors.grey.shade200
                              : Color.fromARGB(255, 255, 212, 209)),
                      child: Center(
                        child: isRemoving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  strokeWidth: 2,
                                ))
                            : Text(
                                "Remove",
                                style: TextStyle(
                                    color: widget.disabled
                                        ? Colors.grey
                                        : Colors.red,
                                    fontSize: 11),
                              ),
                      ),
                    ),
                  )
                : const SizedBox()
          ]),
        ),
      ),
    );
  }

  Future<void> showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          title: Text('Confirmation'),
          content: Text('Are you sure you want to Remove?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.removeUser();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
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
