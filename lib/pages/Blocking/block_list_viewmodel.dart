import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:stacked/stacked.dart";

class BlockListViewModel extends BaseViewModel {
  List blockedUsers = [];
  String? myUid;
  bool isLoading = true;
  bool isProcessing = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  fetchBlockedUsers() async {
    myUid = _auth.currentUser!.uid;
    final blockeduids = await firestore
        .collection("users")
        .doc(myUid)
        .get()
        .then((value) => value.data()!["blockList"] ?? []);
    if (blockeduids.isEmpty) {
      blockedUsers = [];
    } else {
      blockedUsers = await firestore
          .collection("users")
          .where("uid", whereIn: blockeduids)
          .get()
          .then((value) => value.docs
              .map((e) => {
                    "userName": e["userName"],
                    "uid": e["uid"],
                    "pictureUrl": e["profilePictureUrl"]
                  })
              .toList());
    }

    isLoading = false;
    notifyListeners();
  }

  unblockUser(uid, index) async {
    isProcessing = true;
    notifyListeners();
    await firestore.collection("users").doc(myUid).update({
      "blockList": FieldValue.arrayRemove([uid])
    });
    isProcessing = false;
    blockedUsers.removeAt(index);
    notifyListeners();
  }
}
