import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Groups/widgets/group_members_card.dart';
import "package:stacked/stacked.dart";
import 'group_info_viewmodel.dart';

class GroupInfoView extends StatelessWidget {
  final Map groupInfo;
  final String chatRoomId;
  final List members;
  final bool isRemoved;
  final formKey = GlobalKey<FormState>();
  GroupInfoView(
      {super.key,
      required this.groupInfo,
      required this.chatRoomId,
      required this.members,
      required this.isRemoved});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => GroupInfoViewModel(
            groupInfo: groupInfo, chatRoomId: chatRoomId, members: members),
        onViewModelReady: (viewModel) {
          viewModel.initializeCurrentUser().whenComplete(() {
            viewModel.isLoading = false;
            viewModel.notifyListeners();
          });
        },
        builder: (context, viewModel, child) {
          return PopScope(
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
                    : Padding(
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
                                              fontSize: 16, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 10),
                                        textInput(
                                            "Enter a name", viewModel.groupName,
                                            enable: false),
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
                                              fontSize: 16, color: Colors.grey),
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
                                              child: ClipRRect(
                                                  clipBehavior: Clip.antiAlias,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: viewModel.pictureUrl ==
                                                          ""
                                                      ? Center(
                                                          child:
                                                              SvgPicture.asset(
                                                            "assets/app/groupPlaceholder.svg",
                                                            colorFilter:
                                                                const ColorFilter
                                                                    .mode(
                                                                    Colors
                                                                        .white,
                                                                    BlendMode
                                                                        .srcIn),
                                                          ),
                                                        )
                                                      : Image.network(
                                                          viewModel.pictureUrl!,
                                                          fit: BoxFit.cover,
                                                        ))),
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
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 15),
                              Expanded(
                                flex: 1, //viewModel.isOwner! ? 1 : 0,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: viewModel.searchedUsers.length,
                                      itemBuilder: (context, index) {
                                        return GroupMemberCard(
                                          key: ValueKey(viewModel
                                              .searchedUsers[index]['uid']),
                                          manageUser: () {},
                                          user: viewModel.searchedUsers[index],
                                          added: false,
                                          interact: false,
                                          isMember: viewModel.groupOwner !=
                                              viewModel.searchedUsers[index]
                                                  ['uid'],
                                        );
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                resizeToAvoidBottomInset: true,
                bottomNavigationBar: isRemoved
                    ? Container(
                        height: 70,
                        width: double.infinity,
                        color: Colors.red,
                        child: const Center(
                            child: Text(
                          "This group has been removed.",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                      )
                    : const SizedBox()),
          );
        });
  }

  TextFormField textInput(title, controler, {enable = true}) {
    return TextFormField(
      enabled: enable,
      controller: controler,
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
}
