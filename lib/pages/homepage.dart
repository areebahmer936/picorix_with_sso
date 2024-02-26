import 'package:flutter/material.dart';
import 'package:picorix/services/Auth/AuthServices.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  AuthService authService = AuthService();
  String post = "";

  registerUser() async {
    await authService
        .registerUser(email: "areebahmer.dev@gmail.com", password: "123456")
        .then((value) {
      if (value == true) {
        setState(() {
          post = "done";
        });
      } else {
        setState(() {
          post = value;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(post),
            SizedBox(
              height: 20,
              width: 20,
              child: MaterialButton(
                onPressed: () {
                  registerUser();
                },
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}
