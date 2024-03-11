import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picorix/router/app_router.dart';
import 'package:picorix/utils/helper_functions.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // if (!kIsWeb) {
  //   await MobileAds.instance.initialize();
  // }

  //await dotenv.load(fileName: ".env");
  bool? status = await HelperFunctions.getUserLoggedInStatus();
  runApp(MyApp(loggedin: status ?? false));
}

class MyApp extends StatelessWidget {
  final bool loggedin;
  const MyApp({super.key, required this.loggedin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'picorix',
      initialRoute: loggedin ? "/messageview" : '/',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
