import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Message(
      {this.id,
      required this.userName,
      required this.userUid,
      required this.content,
      required this.type,
      required this.timeStamp,
      this.isDeleted = false,
      this.isForwarded = false,
      required this.seenBy,
      required this.reactions,
      required this.previousSenderUid});
  late final String userName;
  late String? id;
  late final String userUid;
  late final String content;
  late final String type;
  late final DateTime timeStamp;
  late final bool isDeleted;
  late final bool isForwarded;
  late final List<dynamic> seenBy;
  late final Map<String, dynamic> reactions;
  late final String previousSenderUid;

  Message.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userUid = json['userUid'];
    content = json['content'];
    isForwarded = json['isForwarded'];
    isDeleted = json['isDeleted'];
    type = json['type'];
    timeStamp = DateTime.parse(json['timeStamp']).toLocal();
    seenBy = json['seenBy'];
    reactions = Map<String, dynamic>.from(json['reactions']);
    previousSenderUid = json["previousSenderUid"];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['userName'] = userName;
    _data['userUid'] = userUid;
    _data['content'] = content;
    _data['type'] = type;
    _data['isDeleted'] = isDeleted;
    _data['isForwarded'] = isForwarded;
    _data['timeStamp'] = timeStamp.toUtc().toIso8601String();
    _data['seenBy'] = seenBy;
    _data['reactions'] = reactions;
    _data['previousSenderUid'] = previousSenderUid;
    return _data;
  }

  Future<void> updateSeenByStatus(
      String currentChatRoomId, String docID, String uid) async {
    await firestore
        .collection("chatRooms")
        .doc(currentChatRoomId)
        .collection("chats")
        .doc(docID)
        .update({
      "seenBy": FieldValue.arrayUnion([uid])
    });
  }

  Future<void> updateReadStatus(
      String currentChatRoomId, String docID, String uid) async {
    DocumentReference chatRoomRef =
        firestore.collection("chatRooms").doc(currentChatRoomId);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
    Map<String, dynamic> unreadCounts = chatRoomSnapshot["unreadCounts"];
    unreadCounts[uid] = 0;
    chatRoomRef.update({'unreadCounts': unreadCounts});
  }
}
