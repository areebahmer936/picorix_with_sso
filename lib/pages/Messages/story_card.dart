// import 'package:magika_chat/models/app_user.dart';
// import "dart:math";
// import 'package:flutter/material.dart';

// class StoryCard extends StatelessWidget {
//   final AppUser user;
//   final bool viewed;

//   StoryCard({super.key, required this.user, required this.viewed});

//   final colorLists = [
//     Colors.amber,
//     Colors.blue,
//     Colors.pink,
//     Colors.red,
//     Colors.green
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           Container(
//             height: size.height * 0.084,
//             width: size.height * 0.084,
//             decoration: BoxDecoration(
//                 border: Border.all(
//                     color: colorLists[Random().nextInt(colorLists.length)]),
//                 color: Colors.transparent,
//                 borderRadius: BorderRadius.circular(100)),
//             child: Center(
//                 child: Container(
//               height: size.height * 0.075,
//               width: size.height * 0.075,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(100),
//                   color: Colors.white),
//               child: ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child: Image.network(user.profilePictureUrl)),
//             )),
//           ),
//           SizedBox(height: 5),
//           Text(
//             user.name,
//             style: const TextStyle(
//                 color: Colors.white, fontSize: 10, overflow: TextOverflow.fade),
//           )
//         ],
//       ),
//     );
//   }
// }
