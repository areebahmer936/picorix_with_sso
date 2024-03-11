import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:stacked/stacked.dart";

class GroupInfoViewModel extends BaseViewModel {
  Map groupInfo;
  String chatRoomId;
  List members;
  GroupInfoViewModel(
      {required this.groupInfo,
      required this.chatRoomId,
      required this.members});
  TextEditingController groupName = TextEditingController();
  String? pictureUrl;
  String? groupOwner;
  bool? isOwner;

  String? uid;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List users = [];
  List searchedUsers = [];

  Future initializeCurrentUser() async {
    groupName.text = groupInfo['groupName'];
    pictureUrl = groupInfo['pictureUrl'];
    groupOwner = groupInfo['groupOwner'];

    uid = _auth.currentUser!.uid;
    isOwner = groupOwner == uid;

    final documents = (await firestore
            .collection("users")
            .where("uid", whereIn: members)
            .get())
        .docs;

    users = documents
        .map((e) => {
              "uid": e["uid"],
              "userName": e["userName"],
              "profilePictureUrl": e["profilePictureUrl"],
              "added": false //addedUsers.contains(e["uid"])
            })
        .toList();

    users.sort((a, b) =>
        a["userName"].toLowerCase().compareTo(b["userName"].toLowerCase()));

    users.sort((a, b) {
      if (a['uid'] == groupOwner) {
        return -1;
      } else if (b['uid'] == groupOwner) {
        return 1;
      } else {
        return 0;
      }
    });
    searchedUsers = users;
  }

  void showCurvedBorderSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Should be at least 2 users to add'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
