import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBottomBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback tapOnAttach;
  final VoidCallback onCamera;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  final VoidCallback messageSend;
  const ChatBottomBar(
      {super.key,
      required this.tapOnAttach,
      required this.controller,
      required this.messageSend,
      required this.onCamera,
      required this.onStartRecording,
      required this.onStopRecording});

  @override
  State<ChatBottomBar> createState() => _ChatBottomBarState();
}

class _ChatBottomBarState extends State<ChatBottomBar> {
  bool typed = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 9, color: Colors.grey.withOpacity(0.5))
      ]),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: size.width * 0.05),
          InkWell(
            onTap: () => widget.tapOnAttach(),
            child: SvgPicture.asset(
              "assets/Icons/attach.svg",
              height: 35,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: chatField(widget.controller)),
          const SizedBox(width: 8),
          typed
              ? InkWell(
                  onTap: () {
                    widget.messageSend();
                    setState(() {
                      typed = false;
                    });
                  },
                  child: SvgPicture.asset("assets/Icons/send.svg"))
              : const SizedBox(),
          typed
              ? const SizedBox()
              : InkWell(
                  onTap: () {
                    widget.onCamera();
                  },
                  child: SvgPicture.asset(
                    "assets/Icons/camera.svg",
                    height: 30,
                  ),
                ),
          const SizedBox(width: 8),
          typed
              ? const SizedBox()
              : GestureDetector(
                  onLongPressStart: (e) {
                    widget.onStartRecording();
                  },
                  onLongPressEnd: (e) {
                    widget.onStopRecording();
                  },
                  child: SvgPicture.asset(
                    "assets/Icons/mic.svg",
                    height: 27,
                  ),
                ),
          SizedBox(width: size.width * 0.05),
        ]),
      ),
    );
  }

  chatField(controller) {
    return Container(
      height: 50,
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
            // suffixIcon: Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: SvgPicture.asset(
            //     "assets/Icons/sticker.svg",
            //     height: 25,
            //   ),
            // ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            isDense: true,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                    style: BorderStyle.none, color: Colors.grey.shade100)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                    style: BorderStyle.none, color: Colors.grey.shade100)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide(
                    style: BorderStyle.none, color: Colors.grey.shade100)),
            filled: true,
            fillColor: Colors.grey.shade100,
            hintText: "Write your message...",
            hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.4),
                fontWeight: FontWeight.w300)),
        onChanged: (value) {
          if (value.isNotEmpty) {
            setState(() {
              typed = true;
              print(value);
            });
          } else {
            setState(() {
              typed = false;
            });
          }
        },
      ),
    );
  }
}
