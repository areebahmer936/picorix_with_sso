import 'package:flutter/material.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Chats/Forwarding/message_forward_viewmodel.dart';
import 'package:picorix/pages/Chats/Forwarding/widgets/forward_user_card.dart';
import "package:stacked/stacked.dart";

class MessageForwardView extends StatelessWidget {
  final String msgUid;
  final String chatRoomId;
  const MessageForwardView(
      {super.key, required this.msgUid, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () =>
            MessageForwardViewModel(msgUid: msgUid, chatRoomId: chatRoomId),
        onViewModelReady: (model) {
          model.getChats().then((value) {
            model.isLoading = false;
            model.notifyListeners();
          });
        },
        onDispose: (model) {
          model.dispose();
        },
        builder: (context, viewModel, child) {
          final size = MediaQuery.of(context).size;
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                              height: size.height * 0.75,
                              width: size.width * 0.9,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  color: Colors.white),
                              child: viewModel.isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          searchUsers((keyword) => viewModel
                                              .showAvailableUsers(keyword)),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: ListView.builder(
                                                addAutomaticKeepAlives: true,
                                                shrinkWrap: true,
                                                // physics: NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.vertical,
                                                itemCount:
                                                    viewModel.chats.length,
                                                itemBuilder: (context, index) {
                                                  return ForwardUserCard(
                                                      key: ValueKey(
                                                          viewModel.chats[index]
                                                              ["chatRoomId"]),
                                                      userData: viewModel
                                                          .chats[index],
                                                      selected: viewModel
                                                          .toForward
                                                          .contains(viewModel
                                                                  .chats[index]
                                                              ["chatRoomId"]),
                                                      onSelected: () {
                                                        viewModel.addToForward(
                                                            viewModel.chats[
                                                                    index]
                                                                ["chatRoomId"]);
                                                        viewModel
                                                            .notifyListeners();
                                                      });
                                                }),
                                          ),
                                        ])),
                          Container(
                            width: size.width * 0.9,
                            height: size.height * 0.05,
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: Colors.grey.shade200)),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20)),
                                color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                    style: const ButtonStyle(
                                        enableFeedback: false,
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor),
                                    )),
                                const VerticalDivider(),
                                TextButton(
                                    style: const ButtonStyle(
                                        enableFeedback: false,
                                        splashFactory: NoSplash.splashFactory),
                                    onPressed: () {
                                      viewModel.forward(context);
                                    },
                                    child: const Text(
                                      "Forward",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor),
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                      viewModel.isForwarding
                          ? Container(
                              height: size.height * 0.8,
                              width: size.width * 0.9,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20)),
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
              ),
            ),
          );
        });
  }

  searchUsers(Function(String keyword) searchUsers) {
    return TextFormField(
      onChanged: (keyword) {
        searchUsers.call(keyword);
      },
      decoration: InputDecoration(
        fillColor: Colors.grey.shade200,
        filled: true,
        isDense: true,
        hintText: "Search users to add",
        hintStyle: TextStyle(color: Colors.grey.shade300),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5))),
      ),
    );
  }
}
