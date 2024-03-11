import 'package:flutter/material.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/utils/cache_image_service.dart';

class BlockedUserCard extends StatefulWidget {
  final VoidCallback onUnblock;
  final Map<String, dynamic> user;
  const BlockedUserCard(
      {super.key, required this.onUnblock, required this.user});

  @override
  State<BlockedUserCard> createState() => _BlockedCardSUsertate();
}

class _BlockedCardSUsertate extends State<BlockedUserCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey.shade300)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100), color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: cachedProfilePicture(widget.user["pictureUrl"]),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          widget.user["userName"],
          style: TextStyle(fontSize: 17),
        ),
        const Spacer(),
        SizedBox(
            height: 40,
            child: MaterialButton(
              color: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                widget.onUnblock();
              },
              child: Text(
                "Unblock",
                style: TextStyle(color: Colors.white),
              ),
            ))
      ]),
    );
  }
}
