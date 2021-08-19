import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                './assets/images/Logo.png',
                height: 200,
                width: 200,
              ),
            ),
            SizedBox(
              width: 250.0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontFamily: 'Blinker',
                ),
                child: AnimatedTextKit(
                  onFinished: () {
                    Navigator.pushReplacementNamed(
                        context, AuthenticationWrapper.id);
                  },
                  displayFullTextOnTap: true,
                  animatedTexts: [
                    TypewriterAnimatedText(
                        'GET YOUR DREAM JOB WITH JUST A CLICK',
                        speed: Duration(milliseconds: 100),
                        textAlign: TextAlign.center),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
