import 'dart:ui';

import 'package:flutter/material.dart';

PageRouteBuilder downToTop(page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

PageRouteBuilder createRouteBlurredBackground(Widget page) {
  return PageRouteBuilder(
    opaque: false,
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15 * animation.value,
              sigmaY: 15 * animation.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2), // Transparent background
            ),
          ),
          FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
            child: child,
          )
        ],
      );
    },
  );
}
