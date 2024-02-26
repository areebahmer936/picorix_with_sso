import 'package:flutter/material.dart';

// InputDecoration inputTextDec = InputDecoration(
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(10.0),
//     borderSide: const BorderSide(color: secondaryColor, width: 0.5),
//   ),
//   enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(10.0),
//     borderSide: const BorderSide(color: secondaryColor, width: 0.5),
//   ),
//   errorBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(10.0),
//     borderSide:
//         const BorderSide(color: Color.fromARGB(255, 206, 0, 0), width: 0.5),
//   ),
//   labelStyle: const TextStyle(
//     fontWeight: FontWeight.w500,
//     fontStyle: FontStyle.normal,
//     fontSize: 12,
//     color: secondaryColor,
//   ),
//   filled: true,
//   fillColor: const Color(0xfff2f2f3),
//   // isDense: true,
//   contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
// );

TextStyle textStyle = const TextStyle(
  fontWeight: FontWeight.w500,
  fontStyle: FontStyle.normal,
  fontSize: 15,
  color: Color(0xff006a00),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplacement(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, message, color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}

const formFeildColorFill = Color.fromARGB(255, 240, 240, 240);

const boxShadow = [
  BoxShadow(
    offset: Offset(0, 1.5),
    blurRadius: 1,
    color: Colors.black26,
  )
];

final boxdeco = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    image: const DecorationImage(image: AssetImage(''), fit: BoxFit.fill),
    boxShadow: const [
      BoxShadow(
        offset: Offset(0, 1.5),
        blurRadius: 2,
        color: Colors.black26,
      )
    ]);
