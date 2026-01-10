import 'dart:async';
import 'package:flutter/material.dart';

class PawLoading extends StatefulWidget {
  const PawLoading({super.key});

  @override
  State<PawLoading> createState() => _PawLoadingState();
}

class _PawLoadingState extends State<PawLoading> {
  int index = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        index = (index + 1) % 4; // goes through 4 images
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final bool isActive = i == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),

          //Scale animation
          transform: Matrix4.identity()
            ..scale(isActive ? 1.0 : 0.5), // larger when active

          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1 : 0, // fade effect

            child: Image.asset(
              "assets/images/paw.png",
              width: 32,
              height: 32,
              color: Color.fromRGBO(215, 54, 138, 1),
            ),
          ),
        );
      }),
    );
  }
}