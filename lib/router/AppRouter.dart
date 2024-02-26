import 'package:flutter/material.dart';
import 'package:picorix/pages/Auth/loginView.dart';
import 'package:picorix/pages/Extras/wordSearch.dart';
import 'package:picorix/pages/Others/NotFounf.dart';
import 'package:picorix/pages/home/HomePage.dart';
import 'package:picorix/pages/home/new_home_page.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/homepage':
        return MaterialPageRoute(builder: (_) => const HomePage());
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
