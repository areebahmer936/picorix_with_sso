import 'package:flutter/material.dart';

imageContainer(int user, context, src) {
  return Align(
    alignment: user == 0 ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(user == 0 ? 15 : 0),
                  topRight: Radius.circular(user == 0 ? 0 : 15))),
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(src),
          ),
        )),
  );
}
