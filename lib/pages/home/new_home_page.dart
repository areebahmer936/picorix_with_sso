import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picorix/utils/helper_functions.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoggingOut = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Signed in"),
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: 80,
                      width: 80,
                      child: Image.network(user!.photoURL!)),
                  Text(
                    user!.email!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(user!.displayName!, style: TextStyle(fontSize: 17)),
                  const SizedBox(
                    height: 50,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        signOut();
                      },
                      child: Text("Sign out"))
                ]),
          ),
          isLoggingOut
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white.withOpacity(0.4),
                )
              : const SizedBox()
        ],
      ),
    );
  }

  signOut() {
    setState(() {
      isLoggingOut = true;
    });
    _auth.signOut().whenComplete(() {
      HelperFunctions.setUserLoggedInStatus(false);
      setState(() {
        isLoggingOut = false;
      });
      Navigator.pushReplacementNamed(context, "/login");
    });
  }
}
