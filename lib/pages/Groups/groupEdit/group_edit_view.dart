import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Groups/groupEdit/widgets/group_members_card.dart';
import 'package:picorix/pages/Groups/groupEdit/widgets/search_users.dart';
import "package:stacked/stacked.dart";
import 'group_edit_viewmodel.dart';

class GroupEditView extends StatelessWidget {
  final Map groupInfo;
  final String chatRoomId;
  final List members;
  final bool isRemoved;
  final formKey = GlobalKey<FormState>();
  GroupEditView(
      {super.key,
      required this.groupInfo,
      required this.chatRoomId,
      required this.members,
      required this.isRemoved});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => GroupEditViewModel(
            groupInfo: groupInfo, chatRoomId: chatRoomId, isRemoved: isRemoved),
        onViewModelReady: (viewModel) {
          viewModel.initializeCurrentUser().whenComplete(() {
            viewModel.isLoading = false;
            viewModel.notifyListeners();
          });
        },
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: !viewModel.isProcessing,
            onPopInvoked: (didPop) {
              viewModel.imageFile = XFile("");
              viewModel.imageSelected = false;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                toolbarHeight: 80,
                title: const Text(
                  "Group Info",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              body: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            " Group Name",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 10),
                                          textInput(
                                              "Enter a name",
                                              viewModel.groupName,
                                              viewModel.validateGroupName,
                                              !viewModel.isRemoved),

                                          // const SizedBox(height: 10),
                                          // GenreChips(
                                          //     key: GenreChips.genreChipsKey,
                                          //     users: viewModel.usersToAdd)
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Icon",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7, horizontal: 20),
                                            child: Container(
                                                height: 55,
                                                width: 55,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color:
                                                        placeholderBackgroundColor),
                                                child: viewModel.imageSelected
                                                    ? InkWell(
                                                        onTap:
                                                            viewModel.isRemoved
                                                                ? () {}
                                                                : () {
                                                                    viewModel
                                                                        .selectImage();
                                                                  },
                                                        child: ClipRRect(
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            child: Image.file(
                                                              File(viewModel
                                                                  .imageFile
                                                                  .path),
                                                              fit: BoxFit.cover,
                                                            )),
                                                      )
                                                    : InkWell(
                                                        onTap:
                                                            viewModel.isRemoved
                                                                ? () {}
                                                                : () {
                                                                    viewModel
                                                                        .selectImage();
                                                                  },
                                                        child: ClipRRect(
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: groupInfo[
                                                                      "pictureUrl"] ==
                                                                  ""
                                                              ? Center(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    "assets/app/groupPlaceholder.svg",
                                                                    height: 35,
                                                                    colorFilter: const ColorFilter
                                                                        .mode(
                                                                        Colors
                                                                            .white,
                                                                        BlendMode
                                                                            .srcIn),
                                                                  ),
                                                                )
                                                              : Image.network(
                                                                  groupInfo[
                                                                      "pictureUrl"]),
                                                        ),
                                                      )

                                                // FloatingActionButton(
                                                //     backgroundColor:
                                                //         Colors.grey.shade300,
                                                //     elevation: 2,
                                                //     shape:
                                                //         RoundedRectangleBorder(
                                                //             borderRadius:
                                                //                 BorderRadius
                                                //                     .circular(
                                                //                         100)),
                                                //     onPressed: () {
                                                //       print(
                                                //           viewModel.members);
                                                //       //viewModel.selectImage();
                                                //     },
                                                //     child: const Center(
                                                //       child: Icon(
                                                //         Icons.add,
                                                //         size: 30,
                                                //         color: Colors.grey,
                                                //       ),
                                                //     )),
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                const Text(
                                  " Members",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 15),
                                Expanded(
                                  flex: viewModel.isOwner! ? 1 : 0,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade100,
                                    ),
                                    child: Column(
                                      children: [
                                        viewModel.isRemoved
                                            ? const SizedBox()
                                            : viewModel.uid ==
                                                    viewModel.groupOwner
                                                ? searchUsers((e) {
                                                    viewModel
                                                        .showAvailableUsers(e);
                                                  }, !viewModel.isRemoved)
                                                : const SizedBox(),
                                        const SizedBox(height: 15),
                                        Expanded(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: viewModel
                                                  .searchedUsers.length,
                                              itemBuilder: (context, index) {
                                                if (viewModel.isRemoved) {
                                                  if (viewModel
                                                          .searchedUsers[index]
                                                      ['alreadyAdded']) {
                                                    return GroupMemberCard(
                                                      key: ValueKey(viewModel
                                                              .searchedUsers[
                                                          index]['uid']),
                                                      disabled:
                                                          viewModel.isRemoved,
                                                      removeUser: () {
                                                        viewModel.removeUser(
                                                            viewModel
                                                                    .searchedUsers[
                                                                index]);
                                                      },
                                                      manageUser: () {
                                                        viewModel.addOrRemoveUsers(
                                                            viewModel
                                                                    .searchedUsers[
                                                                index]);
                                                      },
                                                      user: viewModel
                                                          .searchedUsers[index],
                                                      added: viewModel
                                                          .usersToAdd
                                                          .contains(viewModel
                                                                  .searchedUsers[
                                                              index]['uid']),
                                                      alreadyAdded: viewModel
                                                              .searchedUsers[
                                                          index]['alreadyAdded'],
                                                    );
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                } else {
                                                  return GroupMemberCard(
                                                    key: ValueKey(
                                                        viewModel.searchedUsers[
                                                            index]['uid']),
                                                    disabled:
                                                        viewModel.isRemoved,
                                                    removeUser: () {
                                                      viewModel.removeUser(
                                                          viewModel
                                                                  .searchedUsers[
                                                              index]);
                                                    },
                                                    manageUser: () {
                                                      viewModel.addOrRemoveUsers(
                                                          viewModel
                                                                  .searchedUsers[
                                                              index]);
                                                    },
                                                    user: viewModel
                                                        .searchedUsers[index],
                                                    added: viewModel.usersToAdd
                                                        .contains(viewModel
                                                                .searchedUsers[
                                                            index]['uid']),
                                                    alreadyAdded: viewModel
                                                            .searchedUsers[
                                                        index]['alreadyAdded'],
                                                  );
                                                }
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        viewModel.isProcessing
                            ? Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.4),
                                child: const Center(
                                    child: CircularProgressIndicator(
                                  color: primaryColor,
                                )),
                              )
                            : const SizedBox()
                      ],
                    ),
              resizeToAvoidBottomInset: true,
              bottomNavigationBar: viewModel.isLoading
                  ? const SizedBox()
                  : viewModel.isRemoved
                      ? Container(
                          height: 70,
                          width: double.infinity,
                          color: Colors.red,
                          child: const Center(
                            child: Text(
                              "This group has been removed.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.all(0),
                          color: Colors.transparent,
                          height: 70,
                          padding: const EdgeInsets.only(
                              bottom: 10, left: 20, right: 20),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 70,
                                width: 70,
                                child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    enableFeedback: false,
                                    highlightColor:
                                        primaryColor.withOpacity(0.7),
                                    splashColor: Colors.red,
                                    color: Colors.red,
                                    onPressed: viewModel.isProcessing
                                        ? () {}
                                        : () {
                                            showConfirmationDialog(context, () {
                                              viewModel.removeGroup();
                                            });
                                          },
                                    child: Center(
                                        child: SvgPicture.asset(
                                      "assets/Icons/delete.svg",
                                      height: 30,
                                      colorFilter: const ColorFilter.mode(
                                          Colors.white, BlendMode.srcIn),
                                    ))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 70,
                                  width: double.infinity,
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    enableFeedback: false,
                                    highlightColor:
                                        primaryColor.withOpacity(0.7),
                                    splashColor:
                                        const Color.fromARGB(255, 25, 210, 118),
                                    color: primaryColor,
                                    onPressed: viewModel.isProcessing
                                        ? () {}
                                        : () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              viewModel.updateGroup(
                                                  context,
                                                  viewModel.imageFile,
                                                  viewModel.groupName.text,
                                                  viewModel.usersToAdd);
                                            }
                                          },
                                    child: viewModel.usersToAdd.isNotEmpty
                                        ? const Text(
                                            "Add",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                          )
                                        : const Text(
                                            "Done",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          );
        });
  }

  TextFormField textInput(
      title, controler, String? Function(String?)? validator, enabled) {
    return TextFormField(
      controller: controler,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          filled: true,
          hintText: title,
          fillColor: Colors.grey.shade200),
    );
  }

  Future<void> showConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          title: Text('Confirmation'),
          content: Text('Are you sure you want to Remove the Group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
