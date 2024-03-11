import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:picorix/utils/cache_image_service.dart';

class SearchUserCard extends StatefulWidget {
  final Map user;
  final bool added;
  final String currUserId;
  const SearchUserCard(
      {super.key,
      required this.user,
      required this.added,
      required this.currUserId});

  @override
  State<SearchUserCard> createState() => _SearchUserCardState();
}

class _SearchUserCardState extends State<SearchUserCard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isAdding = false;
  late bool isAdded;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isAdded = widget.added;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/profile",
              arguments: {"uid": widget.user['uid']});
        },
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: Row(
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: cachedProfilePicture(widget.user['profilePictureUrl']),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user['userName'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              isAdded
                  ? Container(
                      height: 40,
                      width: 80,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                        child: Text(
                          "Added",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 40,
                      width: 80,
                      child: MaterialButton(
                        color: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: isAdding
                            ? () {}
                            : () {
                                userAdd();
                              },
                        child: isAdding
                            ? const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: Colors.white),
                                ),
                              )
                            : const Text(
                                "Add",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
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

  userAdd() async {
    final time = DateTime.now().toUtc().toIso8601String();
    setState(() {
      isAdding = true;
    });
    String uid1 = widget.user['uid'];
    String uid2 = widget.currUserId;
    final chatRoomId = await getChatroomId(uid1, uid2);

    if (chatRoomId == false) {
      await firestore.collection("chatRooms").add({
        "users": [uid1, uid2],
        "type": "duo",
        "lastMessage": "Hi! Tap to start chatting",
        "lastMessageTime": DateTime.now().toUtc().toIso8601String(),
        "lastSenderUid": "",
        "isViewing": {
          uid1: [false, time],
          uid2: [false, time]
        },
        "archiveFor": {},
        "unreadCounts": {uid1: 0, uid2: 0},
        "areFriends": true,
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
    setState(() {
      isAdded = true;
      isAdding = false;
    });
  }
}
