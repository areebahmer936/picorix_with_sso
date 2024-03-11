import "dart:async";
import "dart:developer";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:picorix/models/app_user.dart";
import "package:picorix/pages/Chats/chat_view.dart";
import "package:picorix/pages/GroupChat/group_chat_view.dart";
import "package:picorix/services/Auth/AuthServices.dart";
import "package:stacked/stacked.dart";

class MessagesViewModel extends BaseViewModel {
  final String userUid;
  MessagesViewModel(this.userUid);
  String? userId = '';
  String selectedChat = '';
  bool isDeleting = false;
  bool isLoadingMore = false;
  bool isLoggingOut = false;
  DocumentSnapshot? _lastDocument;
  bool isAllLoaded = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;
  final ScrollController scrollController = ScrollController();

  final StreamController<List<DocumentSnapshot<Map<String, dynamic>>>>
      _chatRoomController = StreamController<
          List<DocumentSnapshot<Map<String, dynamic>>>>.broadcast();
  List<DocumentSnapshot<Map<String, dynamic>>> chatRooms = [];

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>> get chatRoomStream =>
      _chatRoomController.stream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _subscription;

  List myBlockList = [];

  // Fetch the chat room data
  fetchChatRoomData() async {
    if (userUid == "") {
      userId = _auth.currentUser!.uid;
    } else {
      userId = userUid;
    }
    scrollController.addListener(_scrollListener);

    _firestore.collection("users").doc(userId).snapshots().listen((event) {
      final data = event.data()!;
      myBlockList = data["blockList"] ?? [];
      notifyListeners();
    });

    try {
      _subscription = _firestore
          .collection("chatRooms")
          .orderBy("lastMessageTime", descending: true)
          .where("users", arrayContains: userId)
          .limit(20)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        for (DocumentChange change in snapshot.docChanges) {
          final doc = change.doc;
          if (change.type == DocumentChangeType.modified) {
            final index =
                chatRooms.indexWhere((existingDoc) => existingDoc.id == doc.id);
            if (index != -1) {
              int indexWhere = chatRooms.indexWhere((chatRoom) {
                return change.doc.id == chatRoom.id;
              });

              if (indexWhere >= 0) {
                chatRooms[indexWhere] =
                    change.doc as DocumentSnapshot<Map<String, dynamic>>;
              }
              chatRooms.sort((a, b) {
                final aTime = DateTime.parse(a['lastMessageTime']);
                final bTime = DateTime.parse(b['lastMessageTime']);
                return bTime.compareTo(aTime); // Descending order
              });

              _chatRoomController.add(chatRooms);
              _lastDocument =
                  snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
              notifyListeners();
            }
          } else if (change.type == DocumentChangeType.added) {
            chatRooms.add(change.doc as DocumentSnapshot<Map<String, dynamic>>);
            chatRooms.sort((a, b) {
              final aTime = DateTime.parse(a['lastMessageTime']);
              final bTime = DateTime.parse(b['lastMessageTime']);
              return bTime.compareTo(aTime); // Descending order
            });
            _chatRoomController.add(chatRooms);
            _lastDocument =
                snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
            notifyListeners();
          } else if (change.type == DocumentChangeType.removed) {
            final index = chatRooms
                .indexWhere((existingDoc) => existingDoc.id == change.doc.id);
            chatRooms.removeAt(index);
            _chatRoomController.add(chatRooms);
            _lastDocument =
                snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
            notifyListeners();
          }
        }
        final newDocuments = snapshot.docs.where(
            (doc) => !chatRooms.any((existingDoc) => existingDoc.id == doc.id));

        if (newDocuments.isNotEmpty) {
          chatRooms.addAll(newDocuments);

          _chatRoomController.add(chatRooms);
          _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
          notifyListeners();
        }
      });
    } on FirebaseException catch (e) {
      log(e.message.toString());
    }

    log("done");
    _subscription.onDone(() {
      _chatRoomController.close();
    });
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      print("triggered");
      isAllLoaded ? null : fetchNextChatRooms();
    }
  }

  Future fetchNextChatRooms() async {
    if (isLoadingMore || _lastDocument == null) return;
    isLoadingMore = true;
    notifyListeners();
    print("doing");

    _firestore
        .collection("chatRooms")
        .orderBy("lastMessageTime", descending: true)
        .where("users", arrayContains: userId)
        .startAfterDocument(_lastDocument!)
        .limit(20)
        .get()
        .then((snapshot) {
      isLoadingMore = false;
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        final newDocuments = snapshot.docs.where(
            (doc) => !chatRooms.any((existingDoc) => existingDoc.id == doc.id));
        if (newDocuments.isNotEmpty) {
          chatRooms.addAll(newDocuments);
          _chatRoomController.add(chatRooms);
          notifyListeners();
        } else {}
      } else {
        isLoadingMore = false;
        isAllLoaded = true;
        notifyListeners();

        print("No more documents available.");
      }
    }).catchError((error) {
      log(error.toString());
      isLoadingMore = false;
      notifyListeners();
    });
  }

  // Dispose method to close the stream controller
  @override
  void dispose() {
    _subscription.cancel();
    _chatRoomController.close();
    if (kDebugMode) {
      print("I am triggered");
    }
    super.dispose();
  }

  onHold(index) {
    //chatSelected = index;
    notifyListeners();
  }

  onChatDelete(chatRoomId) async {
    isDeleting = true;
    notifyListeners();
    final chatRoomRef = _firestore.collection("chatRooms").doc(chatRoomId);

    final chatRoomSnapshot = await chatRoomRef.get();

    Map<String, dynamic> archiveFor = chatRoomSnapshot.data()!['archiveFor'];

    final archiveTime = DateTime.now().toUtc().toIso8601String();
    if (archiveFor.containsKey(userId)) {
      archiveFor[userId!] = archiveTime;
    } else {
      archiveFor.addAll({userId!: archiveTime});
    }
    Map<String, dynamic> unreadCounts = chatRoomSnapshot["unreadCounts"];
    unreadCounts[userId!] = 0;

    await chatRoomRef
        .update({"archiveFor": archiveFor, 'unreadCounts': unreadCounts});

    isDeleting = false;
    selectedChat = '';
    notifyListeners();
  }

  void navigateToChatView(BuildContext context, remoteUserData, String role,
      String currentChatRoomId, String lastSenderUid, String? archiveTime,
      {List? usersList, isRemoved = false}) {
    if (role == "group") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => GroupChatView(
                  myUid: userId!,
                  group: remoteUserData,
                  archiveTime: archiveTime,
                  currentChatRoomId: currentChatRoomId,
                  lastSenderUid: lastSenderUid,
                  usersList: usersList!,
                  isRemoved: isRemoved)));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ChatView(
                  myUid: userId!,
                  user: AppUser.fromJson(remoteUserData),
                  archiveTime: archiveTime,
                  currentChatRoomId: currentChatRoomId,
                  lastSenderUid: lastSenderUid)));
    }
  }

  logOut(context) {
    isLoggingOut = true;
    notifyListeners();
    AuthService().signOut(context);
  }
}
