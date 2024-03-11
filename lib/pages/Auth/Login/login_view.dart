import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:picorix/config/themedata.dart';
import 'package:picorix/pages/Auth/Login/login_view_model.dart';
// import 'package:picorix/utils/helper_functions.dart';
import 'package:picorix/widgets/TextInputFeild.dart';
import 'package:picorix/widgets/pass_Input_field.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return ViewModelBuilder.reactive(
        viewModelBuilder: () => LoginViewModel(),
        builder: (context, viewModel, child) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: viewModel.isLoadingPage
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/bg2.jpg"),
                                fit: BoxFit.fitHeight,
                                opacity: 0.5),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: primaryColor,
                                ))
                              : Form(
                                  key: formKey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 16, 30, 0),
                                          child: Text(
                                            "Log In",
                                            style: GoogleFonts.luckiestGuy()
                                                .copyWith(fontSize: 40),
                                            //       textTheme.headlineLarge!.copyWith(
                                            //     fontSize: 40,
                                            //     fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        // Email Field
                                        const SizedBox(height: 40),
                                        textInputField(
                                            viewModel.emailController,
                                            'Email',
                                            viewModel.validateEmail),

                                        // Password Field
                                        PasswordInputField(
                                            controller:
                                                viewModel.passwordController,
                                            label: "Password",
                                            validator:
                                                viewModel.validatePassword),

                                        Align(
                                          alignment: Alignment.center,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 10),
                                            child: SizedBox(
                                              height: 60,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: MaterialButton(
                                                  onPressed: () {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      setState(() {
                                                        viewModel.isLoading =
                                                            true;
                                                      });
                                                      viewModel
                                                          .login(context)
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
                                                  padding:
                                                      const EdgeInsets.all(16),
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
                                                      : Text("Log In",
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                              padding: const EdgeInsets.all(3),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text.rich(
                                                  TextSpan(
                                                    text:
                                                        " Don't have an account?",
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xff006a00),
                                                        fontSize: 14),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: " Register",
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          recognizer:
                                                              TapGestureRecognizer()
                                                                ..onTap = () {
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/register');
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Text(" OR ",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade400,
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
                                                        isGoogleLoading = false;
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      value)));
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
                                                          BorderRadius.circular(
                                                              15),
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
                                                              height: 30,
                                                              child: Center(
                                                                child: ClipOval(
                                                                  child: Image
                                                                      .asset(
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
                                              ),
                                              // InkWell(
                                              //   onTap: () {
                                              //     setState(() {
                                              //       isProcessing = true;
                                              //     });
                                              //     viewModel
                                              //         .signInWithGoogle()
                                              //         .then((value) {
                                              //       if (value == true) {
                                              //         setState(() {
                                              //           isProcessing = false;
                                              //         });
                                              //         HelperFunctions
                                              //             .setUserLoggedInStatus(
                                              //                 true);
                                              //         Navigator
                                              //             .pushReplacementNamed(
                                              //                 context,
                                              //                 "/messageview");
                                              //       } else {
                                              //         setState(() {
                                              //           isProcessing = false;
                                              //         });
                                              //         ScaffoldMessenger.of(
                                              //                 context)
                                              //             .showSnackBar(
                                              //                 SnackBar(
                                              //                     content: Text(
                                              //                         value)));
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
                                              // InkWell(
                                              //   onTap: () {
                                              //     setState(() {
                                              //       isProcessing = true;
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
                                              //           isProcessing = false;
                                              //         });
                                              //         ScaffoldMessenger.of(
                                              //                 context)
                                              //             .showSnackBar(
                                              //                 SnackBar(
                                              //                     content: Text(
                                              //                         value)));
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
                                              // InkWell(
                                              //   onTap: () {
                                              //     viewModel
                                              //         .signInWithApple()
                                              //         .then((v) {
                                              //       if (v == true) {
                                              //         Navigator.pushNamed(
                                              //             context,
                                              //             "/newhomepage");
                                              //       }
                                              //     });
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
                        isGoogleLoading
                            ? Container(
                                height: double.infinity,
                                width: double.infinity,
                                color: Colors.white.withOpacity(0.2),
                              )
                            : isProcessing
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
}
