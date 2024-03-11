import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Groups/create_group_viewmodel.dart';
import "package:stacked/stacked.dart";

import 'widgets/group_members_card.dart';
import 'widgets/search_users.dart';

class CreateGroupView extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  CreateGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => CreateGroupViewModel(),
        onViewModelReady: (viewModel) {
          viewModel.initializeCurrentUser().whenComplete(() {
            viewModel.isLoading = false;
            viewModel.notifyListeners();
          });
        },
        builder: (context, viewModel, child) {
          return PopScope(
            canPop: !viewModel.isSubmitting,
            onPopInvoked: (didPop) {
              viewModel.imageFile = XFile("");
              viewModel.imageSelected = false;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                toolbarHeight: 80,
                title: const Text(
                  "Create a Group",
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
                                              viewModel.validateGroupName),

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
                                            child: SizedBox(
                                              height: 55,
                                              width: 55,
                                              child: viewModel.imageSelected
                                                  ? InkWell(
                                                      onTap: () {
                                                        viewModel.selectImage();
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
                                                  : FloatingActionButton(
                                                      backgroundColor:
                                                          Colors.grey.shade300,
                                                      elevation: 2,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100)),
                                                      onPressed: () {
                                                        viewModel.selectImage();
                                                      },
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 30,
                                                          color: Colors.grey,
                                                        ),
                                                      )),
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
                                  " Select Members",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                                const SizedBox(height: 15),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.grey.shade100,
                                    ),
                                    child: Column(
                                      children: [
                                        searchUsers((e) {
                                          viewModel.showAvailableUsers(e);
                                        }),
                                        const SizedBox(height: 15),
                                        Expanded(
                                          child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: viewModel
                                                  .searchedUsers.length,
                                              itemBuilder: (context, index) {
                                                return GroupMemberCard(
                                                    key: ValueKey(
                                                        viewModel.searchedUsers[
                                                            index]['uid']),
                                                    manageUser: () {
                                                      viewModel.addOrRemoveUsers(
                                                          viewModel
                                                                  .searchedUsers[
                                                              index]['uid']);
                                                    },
                                                    user: viewModel
                                                        .searchedUsers[index],
                                                    added: viewModel.usersToAdd
                                                        .contains(viewModel
                                                                .searchedUsers[
                                                            index]['uid']));
                                              }),
                                        ),

                                        // Column(children: [
                                        //   GroupMemberCard(user: {
                                        //     "userName": "Areeb",
                                        //     "profilePictureUrl": "",
                                        //     "uid": "5"
                                        //   }),
                                        //   GroupMemberCard(user: {
                                        //     "userName": "Umair",
                                        //     "profilePictureUrl": "",
                                        //     "uid": "3"
                                        //   })
                                        // ]),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        viewModel.isSubmitting
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
                  : Container(
                      margin: EdgeInsets.all(0),
                      color: Colors.transparent,
                      height: 70,
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 20, right: 20),
                      child: Center(
                        child: SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            enableFeedback: false,
                            highlightColor: primaryColor.withOpacity(0.7),
                            splashColor: Colors.blue.shade700,
                            color: primaryColor,
                            onPressed: viewModel.isSubmitting
                                ? () {}
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      if (viewModel.usersToAdd.length < 2) {
                                        viewModel
                                            .showCurvedBorderSnackBar(context);
                                      } else {
                                        viewModel.makeGroup(
                                            context,
                                            viewModel.imageFile,
                                            viewModel.groupName.text,
                                            viewModel.usersToAdd);
                                      }
                                    }
                                  },
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          );
        });
  }

  TextFormField textInput(
      title, controler, String? Function(String?)? validator) {
    return TextFormField(
      controller: controler,
      validator: validator,
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
          filled: true,
          hintText: title,
          fillColor: Colors.grey.shade200),
    );
  }
}
