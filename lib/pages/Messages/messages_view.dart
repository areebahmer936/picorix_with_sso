import "package:cloud_firestore/cloud_firestore.dart";
// import "package:magika_chat/Pages/Messages/my_story_card.dart";
// import "package:magika_chat/Pages/Messages/story_card.dart";
import "package:flutter/material.dart";
import "package:picorix/config/themedata.dart";
import "package:picorix/models/app_user.dart";
import "package:picorix/pages/Messages/messages_viewmodel.dart";
import "package:picorix/pages/Messages/user_card.dart";
import "package:picorix/widgets/app_bar.dart";
import "package:stacked/stacked.dart";

class MessagesView extends StatelessWidget {
  final String userUid;

  MessagesView({super.key, required this.userUid});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ViewModelBuilder.reactive(
        onDispose: (viewModel) {
          viewModel.dispose();
        },
        viewModelBuilder: () => MessagesViewModel(userUid),
        onViewModelReady: (viewModel) async {
          print("initialize");
          await viewModel.fetchChatRoomData();
        },
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: true,
            onPopInvoked: (e) {
              viewModel.dispose();
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: customAppBar(
                () async {
                  Navigator.pushNamed(context, '/creategroup');
                },
                () {
                  Navigator.pushNamed(context, '/blocklist');
                },
                () {
                  viewModel.logOut(context);
                },
                context: context,
                page: 0,
                profilePicture: "",
              ),
              backgroundColor: Colors.transparent,
              //appBar: customerAppBar(),
              body: Stack(
                children: [
                  Container(
                    height: size.height,
                    width: size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment(-1.5, -0.9),
                            end: Alignment(1.2, 0.5),
                            colors: [
                          Colors.black,
                          Color.fromARGB(255, 0, 24, 44),
                          primaryColor,
                          Color.fromARGB(255, 0, 149, 104)
                        ],
                            stops: [
                          0.01,
                          0.2,
                          0.45,
                          1
                        ])),
                    child: Container(
                      color: Colors.transparent,
                      child: Column(children: [
                        SizedBox(height: size.height * 0.15),
                        // SizedBox(
                        //   height: size.height * 0.2,
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         vertical: 25.0, horizontal: 15),
                        //     child: ListView.builder(
                        //         scrollDirection: Axis.horizontal,
                        //         itemCount: 5,
                        //         itemBuilder: (context, i) {
                        //           if (i == 0) {
                        //             return InkWell(
                        //               onTap: () {
                        //                 print(json.isEmpty);
                        //                 // Navigator.push(
                        //                 //     context,
                        //                 //     MaterialPageRoute(
                        //                 //         builder: (_) =>
                        //                 //             ProfileView(user: allUsers[i])));
                        //               },
                        //               child: MyStoryCard(
                        //                   user: allUsers[7], viewed: false),
                        //             );
                        //           } else {
                        //             return StoryCard(
                        //               user: viewModel.allUsersCopy[i],
                        //               viewed: false,
                        //             );
                        //           }
                        //         }),
                        //   ),
                        // ),
                        Container(
                          width: size.width,
                          height: 40,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100)),
                              color: Colors.white),
                          child: Center(
                            child: Container(
                              height: 3,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: StreamBuilder(
                                  stream: viewModel.chatRoomStream,
                                  builder: (context,
                                      AsyncSnapshot<
                                              List<
                                                  DocumentSnapshot<
                                                      Map<String, dynamic>>>>
                                          collectionSnapshot) {
                                    // if (collectionSnapshot.connectionState ==
                                    //     ConnectionState.waiting) {
                                    //   return const Center(
                                    //       child: CircularProgressIndicator(
                                    //     color: Colors.red,
                                    //   ));
                                    if (!collectionSnapshot.hasData) {
                                      return Center(
                                        child: Text(
                                          "Add users to start chatting.",
                                          style: TextStyle(
                                              color: Colors.grey.shade400),
                                        ),
                                      );
                                    } else if (collectionSnapshot.hasData) {
                                      return ListView(
                                        addAutomaticKeepAlives: true,
                                        controller: viewModel.scrollController,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 10),
                                        children: collectionSnapshot.data!.map(
                                            (DocumentSnapshot<
                                                    Map<String, dynamic>>
                                                document) {
                                          Map docData = document.data() as Map;

                                          Map<String, dynamic>
                                              currUserUnreadCounts =
                                              docData['unreadCounts'];

                                          if (docData["type"] == "duo" &&
                                              docData['areFriends'] == false) {
                                            return const SizedBox();
                                          } else {
                                            return StreamBuilder(
                                                key: ValueKey(document.id),
                                                stream: docData["type"] ==
                                                        "group"
                                                    ? firestore
                                                        .collection("chatRooms")
                                                        .doc(document.id)
                                                        .snapshots()
                                                    : firestore
                                                        .collection("users")
                                                        .doc(docData['users']
                                                                    [0] ==
                                                                viewModel.userId
                                                            ? docData["users"]
                                                                [1]
                                                            : docData["users"]
                                                                [0])
                                                        .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot snapshot) {
                                                  if (snapshot.hasData) {
                                                    String role =
                                                        docData['type'];
                                                    Map<String, dynamic>
                                                        remote = {};
                                                    if (role == "group") {
                                                      final groupInfo =
                                                          docData["groupInfo"];
                                                      remote = {
                                                        "groupName": groupInfo[
                                                            'groupName'],
                                                        "pictureUrl": groupInfo[
                                                            "pictureUrl"],
                                                        "groupOwner": groupInfo[
                                                            "groupOwner"]
                                                      };
                                                    } else {
                                                      remote = (snapshot.data!
                                                          .data());
                                                    }
                                                    final lastMsgTime =
                                                        DateTime.parse(document[
                                                                "lastMessageTime"])
                                                            .toLocal();

                                                    if ((role == "duo" &&
                                                            remote['blockList'] !=
                                                                null &&
                                                            remote['blockList']
                                                                .contains(viewModel
                                                                    .userId)) ||
                                                        (viewModel.myBlockList
                                                            .contains(remote[
                                                                "uid"]))) {
                                                      return const SizedBox();
                                                    } else {
                                                      if (document['archiveFor']
                                                          .containsKey(viewModel
                                                              .userId)) {
                                                        final archiveTime =
                                                            DateTime.parse(document[
                                                                        "archiveFor"]
                                                                    [viewModel
                                                                        .userId])
                                                                .toLocal();
                                                        if (lastMsgTime.compareTo(
                                                                archiveTime) >
                                                            0) {
                                                          return UserCard(
                                                            onTap: () {
                                                              if (viewModel
                                                                      .selectedChat !=
                                                                  '') {
                                                                viewModel
                                                                    .selectedChat = '';
                                                                viewModel
                                                                    .notifyListeners();
                                                              } else {
                                                                viewModel.navigateToChatView(
                                                                    context,
                                                                    remote,
                                                                    role,
                                                                    document.id,
                                                                    document[
                                                                        'lastSenderUid'],
                                                                    archiveTime
                                                                        .toUtc()
                                                                        .toIso8601String(),
                                                                    isRemoved: document["type"] ==
                                                                            "group"
                                                                        ? document[
                                                                            'isRemoved']
                                                                        : false,
                                                                    usersList:
                                                                        document[
                                                                            "users"]);
                                                              }
                                                            },
                                                            onDelete: () {
                                                              viewModel
                                                                  .onChatDelete(
                                                                      document
                                                                          .id);
                                                            },
                                                            isSelected: viewModel
                                                                    .selectedChat ==
                                                                document.id,
                                                            onHold: () {
                                                              viewModel
                                                                      .selectedChat =
                                                                  document.id;

                                                              viewModel
                                                                  .notifyListeners();
                                                            },
                                                            isOnline: role ==
                                                                    "group"
                                                                ? false
                                                                : remote[
                                                                    'isOnline'],
                                                            lastMessage: document[
                                                                'lastMessage'],
                                                            lastMessageTime:
                                                                document[
                                                                    'lastMessageTime'],
                                                            unreadCount:
                                                                currUserUnreadCounts[
                                                                    viewModel
                                                                        .userId],
                                                            user: role ==
                                                                    'group'
                                                                ? null
                                                                : AppUser.fromJson(
                                                                    snapshot
                                                                        .data!
                                                                        .data()),
                                                            group:
                                                                role == 'group'
                                                                    ? remote
                                                                    : null,
                                                          );
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      } else {
                                                        return UserCard(
                                                          onTap: () {
                                                            if (viewModel
                                                                    .selectedChat !=
                                                                '') {
                                                              viewModel
                                                                  .selectedChat = '';
                                                              viewModel
                                                                  .notifyListeners();
                                                            } else {
                                                              viewModel.navigateToChatView(
                                                                  context,
                                                                  remote,
                                                                  role,
                                                                  document.id,
                                                                  document[
                                                                      'lastSenderUid'],
                                                                  null,
                                                                  isRemoved: document[
                                                                              "type"] ==
                                                                          "group"
                                                                      ? document[
                                                                          'isRemoved']
                                                                      : false,
                                                                  usersList:
                                                                      document[
                                                                          "users"]);
                                                            }
                                                          },
                                                          onDelete: () {
                                                            viewModel
                                                                .onChatDelete(
                                                                    document
                                                                        .id);
                                                          },
                                                          isSelected: viewModel
                                                                  .selectedChat ==
                                                              document.id,
                                                          onHold: () {
                                                            viewModel
                                                                    .selectedChat =
                                                                document.id;

                                                            viewModel
                                                                .notifyListeners();
                                                          },
                                                          isOnline: role ==
                                                                  "group"
                                                              ? false
                                                              : remote[
                                                                  'isOnline'],
                                                          lastMessage: document[
                                                              'lastMessage'],
                                                          lastMessageTime: document[
                                                              'lastMessageTime'],
                                                          unreadCount:
                                                              currUserUnreadCounts[
                                                                  viewModel
                                                                      .userId],
                                                          user: role == 'group'
                                                              ? null
                                                              : AppUser.fromJson(
                                                                  snapshot.data!
                                                                      .data()),
                                                          group: role == 'group'
                                                              ? remote
                                                              : null,
                                                        );
                                                      }
                                                    }
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                });
                                          }
                                        }).toList()
                                          ..add(viewModel.isLoadingMore == true
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child:
                                                          CircularProgressIndicator(
                                                              color: Colors.grey
                                                                  .shade300),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "Loading more chats",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade300),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox(
                                                  height: 20,
                                                )),
                                      );
                                    } else {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                  })),
                        )
                      ]),
                    ),
                  ),
                  viewModel.isDeleting
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          );
        });
  }
}
