import "package:flutter/material.dart";

Padding textInputField(controller, label, String? Function(String?)? validator,
    {String mode = 'String',
    leading,
    password = false,
    String toolTipMessage = ''}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
    child: TextFormField(
      keyboardType:
          mode == 'String' ? TextInputType.emailAddress : TextInputType.number,
      validator: validator,
      controller: controller,
      autofocus: false,
      obscureText: password ? true : false,

      decoration: InputDecoration(
        labelText: label,
        suffixIcon: toolTipMessage == ""
            ? null
            : Tooltip(
                showDuration: const Duration(seconds: 5),
                textAlign: TextAlign.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                message: toolTipMessage,
                preferBelow: false,
                triggerMode: TooltipTriggerMode.tap,
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.grey,
                ),
              ),
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 18),
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
