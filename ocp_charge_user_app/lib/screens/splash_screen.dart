import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover, 
          child: Image.asset(
            "assets/videos/OCP_video.gif",
          ),
        ),
      ),
    );
  }
}
