import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/models/message.dart';
import 'package:picorix/pages/Chats/widgets/audio_container_local.dart';
import 'package:picorix/pages/Chats/widgets/chat_container.dart';
import 'package:picorix/pages/GroupChat/group_chat_viewmodel.dart';
import 'package:picorix/pages/GroupChat/widgets/chat_container.dart';
import 'package:picorix/widgets/chat_message_field.dart';
import "package:stacked/stacked.dart";

class GroupChatView extends StatefulWidget {
  final String myUid;
  final Map group;
  final String? archiveTime;
  final String currentChatRoomId;
  final String lastSenderUid;
  final List usersList;
  final bool isRemoved;
  const GroupChatView({
    super.key,
    required this.currentChatRoomId,
    this.archiveTime,
    required this.group,
    required this.lastSenderUid,
    required this.usersList,
    required this.isRemoved,
    required this.myUid,
  });

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView>
    with WidgetsBindingObserver {
  late GroupChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    viewModel = GroupChatViewModel(
        myUid: widget.myUid,
        archiveTime: widget.archiveTime,
        groupInfo: widget.group,
        chatRoomId: widget.currentChatRoomId,
        lastSenderUid: widget.lastSenderUid,
        isRemoved: widget.isRemoved,
        usersList: widget.usersList);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    viewModel.handleAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => viewModel,
        // GroupChatViewModel(
        //     myUid: widget.myUid,
        //     archiveTime: widget.archiveTime,
        //     groupInfo: widget.group,
        //     chatRoomId: widget.currentChatRoomId,
        //     lastSenderUid: widget.lastSenderUid,
        //     isRemoved: widget.isRemoved,
        //     usersList: widget.usersList),
        onViewModelReady: (viewModel) async {
          await viewModel.initialize(context);
        },
        builder: (context, viewModel, child) {
          return PopScope(
            onPopInvoked: (e) {
              WidgetsBinding.instance.removeObserver(this);
              viewModel.imageFile = XFile("");
              viewModel.isRecorded = true;
              viewModel.audioPath = "";
              viewModel.imageSelected = false;
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 255, 250, 250),
                elevation: 5,
                shadowColor: Colors.grey.shade200,
                leading: Row(children: [
                  const BackButton(
                    color: const Color.fromARGB(255, 32, 27, 27),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                          context,
                          viewModel.isOwner!
                              ? "/groupeditinfo"
                              : "/groupviewinfo",
                          arguments: {
                            "chatRoomId": viewModel.chatRoomId,
                            "groupInfo": widget.group,
                            "members": widget.usersList
                          });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: const Color.fromARGB(255, 3, 37, 67),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: viewModel.groupProfileImage(
                              viewModel.groupPictureUrl ??
                                  widget.group['pictureUrl'])),
                    ),
                  )
                ]),
                toolbarHeight: 80,
                leadingWidth: 100,
                title: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                        context,
                        viewModel.isOwner!
                            ? "/groupeditinfo"
                            : "/groupviewinfo",
                        arguments: {
                          "chatRoomId": viewModel.chatRoomId,
                          "groupInfo": widget.group,
                          "members": widget.usersList,
                          "isRemoved": viewModel.isRemoved
                        });
                  },
                  child: Text(
                    viewModel.groupName ?? widget.group['groupName'],
                  ),
                ),
                // actions: [
                //   Center(
                //       child: SvgPicture.asset(
                //     "assets/Icons/voiceCall.svg",
                //     height: 35,
                //   )),
                //   const SizedBox(width: 10),
                //   Center(
                //       child: SvgPicture.asset(
                //     "assets/Icons/videoCall.svg",
                //     height: 30,
                //   )),
                //   const SizedBox(
                //     width: 30,
                //   )
                // ],
              ),
              body: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                            child: StreamBuilder(
                                stream: viewModel.chatStream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            List<
                                                DocumentSnapshot<
                                                    Map<String, dynamic>>>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    List<DocumentSnapshot> docs =
                                        snapshot.data!;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, right: 0, bottom: 0),
                                      child: ListView(
                                        reverse: true,
                                        shrinkWrap: true,
                                        controller: viewModel.scrollController,
                                        scrollDirection: Axis.vertical,
                                        children: [
                                          ListView.builder(
                                              shrinkWrap: true,
                                              reverse: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              addAutomaticKeepAlives: true,
                                              itemCount: docs.length,
                                              itemBuilder: (context, index) {
                                                Message message =
                                                    Message.fromJson(
                                                        docs[index].data()
                                                            as Map<String,
                                                                dynamic>);

                                                message.id = docs[index].id;

                                                if (message.userUid ==
                                                    viewModel.userId) {
                                                  return chatContainer(
                                                      context,
                                                      0,
                                                      message,
                                                      (e) {
                                                        viewModel.addReaction(
                                                            message.id, e);
                                                      },
                                                      message.userUid ==
                                                          message
                                                              .previousSenderUid,
                                                      () {
                                                        viewModel.deleteMessage(
                                                            message.id);
                                                      },
                                                      viewModel
                                                          .externalDirectory,
                                                      viewModel.chatRoomId,
                                                      disable:
                                                          viewModel.isRemoved);
                                                } else if (message.type ==
                                                    "update") {
                                                  return Align(
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15,
                                                          horizontal: 30),
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      child: Center(
                                                          child: Text(
                                                        message.content,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade500),
                                                      )),
                                                    ),
                                                  );
                                                } else {
                                                  if (message.seenBy.contains(
                                                          viewModel.userId) ==
                                                      false) {
                                                    message.updateSeenByStatus(
                                                        widget
                                                            .currentChatRoomId,
                                                        docs[index].id,
                                                        viewModel.userId!);
                                                  }
                                                  message.updateReadStatus(
                                                      widget.currentChatRoomId,
                                                      docs[index].id,
                                                      viewModel.userId!);

                                                  return groupChatContainer(
                                                      null, context, 1, message,
                                                      (e) {
                                                    viewModel.addReaction(
                                                        message.id, e);
                                                  },
                                                      docs.last.id ==
                                                              message.id ||
                                                          message.userUid !=
                                                              message
                                                                  .previousSenderUid
                                                      // showInfo: notNewMessage,
                                                      ,
                                                      viewModel
                                                          .externalDirectory,
                                                      viewModel.chatRoomId,
                                                      disable:
                                                          viewModel.isRemoved);
                                                }
                                                // }
                                              }),
                                          viewModel.isLoadingMore
                                              ? SizedBox(
                                                  height: 50,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                                color: Colors
                                                                    .grey
                                                                    .shade400),
                                                      ),
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                      Text(
                                                        "loading More...",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade400),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 50,
                                                ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                })),
                        const SizedBox(height: 10),
                        viewModel.isRecording
                            ? Container(
                                padding: const EdgeInsets.all(10),
                                height: 90,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey, blurRadius: 10)
                                    ]),
                                child:
                                    Lottie.asset("assets/app/recording.json"),
                              )
                            : const SizedBox(),
                        viewModel.isRemoved
                            ? Container(
                                height: 70,
                                color: Colors.red,
                                child: const Center(
                                  child: Text(
                                    "This group has been removed.",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              )
                            : !viewModel.imageSelected
                                ? viewModel.videoFileSelected
                                    ? Stack(
                                        children: [
                                          Container(
                                            height: 80,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                      blurRadius: 10,
                                                      color:
                                                          Colors.grey.shade400)
                                                ]),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: Row(children: [
                                                Expanded(
                                                  child: Center(
                                                      child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: Colors
                                                            .grey.shade200),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(
                                                            width: 15),
                                                        Text(
                                                          viewModel
                                                              .videoFileName,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                        ),
                                                        const Spacer(),
                                                        Text(
                                                          " ${viewModel.videoFileSizeString}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
                                                      ],
                                                    ),
                                                  )),
                                                ),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                    onTap: () {
                                                      viewModel.removeVideo();
                                                    },
                                                    child: deleteButton()),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                    onTap: () =>
                                                        viewModel.uploadVideo(),
                                                    child: sendButton()),
                                                const SizedBox(width: 10),
                                              ]),
                                            ),
                                          ),
                                          viewModel.isVideoSending
                                              ? Container(
                                                  height: 80,
                                                  width: double.infinity,
                                                  color: Colors.white
                                                      .withOpacity(0.6),
                                                  child: ClipRRect(
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 3, sigmaY: 3),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            !viewModel
                                                                    .showProgress
                                                                ? "Sending..."
                                                                : "Sending... (${(viewModel.progressValue * 100).toStringAsFixed(0)} %)",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          SizedBox(
                                                              height: 30,
                                                              width: 30,
                                                              child: viewModel
                                                                      .showProgress
                                                                  ? CircularProgressIndicator(
                                                                      value: viewModel
                                                                          .progressValue,
                                                                      color:
                                                                          primaryColor,
                                                                      strokeWidth:
                                                                          7,
                                                                    )
                                                                  : const CircularProgressIndicator(
                                                                      color:
                                                                          primaryColor,
                                                                      strokeWidth:
                                                                          7,
                                                                    )),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox()
                                        ],
                                      )
                                    : viewModel.fileSelected
                                        ? Stack(
                                            children: [
                                              Container(
                                                height: 80,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 10,
                                                          color: Colors
                                                              .grey.shade400)
                                                    ]),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20.0),
                                                  child: Row(children: [
                                                    Expanded(
                                                      child: Center(
                                                          child: Container(
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Colors
                                                                .grey.shade200),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                                width: 15),
                                                            Text(
                                                              viewModel
                                                                  .documentFileName,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              " ${viewModel.fileSizeString}",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
                                                            ),
                                                            const SizedBox(
                                                                width: 15),
                                                          ],
                                                        ),
                                                      )),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    InkWell(
                                                        onTap: () {
                                                          viewModel
                                                              .removeDocument();
                                                        },
                                                        child: deleteButton()),
                                                    const SizedBox(width: 10),
                                                    InkWell(
                                                        onTap: () => viewModel
                                                            .uploadDocument(),
                                                        child: sendButton()),
                                                    const SizedBox(width: 10),
                                                  ]),
                                                ),
                                              ),
                                              viewModel.isDocSending
                                                  ? Container(
                                                      height: 80,
                                                      width: double.infinity,
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      child: ClipRRect(
                                                        child: BackdropFilter(
                                                          filter:
                                                              ImageFilter.blur(
                                                                  sigmaX: 3,
                                                                  sigmaY: 3),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                !viewModel
                                                                        .showProgress
                                                                    ? "Sending..."
                                                                    : "Sending... (${(viewModel.progressValue * 100).toStringAsFixed(0)} %)",
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                              ),
                                                              const SizedBox(
                                                                width: 15,
                                                              ),
                                                              SizedBox(
                                                                  height: 30,
                                                                  width: 30,
                                                                  child: viewModel
                                                                          .showProgress
                                                                      ? CircularProgressIndicator(
                                                                          value:
                                                                              viewModel.progressValue,
                                                                          color:
                                                                              primaryColor,
                                                                          strokeWidth:
                                                                              7,
                                                                        )
                                                                      : const CircularProgressIndicator(
                                                                          color:
                                                                              primaryColor,
                                                                          strokeWidth:
                                                                              7,
                                                                        )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox()
                                            ],
                                          )
                                        : viewModel.isRecorded
                                            ? Stack(
                                                children: [
                                                  Container(
                                                    height: 80,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              blurRadius: 10,
                                                              color: Colors.grey
                                                                  .shade400)
                                                        ]),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20.0),
                                                      child: Row(children: [
                                                        Expanded(
                                                          child: Center(
                                                            child:
                                                                AudioWidgetLocal(
                                                              path: viewModel
                                                                  .audioPath,
                                                              duration: viewModel
                                                                  .formatDuration(
                                                                      viewModel
                                                                          .recordDuration),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        InkWell(
                                                            onTap: () {
                                                              viewModel
                                                                  .audioPath = '';
                                                              viewModel
                                                                      .isRecorded =
                                                                  false;
                                                              viewModel
                                                                  .notifyListeners();
                                                            },
                                                            child:
                                                                deleteButton()),
                                                        const SizedBox(
                                                            width: 10),
                                                        InkWell(
                                                            onTap: () => viewModel
                                                                .uploadAudio(),
                                                            child:
                                                                sendButton()),
                                                        const SizedBox(
                                                            width: 10),
                                                      ]),
                                                    ),
                                                  ),
                                                  viewModel.isAudioSending
                                                      ? Container(
                                                          height: 80,
                                                          width:
                                                              double.infinity,
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                          child: const Center(
                                                              child: Stack(
                                                            children: [
                                                              CircularProgressIndicator(
                                                                color:
                                                                    primaryColor,

                                                                // color: blue,
                                                                // valueColor: blue,
                                                              ),
                                                              // Text(
                                                              //     "${viewModel.audioUploadProgress * 100} %")
                                                            ],
                                                          )),
                                                        )
                                                      : const SizedBox()
                                                ],
                                              )
                                            : ChatBottomBar(
                                                messageSend: () =>
                                                    viewModel.sendMessage(
                                                        widget
                                                            .currentChatRoomId,
                                                        'text'),
                                                controller: viewModel
                                                    .chatMessageController,
                                                onCamera: () {
                                                  viewModel
                                                      .selectImageFromCamera();
                                                },
                                                onStartRecording: () async {
                                                  await viewModel.soundPlayer
                                                      .play(AssetSource(
                                                          'app/startRecording.mp3'))
                                                      .whenComplete(() =>
                                                          viewModel.start());
                                                },
                                                onStopRecording: () async {
                                                  viewModel.stop();

                                                  await viewModel.soundPlayer
                                                      .play(AssetSource(
                                                          'app/stopRecording.mp3'));
                                                },
                                                tapOnAttach: () {
                                                  tapOnAttach(context, () {
                                                    viewModel.selectImage();
                                                  }, () {
                                                    viewModel
                                                        .selectImageFromCamera();
                                                  }, () {
                                                    viewModel
                                                        .selectFile(context);
                                                  }, () {
                                                    viewModel
                                                        .pickVideo(context);
                                                  });
                                                },
                                              )
                                : Stack(
                                    children: [
                                      Container(
                                        height: 80,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 10,
                                                  color: Colors.grey.shade300)
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 20),
                                          child: Row(children: [
                                            Expanded(
                                              child: InkWell(
                                                  onTap: () {
                                                    showImageDialog(context,
                                                        viewModel.imageFile);
                                                  },
                                                  child: Container(
                                                      height: 40,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: Colors
                                                              .grey.shade300),
                                                      child: Center(
                                                          child: Text(
                                                        viewModel
                                                            .imageFile.name,
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                      )))),
                                            ),
                                            const SizedBox(width: 10),
                                            InkWell(
                                                onTap: () {
                                                  viewModel.imageSelected =
                                                      false;
                                                  viewModel.imageFile =
                                                      XFile('');
                                                  viewModel.notifyListeners();
                                                },
                                                child: deleteButton()),
                                            const SizedBox(width: 10),
                                            InkWell(
                                                onTap: () {
                                                  viewModel.upload(
                                                      viewModel.imageFile);
                                                },
                                                child: sendButton())
                                          ]),
                                        ),
                                      ),
                                      viewModel.isImageSending
                                          ? Container(
                                              height: 80,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        color: primaryColor),
                                              ),
                                            )
                                          : const SizedBox()
                                    ],
                                  )
                      ],
                    ),
            ),
          );
        });
  }

  Container sendButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.green),
      child: Center(
          child: SvgPicture.asset(
        "assets/Icons/send.svg",
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        height: 25,
      )),
    );
  }

  Container deleteButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.red),
      child: Center(
          child: SvgPicture.asset(
        "assets/Icons/delete.svg",
        height: 25,
      )),
    );
  }

  tapOnAttach(context, VoidCallback onMedia, VoidCallback onCamera,
      VoidCallback onDocument, VoidCallback onVideo) {
    return showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.6, //0.8,
              maxChildSize: 1,
              minChildSize: 0.6, //0.8,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    // height: 900,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "Share Content",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          SizedBox(height: 20),
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    onCamera();
                                    Navigator.pop(context);
                                  },
                                  child: bottomSheetItems(
                                      "camera", "Camera", "Click a picture"),
                                ),
                                divider(),
                                InkWell(
                                  onTap: () {
                                    onDocument();
                                    Navigator.pop(context);
                                  },
                                  child: bottomSheetItems(
                                      "doc", "Documents", "Share your files"),
                                ),
                                divider(),
                                // bottomSheetItems("poll", "Create a Poll",
                                //     "Create a poll for any query"),
                                // divider(),
                                InkWell(
                                  onTap: () {
                                    onMedia();
                                    Navigator.pop(context);
                                  },
                                  child: bottomSheetItems(
                                      "media", "Photos", "Share Photos"),
                                ),
                                divider(),
                                InkWell(
                                  onTap: () {
                                    onVideo();
                                    Navigator.pop(context);
                                  },
                                  child: bottomSheetItems(
                                      "videoCall", "Videos", "Share Videos"),
                                ),
                                // divider(),
                                // bottomSheetItems("location", "Location",
                                //     "Share your Location"),
                              ],
                            ),
                          )
                        ],
                      ),
                    ));
              });
        });
  }

  Divider divider() {
    return Divider(
      color: Colors.grey.shade300,
      indent: 25,
      endIndent: 25,
    );
  }

  void showImageDialog(BuildContext context, XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.file(File(imageFile.path)),
          ),
        );
      },
    );
  }

  SizedBox bottomSheetItems(icon, label, baselinetext) {
    return SizedBox(
      height: 75,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 20),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 225, 225, 225),
                    borderRadius: BorderRadius.circular(100)),
                child: ClipRRect(
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/Icons/$icon.svg",
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade500, BlendMode.srcIn),
                      height: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(baselinetext,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400))
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
