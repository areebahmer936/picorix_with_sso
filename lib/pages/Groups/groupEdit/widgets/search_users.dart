import 'package:flutter/material.dart';
import 'package:picorix/config/themedata.dart';

searchUsers(Function(String keyword) searchUsers, enabled) {
  return TextFormField(
    enabled: enabled,
    onChanged: (keyword) {
      searchUsers.call(keyword);
    },
    decoration: InputDecoration(
      fillColor: Colors.white,
      filled: true,
      isDense: true,
      hintText: "Search users to add",
      hintStyle: TextStyle(color: Colors.grey.shade300),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5))),
    ),
  );
}
