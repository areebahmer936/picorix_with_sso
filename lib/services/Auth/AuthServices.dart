import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:picorix/utils/helper_functions.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;

  Future loginUser({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future registerUser({required String email, required String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return e.message;
    }
  }

  Future signInWithAppleId() async {
    // final result = await App
    final UserCredential auth =
        await firebaseAuth.signInWithProvider(AppleAuthProvider());
    if (auth.user != null) {
      print(auth.user!.email!);
      return true;
    }
  }

  Future signInWithFacebook() async {
    try {
      final LoginResult loginResult =
          await facebookAuth.login(permissions: ["email"]);
      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential oAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        try {
          final user = await firebaseAuth.signInWithCredential(oAuthCredential);
          if (user.additionalUserInfo!.isNewUser) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.user!.uid)
                .set({
              "userName": user.user!.displayName,
              "uid": user.user!.uid,
              "email": user.user!.email,
              "profilePictureUrl": user.user!.photoURL ?? "",
              "isOnline": true,
              "lastOnline": DateTime.now().toUtc().toIso8601String(),
              "mobileNo": "",
              "blockList": []
            });
          }
          await HelperFunctions.setInfo(user.user!.photoURL ?? "",
              user.user!.uid, true, user.user!.email, user.user!.displayName);
          return true;
        } on FirebaseAuthException catch (e) {
          print(e.toString());
          return e.message.toString();
        }
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      try {
        final user =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (user.additionalUserInfo!.isNewUser) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.user!.uid)
              .set({
            "userName": user.user!.displayName,
            "uid": user.user!.uid,
            "email": user.user!.email,
            "profilePictureUrl": user.user!.photoURL ?? "",
            "isOnline": true,
            "lastOnline": DateTime.now().toUtc().toIso8601String(),
            "mobileNo": "",
            "blockList": []
          });
        }
        await HelperFunctions.setInfo(user.user!.photoURL ?? "", user.user!.uid,
            true, user.user!.email, user.user!.displayName);

        return true;
      } on FirebaseAuthException catch (e) {
        print(e.toString());
        return e.message.toString();
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  Future signOut(context) async {
    try {
      await HelperFunctions.setUserLoggedInStatus(false);
      await HelperFunctions.setUserEmailSf("");
      await HelperFunctions.setUserNameSf("");
      await HelperFunctions.setProfilePicture("");
      await HelperFunctions.setUid('');

      await firebaseAuth.signOut();
      Navigator.pushReplacementNamed(context, "/login");
    } on FirebaseException catch (e) {
      return e.message.toString();
    }
  }

  Future<void> updateCurrentUserName({required String name}) async {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
  }

  Future<String> emailConfirmationForUserRoles({required String uid}) async {
    DocumentSnapshot documentReferenceAdmin =
        await FirebaseFirestore.instance.collection("Admin").doc(uid).get();
    if (documentReferenceAdmin.exists) {
      return "Admin";
    } else {
      return "Users";
    }
  }
}
