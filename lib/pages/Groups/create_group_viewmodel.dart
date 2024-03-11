import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:stacked/stacked.dart";

class CreateGroupViewModel extends BaseViewModel {
  TextEditingController groupName = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  XFile imageFile = XFile("");
  bool imageSelected = false;
  String? uid;
  List usersToAdd = [];
  ImagePicker imagePicker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  bool isLoading = true;
  bool isSubmitting = false;
  List users = [];
  List searchedUsers = [];

  selectImage() async {
    final XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      imageFile = selectedImage;
      imageSelected = true;
      notifyListeners();
    } else {
      return null;
    }
  }

  makeGroup(context, image, String groupName, List uids) async {
    isSubmitting = true;
    notifyListeners();
    String imageUrl = "";
    if (imageSelected == true) {
      final ref = firebaseStorage
          .ref()
          .child('Groups')
          .child(groupName)
          .child('${DateTime.now().toIso8601String()}_ProfilePicture');
      await ref.putFile(File(image.path));
      imageUrl = await ref.getDownloadURL();
    }

    Map<String, int> uidMap =
        Map.fromIterable(uids, key: (uid) => uid, value: (_) => 0);
    Map<String, dynamic> isViewing = {
      for (var uid in uids)
        uid: [false, DateTime.now().toUtc().toIso8601String()]
    };
    isViewing.addAll({
      uid!: [false, DateTime.now().toUtc().toIso8601String()]
    });

    uidMap.addAll({uid!: 0});
    uids.add(uid!);

    final chatroom = {
      "type": "group",
      "users": uids,
      "lastMessage": "Tap to Start Chatting",
      "lastMessageTime": DateTime.now().toUtc().toIso8601String(),
      "lastSenderUid": "",
      "unreadCounts": uidMap,
      "isRemoved": false,
      "isViewing": isViewing,
      "archiveFor": {},
      "groupInfo": {
        "groupName": groupName,
        "pictureUrl": imageUrl,
        "groupOwner": uid
      }
    };

    await firestore.collection("chatRooms").add(chatroom);

    isSubmitting = false;
    notifyListeners();
    Navigator.pushNamed(context, "/alldone");
  }

  Future initializeCurrentUser() async {
    uid = _auth.currentUser!.uid;

    final documents = (await firestore
            .collection("users")
            .orderBy("userName", descending: false)
            .get())
        .docs;

    for (var i in documents) {
      final data = i.data();
      if (data["uid"] == uid) {
      } else {
        users.add({
          "uid": data["uid"],
          "userName": data["userName"],
          "profilePictureUrl": data["profilePictureUrl"],
          "added": false
        });
      }
    }

    searchedUsers = users;
  }

  addOrRemoveUsers(uid) {
    usersToAdd.contains(uid) ? usersToAdd.remove(uid) : usersToAdd.add(uid);
    notifyListeners();
  }

  showAvailableUsers(String searchTerm) async {
    print(searchTerm);
    searchTerm = searchTerm.toLowerCase();
    searchedUsers = [];
    List matchingUsers = [];

    for (var user in users) {
      String userName = user['userName'].toString().toLowerCase();
      if (searchTerm.length == 1) {
        // Only include users whose names start with the search term
        if (userName.startsWith(searchTerm)) {
          print("first character matches");
          matchingUsers.add({
            "userName": user['userName'],
            "uid": user['uid'],
            "profilePictureUrl": user['profilePictureUrl'],
            "added": user['added']
          });
        }
      } else if (userName.contains(searchTerm)) {
        matchingUsers.add({
          "userName": user['userName'],
          "uid": user['uid'],
          "profilePictureUrl": user['profilePictureUrl'],
          "added": user['added']
        });
      }
    }
    searchedUsers = matchingUsers;
    notifyListeners();
  }

  String? validateGroupName(String? value) {
    if (value!.length < 3) {
      return 'Must be at least 3 characters long';
    } else {
      return null;
    }
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

  @override
  void dispose() {
    super.dispose();
  }
}
