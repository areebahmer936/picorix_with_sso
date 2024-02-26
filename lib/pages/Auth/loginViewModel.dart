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
        final uid = FirebaseAuth.instance.currentUser!.uid;
        String role = await authService.emailConfirmationForUserRoles(
            uid: FirebaseAuth.instance.currentUser!.uid);
        print(role);

        DocumentSnapshot docSnp =
            await firebaseFirestoreServices.getUserData(role, uid);
        print(docSnp.data());

        Map<String, dynamic> userData = docSnp.data() as Map<String, dynamic>;
        await authService.updateCurrentUserName(name: userData["nameId"]);
        await HelperFunctions.setProfilePicture(userData["profilePicture"]);
        await HelperFunctions.setUid(userData['uid']);
        await HelperFunctions.setUserLoggedInStatus(true);
        await HelperFunctions.setUserEmailSf(emailController.text);
        await HelperFunctions.setUserNameSf(
            FirebaseAuth.instance.currentUser!.displayName!);
        await HelperFunctions.setUserRole(role == 'other' ? 'Admin' : role);
        await HelperFunctions.setEmailVerificatiedStatus(role == "Admin"
            ? true
            : FirebaseAuth.instance.currentUser!.emailVerified);
        if (role == "Users") {
          isLoadingPage = true;
          notifyListeners();
          Navigator.pushReplacementNamed(context, '/homepage');
          //   isLoadingPage = true;
          //   notifyListeners();
          //   // ignore: use_build_context_synchronously
          //   nextScreenReplacement(
          //       context,
          //       FirebaseAuth.instance.currentUser!.emailVerified
          //           ? const DashBoard()
          //           : const EmailVerificationScreen());
        } else if (role == 'Admin') {
          Navigator.pushReplacementNamed(context, '/adminpanel');
        }
        // } else {
        //   // ignore: use_build_context_synchronously
        //   nextScreenReplacement(
        //       context,
        //       FirebaseAuth.instance.currentUser!.emailVerified
        //           ? const VetHomeView()
        //           : const DocEmailVerificationScreen());
        // }
      } else {
        showSnackbar(context, value, Colors.red);
      }
    });
  }
}
