import 'package:flutter/material.dart';

class PasswordInputField extends StatefulWidget {
  final controller;
  final label;
  final String? Function(String?)? validator;

  const PasswordInputField(
      {super.key,
      required this.controller,
      required this.label,
      required this.validator});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool ishidden = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        autofocus: false,
        obscureText: ishidden ? true : false,

        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: !ishidden
                ? const Icon(
                    Icons.visibility,
                    color: Colors.grey,
                  )
                : const Icon(
                    Icons.visibility_off,
                    color: Colors.grey,
                  ),
            onPressed: () {
              setState(() {
                ishidden = !ishidden;
              });
            },
          ),
          labelText: widget.label,
          contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20, vertical: 18),
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 240, 240, 240),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 240, 240, 240),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xffE21C3D),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xffE21C3D),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 240, 240, 240),
        ),

        style: const TextStyle(
            fontFamily: "Ubuntu",
            fontWeight: FontWeight.w400,
            fontSize: 17,
            color: Color.fromARGB(255, 50, 50, 50)),

        // validator:
      ),
    );
  }
}
