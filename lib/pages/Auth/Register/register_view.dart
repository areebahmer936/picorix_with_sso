import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Auth/Register/register_view_model.dart';
import 'package:picorix/widgets/TextInputFeild.dart';
import 'package:picorix/widgets/pass_Input_field.dart';
import 'package:stacked/stacked.dart';
import 'dart:math';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final formKey = GlobalKey<FormState>();
  bool isProcessing = false;
  bool isGoogleLoading = false;
  // final notificationService = NotificationService();

  final bool _isLoading = false;
  @override
  void initState() {
    // notificationService.requestNotificationPermission();
    // notificationService.getDeviceToken().then((value) => print(value));
    // // TODO: implement initState
    super.initState();
  }

  // Helper functions
  String randomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => RegisterViewModel(context: context),
        onViewModelReady: (model) {
          if (kDebugMode) {
            final random = Random(); // Standard random number generator

            // Email
            String randomEmail = '${randomString(10)}@gmail.com';
            model.emailController.text = randomEmail;

            // Mobile Number
            String randomMobileNo =
                '03${random.nextInt(99999)}${random.nextInt(9999)}';
            model.mobileNoController.text = randomMobileNo;

            // Password (Simplified)
            String randomPassword = randomString(6);
            model.passwordController.text = randomPassword;
            model.confirmPasswordController.text = randomPassword;

            // Username
            String randomUsername = randomString(6).toLowerCase();
            model.userNameController.text = randomUsername;
          }
        },
        builder: (context, viewModel, child) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/bg2.jpg"),
                          fit: BoxFit.fill,
                          opacity: 0.5),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                            color: primaryColor,
                          ))
                        : SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 16, 30, 0),
                                      child: Text(
                                        "Sign up",
                                        style: GoogleFonts.luckiestGuy()
                                            .copyWith(fontSize: 40),
                                        //       textTheme.headlineLarge!.copyWith(
                                        //     fontSize: 40,
                                        //     fontWeight: FontWeight.w500,
                                      ),
                                    ),

                                    // Email Field
                                    const SizedBox(height: 10),
                                    textInputField(viewModel.userNameController,
                                        'User Name', viewModel.validateName,
                                        toolTipMessage:
                                            "Every user has a unique user name. Try adding some non alphabetical characters if your name is already taken"),

                                    textInputField(viewModel.emailController,
                                        'Email', viewModel.validateEmail),

                                    // Password Field
                                    PasswordInputField(
                                        controller:
                                            viewModel.passwordController,
                                        label: "Password",
                                        validator: viewModel.validatePassword),
                                    PasswordInputField(
                                        controller:
                                            viewModel.confirmPasswordController,
                                        label: "Confirm Password",
                                        validator:
                                            viewModel.validateConfirmPassword),
                                    textInputField(
                                        viewModel.mobileNoController,
                                        'Phone Number',
                                        viewModel.validatePhoneNo),

                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 10),
                                        child: SizedBox(
                                          height: 60,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: MaterialButton(
                                              onPressed: () {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    viewModel.isLoading = true;
                                                  });
                                                  viewModel
                                                      .signUp(context)
                                                      .whenComplete(() {
                                                    setState(() {
                                                      viewModel.isLoading =
                                                          false;
                                                    });
                                                  });
                                                }
                                              },
                                              color: primaryColor,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        viewModel.isLoading
                                                            ? 10
                                                            : 10.0),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              textColor:
                                                  const Color(0xffffffff),
                                              height: 40,
                                              child: viewModel.isLoading
                                                  ? const SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Text("Sign Up",
                                                      style: GoogleFonts
                                                              .luckiestGuy()
                                                          .copyWith(
                                                              fontSize:
                                                                  20) //textTheme.bodyLarge
                                                      )),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text.rich(
                                              TextSpan(
                                                text:
                                                    " Already have an account?",
                                                style: const TextStyle(
                                                    color: Color(0xff006a00),
                                                    fontSize: 14),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: " Login",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Navigator
                                                                  .pushNamed(
                                                                      context,
                                                                      '/login');
                                                            }),
                                                ],
                                              ),
                                            ),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(" OR ",
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w900)),
                                            ),
                                            Expanded(
                                                child: Divider(
                                              color: Colors.grey.shade400,
                                            ))
                                          ]),
                                    ),

                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                isGoogleLoading = true;
                                              });
                                              viewModel
                                                  .signInWithGoogle()
                                                  .then((value) {
                                                if (value == true) {
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                          context,
                                                          "/messageview",
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                } else {
                                                  setState(() {
                                                    viewModel.isLoading = false;
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content:
                                                              Text(value)));
                                                }
                                              });
                                            },
                                            child: Container(
                                              height: 60,
                                              width: 250,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors
                                                            .grey.shade300,
                                                        blurRadius: 10)
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Colors.white),
                                              child: isGoogleLoading
                                                  ? SizedBox(
                                                      height: 80,
                                                      child: Lottie.asset(
                                                        "assets/app/google_loading.json",
                                                        repeat: true,
                                                        frameRate:
                                                            FrameRate.max,
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                          height: 25,
                                                          child: Center(
                                                            child: ClipOval(
                                                              child: Image.asset(
                                                                  'assets/app/google.png'),
                                                            ),
                                                          ),
                                                        ),
                                                        const Text(
                                                          "sign in with google",
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                            ),
                                          )

                                          // --------- Google Button Round ------------
                                          // InkWell(
                                          //   onTap: () {
                                          //     setState(() {
                                          //       viewModel.isLoading = true;
                                          //     });
                                          //     viewModel
                                          //         .signInWithGoogle()
                                          //         .then((value) {
                                          //       if (value == true) {
                                          //         HelperFunctions
                                          //             .setUserLoggedInStatus(
                                          //                 true);
                                          //         Navigator
                                          //             .pushReplacementNamed(
                                          //                 context,
                                          //                 "/messageview");
                                          //       } else {
                                          //         setState(() {
                                          //           viewModel.isLoading = false;
                                          //         });
                                          //         ScaffoldMessenger.of(context)
                                          //             .showSnackBar(SnackBar(
                                          //                 content:
                                          //                     Text(value)));
                                          //       }
                                          //     });
                                          //   },
                                          //   child: SizedBox(
                                          //     height: 30,
                                          //     child: ClipOval(
                                          //       child: Image.asset(
                                          //           'assets/app/google.png'),
                                          //     ),
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 30),
                                          // --------- Facebook Button Round ------------
                                          // InkWell(
                                          //   onTap: () {
                                          //     setState(() {
                                          //       viewModel.isLoading = true;
                                          //     });
                                          //     viewModel
                                          //         .signInWithFacebook()
                                          //         .then((value) {
                                          //       if (value == true) {
                                          //         HelperFunctions
                                          //             .setUserLoggedInStatus(
                                          //                 true);
                                          //         Navigator
                                          //             .pushReplacementNamed(
                                          //                 context,
                                          //                 "/messageview");
                                          //       } else {
                                          //         setState(() {
                                          //           viewModel.isLoading = false;
                                          //         });
                                          //         ScaffoldMessenger.of(context)
                                          //             .showSnackBar(SnackBar(
                                          //                 content:
                                          //                     Text(value)));
                                          //       }
                                          //     });
                                          //   },
                                          //   child: SizedBox(
                                          //     height: 30,
                                          //     child: ClipOval(
                                          //       child: Image.asset(
                                          //           'assets/app/facebook.png'),
                                          //     ),
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 30),
                                          // --------- Apple Button Round ------------
                                          // InkWell(
                                          //   onTap: () {
                                          //     // viewModel
                                          //     //     .signInWithApple()
                                          //     //     .then((v) {
                                          //     //   if (v == true) {
                                          //     //     Navigator.pushNamed(
                                          //     //         context, "/newhomepage");
                                          //     //   }
                                          //   },
                                          //   child: SizedBox(
                                          //     height: 30,
                                          //     child: ClipOval(
                                          //       child: Image.asset(
                                          //           'assets/app/apple.png'),
                                          //     ),
                                          //   ),
                                          // )
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                  isGoogleLoading
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.2),
                        )
                      : viewModel.isLoading
                          ? Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.white.withOpacity(0.2),
                            )
                          : const SizedBox()
                ],
              ));
        });
  }

  showTooltip(BuildContext context, String message) {
    final tooltip = Tooltip(
      message: message,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16.0,
      ),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );

    // Find the Scaffold in the widget tree and use it to show the tooltip
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: tooltip),
    );
  }
}
