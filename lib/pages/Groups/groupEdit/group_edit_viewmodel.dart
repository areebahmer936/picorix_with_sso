import "dart:io";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:picorix/models/message.dart";
import "package:stacked/stacked.dart";

class GroupEditViewModel extends BaseViewModel {
  Map groupInfo;
  String chatRoomId;
  List members = [];
  GroupEditViewModel(
      {required this.groupInfo,
      required this.chatRoomId,
      required this.isRemoved});
  TextEditingController groupName = TextEditingController();
  String? pictureUrl;
  String? groupOwner;
  bool? isOwner;
  bool isRemoved;

  XFile imageFile = XFile("");
  bool imageSelected = false;
  String? uid;
  List usersToAdd = [];
  ImagePicker imagePicker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  bool isLoading = true;
  bool isProcessing = false;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> searchedUsers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  updateGroup(context, image, String groupName, List usersToBeAdded) async {
    String imageUrl = "";
    isProcessing = true;
    notifyListeners();
    if (imageSelected == true) {
      final ref = firebaseStorage
          .ref()
          .child('Groups')
          .child(groupName)
          .child('${DateTime.now().toIso8601String()}_ProfilePicture');
      await ref.putFile(File(image.path));
      imageUrl = await ref.getDownloadURL();
    }
    final data = await firestore.collection("chatRooms").doc(chatRoomId).get();

    final Map<String, dynamic> unreadCounts = data.data()!["unreadCounts"];
    final Map<String, dynamic> isViewing = data.data()!["isViewing"];
    for (Map<String, dynamic> newUid in usersToBeAdded) {
      unreadCounts.addAll({newUid['uid']: 0});
      isViewing.addAll({
        newUid['uid']: [false, DateTime.now().toUtc().toIso8601String()]
      });
    }
    List userss = usersToBeAdded.map((e) => e["uid"]).toList();

    await firestore.collection("chatRooms").doc(chatRoomId).update({
      "users": FieldValue.arrayUnion(userss),
      "unreadCounts": unreadCounts,
      "isViewing": isViewing,
      "groupInfo": {
        "groupName": groupName,
        "pictureUrl":
            imageSelected == false ? groupInfo["pictureUrl"] : imageUrl,
        "groupOwner": groupOwner
      }
    });
    for (var i in usersToBeAdded) {
      Message msg = Message(
          userName: "admin",
          userUid: "-1",
          content: "${i["userName"]} has been added.",
          type: "update",
          timeStamp: DateTime.now(),
          seenBy: [],
          reactions: {},
          previousSenderUid: "-1");

      await firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("chats")
          .add(msg.toJson());
    }

    isProcessing = false;
    notifyListeners();
    Navigator.pop(context);
  }

  removeGroup() async {
    isProcessing = true;
    notifyListeners();
    await firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .update({"isRemoved": true});
    isRemoved = true;
    isProcessing = false;
    notifyListeners();
  }

  Future initializeCurrentUser() async {
    groupName.text = groupInfo['groupName'];
    pictureUrl = groupInfo['pictureUrl'];
    groupOwner = groupInfo['groupOwner'];

    uid = _auth.currentUser!.uid;
    isOwner = groupOwner == uid;

    final documents = (await firestore
            .collection("users")
            .orderBy("userName", descending: false)
            .get())
        .docs;
    final doc = await firestore.collection("chatRooms").doc(chatRoomId).get();
    members = doc.data()!["users"];

    for (var i in documents) {
      final e = i.data();
      if (e['uid'] == uid) {
      } else {
        users.add({
          "uid": e["uid"],
          "userName": e["userName"],
          "profilePictureUrl": e["profilePictureUrl"],
          "alreadyAdded": members.contains(e["uid"])
        });
      }
    }
    // users = documents
    //     .map((e) => {
    //           "uid": e["uid"],
    //           "userName": e["userName"],
    //           "profilePictureUrl": e["profilePictureUrl"],
    //           "alreadyAdded": members.contains(e["uid"])
    //         })
    //     .toList();
    // users.sort((a, b) =>
    //     a["userName"].toLowerCase().compareTo(b["userName"].toLowerCase()));
    users.sort((a, b) {
      if (a['alreadyAdded']) {
        return -1;
      } else if (b['alreadyAdded']) {
        return 1;
      } else {
        return 0;
      }
    });
    searchedUsers = users;
    print(searchedUsers);
  }

  List<Map<String, dynamic>> userMapSort(List<Map<String, dynamic>> lst) {
    lst.sort((a, b) =>
        a["userName"].toLowerCase().compareTo(b["userName"].toLowerCase()));
    lst.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      if (a['alreadyAdded']) {
        return -1;
      } else if (b['alreadyAdded']) {
        return 1;
      } else {
        return 0;
      }
    });

    return lst;
  }

  removeUser(Map user) async {
    isProcessing = true;
    notifyListeners();
    final data = await firestore.collection("chatRooms").doc(chatRoomId).get();
    Map unreadCounts = data.data()!["unreadCounts"];
    List membersCopy = members;
    membersCopy.remove(user[uid]);
    unreadCounts.remove(user["uid"]);
    await firestore.collection("chatRooms").doc(chatRoomId).update({
      "users": FieldValue.arrayRemove([user["uid"]]),
      "unreadCounts": unreadCounts
    });
    searchedUsers.remove(user);
    user['alreadyAdded'] = false;
    searchedUsers.add(user as Map<String, dynamic>);
    searchedUsers = userMapSort(searchedUsers as List<Map<String, dynamic>>);
    Message msg = Message(
        userName: "admin",
        userUid: "-1",
        content: "${user["userName"]} has been removed.",
        type: "update",
        timeStamp: DateTime.now(),
        seenBy: [],
        reactions: {},
        previousSenderUid: "-1");

    await firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .add(msg.toJson());

    isProcessing = false;
    notifyListeners();
  }

  addOrRemoveUsers(user) {
    usersToAdd.contains(user) ? usersToAdd.remove(user) : usersToAdd.add(user);
    //usersToAdd.contains(uid) ? usersToAdd.remove(uid) : usersToAdd.add(uid);
    notifyListeners();
  }

  showAvailableUsers(String searchTerm) async {
    print(searchTerm);
    searchTerm = searchTerm.toLowerCase();
    searchedUsers = [];
    List<Map<String, dynamic>> matchingUsers = [];

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
            "alreadyAdded": user['alreadyAdded']
          });
        }
      } else if (userName.contains(searchTerm)) {
        matchingUsers.add({
          "userName": user['userName'],
          "uid": user['uid'],
          "profilePictureUrl": user['profilePictureUrl'],
          "alreadyAdded": user['alreadyAdded']
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
}
