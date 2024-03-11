import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/User%20Search/search_user_viewmodel.dart';
import 'package:picorix/pages/User%20Search/widgets/search_user_Card.dart';
import 'package:stacked/stacked.dart';

class SearchUser extends StatelessWidget {
  const SearchUser({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => SearchViewModel(),
        onViewModelReady: (viewModel) {
          viewModel.initializeCurrentUser(context).whenComplete(() {
            viewModel.isListLoading = false;
            viewModel.notifyListeners();
          });
        },
        builder: (context, viewModel, child) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: searchField((e) {
                            viewModel.showAvailableUsers(e);
                          }, viewModel.searchController, viewModel.searchMode)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FilterChip(
                                side: BorderSide(color: Colors.transparent),
                                checkmarkColor: primaryColor,
                                shadowColor: primaryColor.withOpacity(0.4),
                                label: const Text(
                                  "Username",
                                  style: TextStyle(
                                      fontSize: 11, color: primaryColor),
                                ),
                                elevation: 3,
                                selectedColor:
                                    const Color.fromARGB(255, 195, 226, 251),
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                selected: viewModel.searchMode == "Username",
                                onSelected: (bool selected) {
                                  viewModel.searchMode = "Username";
                                  viewModel.searchController.text = "";
                                  viewModel.searchedUsers = viewModel.users;
                                  viewModel.notifyListeners();
                                }),
                            const SizedBox(
                              width: 10,
                            ),
                            FilterChip(
                                side:
                                    const BorderSide(color: Colors.transparent),
                                checkmarkColor: primaryColor,
                                shadowColor: primaryColor.withOpacity(0.4),
                                disabledColor: Colors.white,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                label: const Text("Class",
                                    style: TextStyle(
                                        fontSize: 11, color: primaryColor)),
                                elevation: 3,
                                selectedColor:
                                    const Color.fromARGB(255, 195, 226, 251),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100)),
                                selected: viewModel.searchMode == "Class",
                                onSelected: (bool selected) {
                                  viewModel.searchMode = "Class";
                                  viewModel.searchController.text = "";
                                  viewModel.searchedUsers = viewModel.users;

                                  viewModel.notifyListeners();
                                }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          controller: viewModel.scrollController,
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                addAutomaticKeepAlives: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: viewModel.searchedUsers.length,
                                itemBuilder: (context, index) {
                                  return SearchUserCard(
                                    key: ValueKey(
                                        viewModel.searchedUsers[index]["uid"]),
                                    currUserId: viewModel.uid!,
                                    user: viewModel.searchedUsers[index],
                                    added: viewModel.searchedUsers[index]
                                        ['added'],
                                  );
                                }),
                            viewModel.isLoadingMore
                                ? SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.grey.shade400),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          "Loading More ...",
                                          style: TextStyle(
                                              color: Colors.grey.shade400),
                                        )
                                      ],
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                    ],
                  ),
                  viewModel.isListLoading
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.4),
                          child: const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor),
                          ),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          );
        });
  }

  searchField(Function(String keyword) searchUsers, controller, searchMode) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SizedBox(
          height: 50,
          child: TextFormField(
            controller: controller,
            onChanged: (value) {
              searchUsers.call(value);
            },
            decoration: InputDecoration(
              hintText: searchMode == "Class"
                  ? "Search by Class"
                  : "Search by Username",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              isDense: true,
              prefixIcon: Container(
                width: 20,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/Icons/search.svg",
                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                    height: 30,
                  ),
                ),
              ),
              fillColor: Colors.grey.shade300,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ));
  }
}
