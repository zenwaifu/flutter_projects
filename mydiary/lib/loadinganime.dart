import 'dart:async';
import 'package:flutter/material.dart';

class LoadingAnime extends StatefulWidget {
  const LoadingAnime({super.key});

  @override
  State<LoadingAnime> createState() => _LoadingAnimeState();
}

class _LoadingAnimeState extends State<LoadingAnime> {
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
            ..scale(isActive ? 2.0 : 1.5), // larger when active

          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isActive ? 1 : 0, // fade effect

            child: Image.asset(
              "assets/images/walking2.png",
              width: 35,
              height: 35,
            ),
          ),
        );
      }),
    );
  }
}
