import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picorix/pages/Auth/Login/login_view.dart';
import 'package:picorix/pages/Auth/Register/register_view.dart';
import 'package:picorix/pages/Blocking/block_list_view.dart';
import 'package:picorix/pages/Chats/Forwarding/message_forward_view.dart';
import 'package:picorix/pages/Extras/wordSearch.dart';
import 'package:picorix/pages/Groups/create_group_view.dart';
import 'package:picorix/pages/Groups/groupEdit/group_edit_view.dart';
import 'package:picorix/pages/Groups/groupView/group_info_view.dart';
import 'package:picorix/pages/Groups/widgets/all_done_view.dart';
import 'package:picorix/pages/Messages/messages_view.dart';
import 'package:picorix/pages/Others/NotFounf.dart';
import 'package:picorix/pages/Profile/profile_view.dart';
import 'package:picorix/pages/User%20Search/search_user_view.dart';
import 'package:picorix/pages/home/new_home_page.dart';
import 'package:picorix/router/transitions.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case '/messageview':
        final myUid = FirebaseAuth.instance.currentUser!.uid;
        return MaterialPageRoute(
            builder: (_) => MessagesView(
                  userUid: myUid,
                ));
      case '/search':
        return downToTop(const SearchUser());
      case '/creategroup':
        return MaterialPageRoute(builder: (_) => CreateGroupView());
      case '/alldone':
        return MaterialPageRoute(builder: (_) => const AllDone());
      case '/blocklist':
        return MaterialPageRoute(builder: (_) => const BlockListView());
      case '/forwardmessage':
        Map<String, dynamic> msgInfo =
            settings.arguments as Map<String, dynamic>;
        return createRouteBlurredBackground(MessageForwardView(
          msgUid: msgInfo['msgUid'],
          chatRoomId: msgInfo["chatRoomId"],
        ));

      case '/profile':
        Map<String, dynamic> user = settings.arguments as Map<String, dynamic>;
        if (user["user"] == null) {
          return MaterialPageRoute(
              builder: (_) => ProfileView(
                    uid: user["uid"],
                  ));
        } else {
          return MaterialPageRoute(
              builder: (_) => ProfileView(
                    user: user["user"],
                  ));
        }

      case '/groupeditinfo':
        Map info = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => GroupEditView(
                groupInfo: info['groupInfo'],
                chatRoomId: info['chatRoomId'],
                members: info['members'],
                isRemoved: info['isRemoved']));
      case '/groupviewinfo':
        Map info = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => GroupInfoView(
                groupInfo: info['groupInfo'],
                chatRoomId: info['chatRoomId'],
                members: info['members'],
                isRemoved: info['isRemoved']));
      case '/newhomepage':
        return MaterialPageRoute(builder: (_) => const NewHomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/wordsearch':
        return MaterialPageRoute(builder: (_) => WordSearchGame());
      default:
        return MaterialPageRoute(builder: (_) => const NotFound());
    }
  }
}
