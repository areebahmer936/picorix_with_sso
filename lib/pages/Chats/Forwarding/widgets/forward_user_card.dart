import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/utils/cache_image_service.dart';

class ForwardUserCard extends StatefulWidget {
  final Map userData;
  final VoidCallback onSelected;
  final bool selected;
  const ForwardUserCard(
      {super.key,
      required this.userData,
      required this.onSelected,
      required this.selected});

  @override
  State<ForwardUserCard> createState() => _ForwardUserCardState();
}

class _ForwardUserCardState extends State<ForwardUserCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool selected = false;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          selected = !selected;
          widget.onSelected();
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: selected
                  ? const Color.fromARGB(255, 230, 244, 255)
                  : Colors.transparent),
          // color: Colors.red,
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child:
                          cachedProfilePicture(widget.userData["pictureUrl"]),
                    ),
                  ),
                  !selected
                      ? const SizedBox()
                      : Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white),
                            child: Center(
                              child: Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: primaryColor),
                                child: Center(
                                  child: SvgPicture.asset(
                                    "assets/Icons/tick.svg",
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                    height: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userData["name"].toString().capitalize(),
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    widget.userData["subline"],
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

extension CapitalizeExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
