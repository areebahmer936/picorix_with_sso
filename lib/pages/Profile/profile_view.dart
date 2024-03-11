import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/models/app_user.dart';
import 'package:picorix/pages/Profile/profile_viewmodel.dart';
import 'package:picorix/utils/cache_image_service.dart';
import "package:stacked/stacked.dart";

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ProfileView extends StatelessWidget {
  final AppUser? user;
  final String? uid;
  const ProfileView({super.key, this.user, this.uid});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => ProfileViewModel(user: user, uid: uid),
        onViewModelReady: (vm) async {
          await vm.initializeProfile();
        },
        builder: (context, viewModel, child) {
          return PopScope(
            onPopInvoked: (didPop) {
              if (viewModel.justBlocked) {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Navigator.pop(context);
                });
              }
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                toolbarHeight: 80,
                leading: const BackButton(
                  color: Colors.white,
                ),
                backgroundColor: Colors.transparent,
              ),
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
                          Color.fromARGB(255, 97, 255, 147)
                        ],
                            stops: [
                          0.01,
                          0.2,
                          0.45,
                          1
                        ])),
                    child: viewModel.isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : Column(children: [
                            SizedBox(
                              height: size.height * 0.15,
                            ),
                            Column(
                              children: [
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: cachedProfilePicture(viewModel
                                        .profileInfo.profilePictureUrl),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  viewModel.profileInfo.userName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeInOut,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 30,
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 211, 235, 255),
                                    borderRadius: BorderRadius.circular(12)),
                                child: viewModel.onlineStatus
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              "Online",
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 12),
                                            )
                                          ])
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Text(
                                              viewModel.lastOnline,
                                              style: const TextStyle(
                                                  color: primaryColor,
                                                  fontSize: 12),
                                            )
                                          ]),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            viewModel.isMe
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        !viewModel.isFriend
                                            ? InkWell(
                                                onTap: () {
                                                  showSnackBarWarning(context,
                                                      "You must add user first");
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: Colors.white
                                                          .withOpacity(0.2)),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      "assets/Icons/message.svg",
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              Colors.grey
                                                                  .shade400,
                                                              BlendMode.srcIn),
                                                      height: 30,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  viewModel
                                                      .navigateToChat(context);
                                                },
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      color: Colors.white
                                                          .withOpacity(0.4)),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      "assets/Icons/message.svg",
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                              Colors.white,
                                                              BlendMode.srcIn),
                                                      height: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(width: 20),
                                        InkWell(
                                          onTap: viewModel.isMeBlocked
                                              ? () {
                                                  showSnackBarWarning(context,
                                                      "This user has blocked you");
                                                }
                                              : () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            20.0),
                                                      ),
                                                    ),
                                                    builder:
                                                        (BuildContext context) {
                                                      return Container(
                                                        padding: EdgeInsets.all(
                                                            20.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            viewModel.isBlocked
                                                                ? const SizedBox()
                                                                : viewModel
                                                                        .isFriend
                                                                    ? ListTile(
                                                                        leading:
                                                                            const Icon(Icons.remove),
                                                                        title: const Text(
                                                                            'Remove'),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          viewModel
                                                                              .removeUser();
                                                                        },
                                                                      )
                                                                    : ListTile(
                                                                        leading:
                                                                            const Icon(Icons.add),
                                                                        title: const Text(
                                                                            'Add'),
                                                                        onTap:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          viewModel
                                                                              .userAdd();
                                                                        },
                                                                      ),
                                                            viewModel.isBlocked
                                                                ? ListTile(
                                                                    leading:
                                                                        const Icon(
                                                                            Icons.block),
                                                                    title: const Text(
                                                                        'Unblock User'),
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      viewModel
                                                                          .unblockUser();
                                                                    },
                                                                  )
                                                                : ListTile(
                                                                    leading:
                                                                        const Icon(
                                                                            Icons.block),
                                                                    title: const Text(
                                                                        'Block User'),
                                                                    onTap: () {
                                                                      // Add your block user logic here
                                                                      Navigator.pop(
                                                                          context);
                                                                      viewModel
                                                                          .blockUser(
                                                                              context);
                                                                    },
                                                                  ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                          child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.white
                                                    .withOpacity(0.4)),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                "assets/Icons/more.svg",
                                                colorFilter: ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn),
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                            const SizedBox(
                              height: 30,
                            ),
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              width: double.infinity,
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Display Name",
                                      style: TextStyle(
                                          color: Colors.grey.shade300),
                                    ),
                                    Text(
                                      " ${viewModel.profileInfo.userName}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Email Address",
                                      style: TextStyle(
                                          color: Colors.grey.shade300),
                                    ),
                                    Text(
                                      " ${viewModel.profileInfo.email}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Phone Number",
                                      style: TextStyle(
                                          color: Colors.grey.shade300),
                                    ),
                                    Text(
                                      " ${viewModel.profileInfo.mobileNo == "" ? "-" : viewModel.profileInfo.mobileNo}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ]),
                            )),
                          ]),
                  ),
                  viewModel.isProcessing
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.3),
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

  showSnackBarWarning(context, message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade400,
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message)));
  }
}
