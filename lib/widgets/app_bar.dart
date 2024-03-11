import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:picorix/config/themedata.dart';

AppBar customAppBar(
    VoidCallback createGroup, VoidCallback blocklist, VoidCallback logOut,
    {context, profilePicture, page = 0}) {
  return AppBar(
    actions: [
      page == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: IconButton(
                  onPressed: () {
                    showMenu(
                        context: context,
                        color: Colors.white,
                        surfaceTintColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        position: const RelativeRect.fromLTRB(100, 100, 20, 0),
                        items: [
                          PopupMenuItem(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            onTap: () {
                              createGroup();
                            },
                            child: Text('Create Group'),
                          ),
                          PopupMenuItem(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            onTap: () {
                              blocklist();
                            },
                            child: Text('Blocklist'),
                          ),
                          PopupMenuItem(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            onTap: () =>
                                showConfirmationDialog(context, () => logOut()),
                            child: const Text('Log out'),
                          )
                        ]);
                  },
                  icon: SvgPicture.asset("assets/Icons/menu.svg"))
              // Container(
              //     height: 60,
              //     width: 60,
              //     decoration: BoxDecoration(
              //       border: Border.all(
              //           width: 3, color: Colors.white.withOpacity(0.3)),
              //       borderRadius: BorderRadius.circular(100),
              //       color: blue.withOpacity(0.5),
              //     ),
              //     child: ClipRRect(
              //         borderRadius: BorderRadius.circular(100),
              //         child: profilePicture == null
              //             ? SvgPicture.asset(
              //                 "assets/app/placeHolderAvatar.svg",
              //                 fit: BoxFit.scaleDown,
              //               )
              //             : Image.network(profilePicture))),
              )
          : page == 1
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          "assets/app/makeCall.svg",
                          height: 30,
                        ),
                      )),
                )
              : page == 2
                  ? Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                "assets/app/addContact.svg",
                                height: 23,
                              ),
                            ),
                          )),
                    )
                  : const SizedBox()
    ],
    leading: page == 3
        ? null
        : Padding(
            padding: const EdgeInsets.all(25.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/search');
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/search");
                    },
                    icon: SvgPicture.asset(
                      "assets/Icons/search.svg",
                    ),
                    iconSize: 35,
                  )),
            ),
          ),
    title: Text(
      page == 0
          ? "Home"
          : page == 1
              ? "Calls"
              : page == 2
                  ? "Contacts"
                  : "Settings",
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
    ),
    centerTitle: true,
    elevation: 0,
    leadingWidth: 100,
    toolbarHeight: 100,
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
  );
}

Future<void> showConfirmationDialog(
    BuildContext context, VoidCallback onConfirm) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to Log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
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
            child: const Text('Cancel', style: TextStyle(color: primaryColor)),
          ),
        ],
      );
    },
  );
}
