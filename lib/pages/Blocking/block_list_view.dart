import 'package:flutter/material.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Blocking/block_list_viewmodel.dart';
import 'package:picorix/pages/Blocking/widgets/blocked_user_card.dart';
import "package:stacked/stacked.dart";

class BlockListView extends StatelessWidget {
  const BlockListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => BlockListViewModel(),
        onViewModelReady: (viewModel) async {
          await viewModel.fetchBlockedUsers();
        },
        builder: (context, viewModel, child) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 252, 252, 252),
              appBar: AppBar(
                centerTitle: true,
                surfaceTintColor: Colors.white,
                title: const Text("Blocked Users"),
                elevation: 5,
                shadowColor: Colors.grey.shade100,
                toolbarHeight: 70,
              ),
              body: viewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: viewModel.blockedUsers.isEmpty
                              ? const Center(
                                  child: Text("Nothing to show here",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 20)),
                                )
                              : ListView.builder(
                                  itemCount: viewModel.blockedUsers.length,
                                  itemBuilder: (context, index) {
                                    return BlockedUserCard(
                                        onUnblock: () {
                                          viewModel.unblockUser(
                                              viewModel.blockedUsers[index]
                                                  ["uid"],
                                              index);
                                        },
                                        user: viewModel.blockedUsers[index]);
                                  }),
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
            ),
          );
        });
  }
}
