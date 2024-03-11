import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picorix/services/Auth/AuthServices.dart';
import 'package:picorix/utils/helper_functions.dart';
import 'package:picorix/services/Firestore/firebase_firestor_services.dart';
import 'package:picorix/widgets/widgets.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends BaseViewModel {
  // FirebaseStorageServices firebaseStorageServices = FirebaseStorageServices();
  FirebaseFirestoreServices firebaseFirestoreServices =
      FirebaseFirestoreServices();

  // final notificationService = NotificationService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isLoadingPage = false;
  AuthService authService = AuthService();

  // askPermissions() async {
  //   return notificationService.requestNotificationPermission();
  // }

  String? validateEmail(String? value) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(value!)
        ? null
        : "Enter a Correct Email!";
  }

  String? validatePassword(String? value) {
    if (value!.length < 6) {
      return 'Password should be 6 characters long';
    } else {
      return null;
    }
  }

  Future signInWithGoogle() async {
    return await authService.signInWithGoogle();
  }

  Future signInWithApple() async {
    return await authService.signInWithAppleId();
  }

  Future signInWithFacebook() async {
    return await authService.signInWithFacebook();
  }

  Future login(BuildContext context) async {
    await authService
        .loginUser(
            email: emailController.text, password: passwordController.text)
        .then((value) async {
      if (value == true) {
        final user = FirebaseAuth.instance.currentUser!;

        DocumentSnapshot docSnp = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        Map<String, dynamic> userData = docSnp.data() as Map<String, dynamic>;
        await HelperFunctions.setInfo(userData["profilePictureUrl"], user.uid,
            true, user.email, userData["username"]);
        await authService.updateCurrentUserName(name: userData["username"]);

        isLoadingPage = true;
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/messageview');
      } else {
        showSnackbar(context, value, Colors.red);
      }
    });
  }
}
