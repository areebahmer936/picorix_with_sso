// ignore_for_file: unnecessary_overrides

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:picorix/models/message.dart";
import "package:stacked/stacked.dart";

class MessageForwardViewModel extends BaseViewModel {
  MessageForwardViewModel({required this.msgUid, required this.chatRoomId});
  final String msgUid;
  final String chatRoomId;
  late Message originalMsg;
  bool isLoading = true;
  bool isForwarding = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List chats = [];
  List allChats = [];
  List toForward = [];
  String? uid;
  Map<String, dynamic>? userData;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future getChats() async {
    uid = auth.currentUser!.uid;

    originalMsg = await firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(msgUid)
        .get()
        .then((value) => Message.fromJson(value.data()!));

    userData = await firestore
        .collection("users")
        .doc(uid)
        .get()
        .then((value) => value.data()!);

    final documents = (await firestore
            .collection("chatRooms")
            .orderBy("lastMessageTime", descending: true)
            .where("users", arrayContains: uid)
            .get())
        .docs;

    for (var doc in documents) {
      Map<String, dynamic> data = doc.data();
      String name = "";
      String subline = "";
      String pictureUrl = "";
      String type = "";
      String chatRoomId = doc.id;
      if (data['type'] == "group") {
        name = data["groupInfo"]["groupName"];
        subline = "group";
        pictureUrl = data["groupInfo"]["pictureUrl"];
        type = "group";
      } else {
        final userData = await getUserData(data["users"]);
        name = userData["userName"];
        subline = "Class: ${userData["classInfo"]}";
        pictureUrl = userData["profilePictureUrl"];
        type = "duo";
      }
      allChats.add({
        "chatRoomId": chatRoomId,
        "name": name,
        "subline": subline,
        "pictureUrl": pictureUrl,
        "type": type
      });
    }
    chats = allChats;
    print(chats);
    print(originalMsg.content);
  }

  addToForward(uid) {
    if (toForward.contains(uid)) {
      toForward.remove(uid);
    } else {
      toForward.add(uid);
    }
    print(toForward);
  }

  showAvailableUsers(String searchTerm) async {
    print(searchTerm);
    searchTerm = searchTerm.toLowerCase();
    chats = [];
    List matchingUsers = [];

    for (var chat in allChats) {
      String chatRoomName = chat['name'].toString().toLowerCase();
      if (searchTerm.length == 1) {
        // Only include users whose names start with the search term
        if (chatRoomName.startsWith(searchTerm)) {
          print("first character matches");
          matchingUsers.add({
            "chatRoomId": chat["chatRoomId"],
            "name": chat["name"],
            "subline": chat["subline"],
            "pictureUrl": chat["pictureUrl"],
            "type": chat["type"]
          });
        }
      } else if (chatRoomName.contains(searchTerm)) {
        matchingUsers.add({
          "chatRoomId": chat["chatRoomId"],
          "name": chat["name"],
          "subline": chat["subline"],
          "pictureUrl": chat["pictureUrl"],
          "type": chat["type"]
        });
      }
    }
    chats = matchingUsers;
    notifyListeners();
  }

  forward(context) async {
    isForwarding = true;
    notifyListeners();
    final time = DateTime.now();
    if (toForward.isEmpty) {
      Navigator.pop(context);
    } else {
      for (var i in toForward) {
        final chatRoomData = await firestore
            .collection("chatRooms")
            .doc(i)
            .get()
            .then((value) => value.data()!);
        Message msg = Message(
            userName: userData!["userName"],
            userUid: uid!,
            content: originalMsg.content,
            type: originalMsg.type,
            isForwarded: true,
            timeStamp: time,
            seenBy: [],
            reactions: {},
            previousSenderUid: chatRoomData["lastSenderUid"]);
        firestore
            .collection("chatRooms")
            .doc(i)
            .collection("chats")
            .add(msg.toJson());
        firestore.collection("chatRooms").doc(i).update({
          "lastMessage":
              "${userData!['userName']} forwarded a ${originalMsg.type}.",
          "lastMessageTime": time.toUtc().toIso8601String(),
          "lastSenderUid": userData!['uid']
        });

        Map<String, dynamic> unreadCounts = await firestore
            .collection('chatRooms')
            .doc(i)
            .get()
            .then((value) => value.data()!["unreadCounts"]);
        unreadCounts.forEach((key, value) {
          if (key != uid) {
            unreadCounts[key] += 1;
          }
        });
        await firestore
            .collection('chatRooms')
            .doc(i)
            .update({'unreadCounts': unreadCounts});
      }
      Navigator.pop(context);
    }
  }

  Future getUserData(users) async {
    final document = await FirebaseFirestore.instance
        .collection("users")
        .doc(users[0] == uid ? users[1] : users[0])
        .get();
    return document.data()!;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
