import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:picorix/services/Auth/AuthServices.dart';
import 'package:picorix/utils/helper_functions.dart';
import 'package:picorix/services/Firestore/firebase_firestor_services.dart';
import 'package:picorix/widgets/widgets.dart';
import 'package:stacked/stacked.dart';

class RegisterViewModel extends BaseViewModel {
  // FirebaseStorageServices firebaseStorageServices = FirebaseStorageServices();
  FirebaseFirestoreServices firebaseFirestoreServices =
      FirebaseFirestoreServices();
  BuildContext context;
  // final notificationService = NotificationService();
  RegisterViewModel({required this.context});
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();

  bool isLoading = false;
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

  String? validateName(String? value) {
    if (value!.length <= 3) {
      return 'Name should be at least 3 characters long';
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value!.length < 6) {
      return 'Password should be 6 characters long';
    } else {
      return null;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value!.isEmpty) {
      return "Empty Field";
    } else if (passwordController.text != value) {
      return "Passwords doesn't match";
    } else {
      return null;
    }
  }

  String? validatePhoneNo(String? value) {
    return RegExp(r"^((\+92)??(0)?)(3)([0-9]{9})$").hasMatch(value!)
        ? null
        : "Enter Correct Phone Number!";
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

  showSnackBarWarning(value, color) {
    showSnackbar(context, value, color);
  }

  Future signUp(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    List allUserNames = await FirebaseFirestore.instance
        .collection("users")
        .get()
        .then((value) => value.docs.map((e) => e["userName"]).toList());
    if (allUserNames.contains(userNameController.text)) {
      isLoading = false;
      notifyListeners();
      showSnackBarWarning("User Name already exists.", Colors.red);
      return;
    }
    await authService
        .registerUser(
            email: emailController.text, password: passwordController.text)
        .then((value) async {
      if (value == true) {
        final user = FirebaseAuth.instance.currentUser!;
        await firebaseFirestoreServices.addData("users", docId: user.uid, {
          "userName": userNameController.text,
          "uid": user.uid,
          "email": emailController.text,
          "profilePictureUrl": "",
          "isOnline": true,
          "lastOnline": DateTime.now().toUtc().toIso8601String(),
          "mobileNo": mobileNoController.text,
          "blockList": []
        });

        await authService.updateCurrentUserName(name: userNameController.text);

        await HelperFunctions.setInfo(
            "", user.uid, true, emailController.text, userNameController.text);

        isLoading = false;
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/messageview');
      } else {
        isLoading = false;
        notifyListeners();
        showSnackbar(context, value, Colors.red);
      }
    });
  }
}
