import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:picorix/models/app_user.dart";
import "package:picorix/pages/Chats/chat_view.dart";
import "package:stacked/stacked.dart";

class ProfileViewModel extends BaseViewModel {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? uid;
  final AppUser? user;
  String? myUid = '';
  ProfileViewModel({this.uid, this.user});
  late AppUser profileInfo;
  bool isProcessing = false;
  bool isAdding = false;
  bool isBlocking = false;

  bool isBlocked = false;
  bool isMeBlocked = false;

  String lastOnline = "";
  bool onlineStatus = false;
  bool isLoading = true;
  bool isFriend = false;
  bool isMe = true;
  bool isNavigating = false;
  bool justBlocked = false;

  Future initializeProfile() async {
    myUid = _auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userData;
    if (uid == null) {
      userData = await firestore.collection("users").doc(user!.uid).get();

      profileInfo = AppUser.fromJson(userData.data()!);
      onlineStatus = profileInfo.isOnline;
      String lastSeen = profileInfo.lastOnline;
      lastOnline = formatLastOnline(lastSeen);
    } else {
      userData = await firestore.collection("users").doc(uid).get();
      profileInfo = AppUser.fromJson(userData.data()!);
      onlineStatus = profileInfo.isOnline;
      String lastSeen = profileInfo.lastOnline;
      lastOnline = formatLastOnline(lastSeen);
    }
    final myBlockList = await firestore
        .collection("users")
        .doc(myUid)
        .get()
        .then((value) => value.data()!["blockList"] ?? []);

    if (userData.data()!["blockList"] != null) {
      if (userData.data()!["blockList"].contains(myUid)) {
        isMeBlocked = true;
      }
    } else if (myBlockList.contains(profileInfo.uid)) {
      isBlocked = true;
    }

    isMe = profileInfo.uid == myUid;
    await firestore
        .collection("users")
        .doc(myUid)
        .collection("chatFriends")
        .doc(profileInfo.uid)
        .get()
        .then((value) => value.exists ? isFriend = true : isFriend = false);
    isLoading = false;
    notifyListeners();
  }

  unblockUser() async {
    justBlocked = false;
    isProcessing = true;
    notifyListeners();
    await firestore.collection("users").doc(myUid).update({
      "blockList": FieldValue.arrayRemove([profileInfo.uid])
    });
    isBlocked = false;
    isProcessing = false;
    notifyListeners();
  }

  blockUser(context) async {
    justBlocked = true;
    isProcessing = true;
    notifyListeners();
    await firestore.collection("users").doc(myUid).update({
      "blockList": FieldValue.arrayUnion([profileInfo.uid])
    });
    isBlocked = true;
    isProcessing = false;

    notifyListeners();
  }

  userAdd() async {
    isProcessing = true;
    notifyListeners();
    final time = DateTime.now().toUtc().toIso8601String();
    String uid1 = profileInfo.uid;
    String uid2 = myUid!;
    final chatRoomId = await getChatroomId(uid1, uid2);

    if (chatRoomId == false) {
      await firestore.collection("chatRooms").add({
        "users": [uid1, uid2],
        "type": "duo",
        "lastMessage": "Hi! Tap to start chatting",
        "lastMessageTime": DateTime.now().toUtc().toIso8601String(),
        "lastSenderUid": "",
        "unreadCounts": {uid1: 0, uid2: 0},
        "isViewing": {
          uid1: [false, time],
          uid2: [false, time]
        },
        "areFriends": true,
        "archiveFor": {},
        "groupInfo": {}
      });
    } else {
      await firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .update({"areFriends": true});
    }

    await firestore
        .collection("users")
        .doc(uid1)
        .collection("chatFriends")
        .doc(uid2)
        .set({});
    await firestore
        .collection("users")
        .doc(uid2)
        .collection("chatFriends")
        .doc(uid1)
        .set({});

    isFriend = true;
    isProcessing = false;
    notifyListeners();
  }

  navigateToChat(context) async {
    isProcessing = true;
    notifyListeners();

    final currentChatRoomId = await getChatroomId(myUid, profileInfo.uid);
    print("my uid: $myUid and other uid: ${profileInfo.uid}");
    print(currentChatRoomId);

    final docData = await firestore
        .collection("chatRooms")
        .doc(currentChatRoomId)
        .get()
        .then((value) => value.data()!);
    String? archiveTime;
    if (docData["archiveFor"].containsKey(myUid)) {
      archiveTime = docData["archiveFor"][myUid];
    }
    isProcessing = false;
    notifyListeners();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChatView(
                  myUid: myUid!,
                  user: profileInfo,
                  currentChatRoomId: currentChatRoomId,
                  archiveTime: archiveTime,
                  isBlocked: isBlocked,
                  isMeBlocked: isMeBlocked,
                  lastSenderUid: docData['lastSenderUid'],
                )));
  }

  getChatroomId(myUid, otherUserUid) async {
    final querySnapshot = await firestore
        .collection('chatRooms')
        .where("type", isEqualTo: "duo")
        .where("users", arrayContainsAny: [myUid, otherUserUid]).get();

    for (var documentSnapshot in querySnapshot.docs) {
      List<dynamic> users = documentSnapshot.data()['users'];
      print(users);

      if (users.contains(myUid) && users.contains(otherUserUid)) {
        print(documentSnapshot.id);

        return documentSnapshot.id;
      }
    }
    return false;
  }

  removeUser() async {
    isProcessing = true;
    notifyListeners();

    String chatroomId = '';
    final docs = (await firestore
            .collection("chatRooms")
            .where("users", arrayContainsAny: [profileInfo.uid, myUid]).get())
        .docs;
    for (var i in docs) {
      final data = i.data();
      if (data['type'] == "duo") {
        if (data["users"].contains(myUid) &&
            data["users"].contains(profileInfo.uid)) {
          chatroomId = i.id;
        }
      }
    }
    await firestore
        .collection("users")
        .doc(myUid)
        .collection("chatFriends")
        .doc(profileInfo.uid)
        .delete();
    await firestore
        .collection("users")
        .doc(profileInfo.uid)
        .collection("chatFriends")
        .doc(myUid)
        .delete();

    await firestore
        .collection("chatRooms")
        .doc(chatroomId)
        .update({"areFriends": false});

    isProcessing = false;
    isFriend = false;
    notifyListeners();
  }

  String formatLastOnline(String utcDatetimeString) {
    DateTime lastOnlineUtc = DateTime.parse(utcDatetimeString);
    DateTime lastOnlineLocal = lastOnlineUtc.toLocal();
    DateTime now = DateTime.now();

    Duration difference = now.difference(lastOnlineLocal);

    if (difference.inMinutes < 1) {
      return 'Last online just now';
    } else if (difference.inHours < 1) {
      int minutes = difference.inMinutes;
      return 'Last online $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      int hours = difference.inHours;
      return 'Last online $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      int days = difference.inDays;
      return 'Last online $days ${days == 1 ? 'day' : 'days'} ago';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
