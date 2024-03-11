import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SearchViewModel extends BaseViewModel {
  TextEditingController searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? uid;
  List data = [];
  List searchedUsers = [];
  List myBlockList = [];
  List addedUsers = [];
  List users = [];
  bool isListLoading = true;
  String searchMode = "Username";
  bool isLoadingMore = false;
  bool allLoaded = false;
  // DocumentSnapshot? _lastDocument;
  final ScrollController scrollController = ScrollController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future initializeCurrentUser(context) async {
    uid = _auth.currentUser!.uid;
    // scrollController.addListener(scrollListener);
    final userData = await firestore
        .collection("users")
        .doc(uid)
        .get()
        .then((value) => value.data()!);
    myBlockList = userData["blockList"] ?? [];

    try {
      final documents = (await firestore
              .collection("users")
              .orderBy("userName", descending: false)
              .get())
          .docs;
      addedUsers = (await firestore
              .collection("users")
              .doc(uid)
              .collection("chatFriends")
              .get())
          .docs
          .map((e) => e.id)
          .toList();

      for (var e in documents) {
        var data = e.data();
        if (e.id == uid) {
        } else {
          if ((data["blockList"] != null && data['blockList'].contains(uid)) ||
              myBlockList.contains(data["uid"])) {
          } else {
            users.add({
              "uid": data["uid"],
              "userName": data["userName"],
              "profilePictureUrl": data["profilePictureUrl"],
              "added": addedUsers.contains(data['uid'])
            });
          }
        }
      }

      print(users);
      users.sort((a, b) =>
          a["userName"].toLowerCase().compareTo(b["userName"].toLowerCase()));

      searchedUsers = users;
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(e.message.toString())));
    }
  }

  // ------- Pagination ----------

  // void scrollListener() {
  //   if (scrollController.position.pixels ==
  //       scrollController.position.maxScrollExtent) {
  //     allLoaded ? null : fetchNextBatch();
  //   }
  // }

  // fetchNextBatch() async {
  //   isLoadingMore = true;
  //   notifyListeners();
  //   await firestore
  //       .collection("users")
  //       .orderBy("userName", descending: false)
  //       .limit(10)
  //       .startAfterDocument(_lastDocument!)
  //       .get()
  //       .then((snapshot) {
  //     _lastDocument = snapshot.docs.last;

  //     if (snapshot.docs.isNotEmpty) {
  //       for (var e in snapshot.docs) {
  //         var data = e.data();
  //         if (data["uid"] == uid) {
  //         } else {
  //           if ((data["blockList"] != null &&
  //                   data['blockList'].contains(uid)) ||
  //               myBlockList.contains(data["uid"])) {
  //           } else {
  //             users.add({
  //               "uid": data["uid"],
  //               "userName": data["userName"],
  //               "classInfo": data["classInfo"],
  //               "profilePictureUrl": data["profilePictureUrl"],
  //               "added": addedUsers.contains(data['uid'])
  //             });
  //           }
  //         }
  //       }
  //       isLoadingMore = false;
  //       notifyListeners();
  //     } else {
  //       print("no more docs");
  //       allLoaded = true;
  //       isLoadingMore = false;
  //       notifyListeners();
  //     }
  //   }).catchError((error) {
  //     isLoadingMore = false;
  //     notifyListeners();
  //   });
  // }

  // searchUsers(String searchTerm) async {
  //   if (searchTerm.length > 2) {
  //     searchTerm = searchTerm.toLowerCase();
  //     searchedUsers = [];

  //     List userGot = [];
  //     print(searchTerm);

  //     await firestore
  //         .collection("users")
  //         .orderBy("userName", descending: false)
  //         .startAt([searchTerm])
  //         .get()
  //         .then((value) =>
  //             userGot = value.docs.map((e) => e["userName"]).toList());
  //     print(userGot);
  //   }
  // }

  // --------------------------

  showAvailableUsers(String searchTerm) async {
    if (searchMode == "Class") {
      searchTerm = searchTerm.toLowerCase();
      searchedUsers = [];
      List matchingUsers = [];

      for (var user in users) {
        String classInfo = user['classInfo'].toString().toLowerCase();
        if (searchTerm.length == 1) {
          if (classInfo.startsWith(searchTerm)) {
            matchingUsers.add({
              "userName": user['userName'],
              "uid": user['uid'],
              "profilePictureUrl": user['profilePictureUrl'],
              "added": user['added']
            });
          }
        } else if (classInfo.contains(searchTerm)) {
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
    } else {
      searchTerm = searchTerm.toLowerCase();
      searchedUsers = [];
      List matchingUsers = [];

      for (var user in users) {
        String userName = user['userName'].toString().toLowerCase();
        if (searchTerm.length == 1) {
          if (userName.startsWith(searchTerm)) {
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
  }
}
