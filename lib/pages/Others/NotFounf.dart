import 'package:flutter/material.dart';

class NotFound extends StatefulWidget {
  const NotFound({super.key});

  @override
  State<NotFound> createState() => _NotFoundState();
}

class _NotFoundState extends State<NotFound> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Page Not Found"),
      ),
    );
  }
}
