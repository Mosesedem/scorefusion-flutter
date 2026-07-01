import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _SplashAnimation(),
                const SizedBox(height: 20),
                const Text(
                  'score fusion',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Loading your experience…',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF888888),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(AppConstants.orangeValue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashAnimation extends StatelessWidget {
  const _SplashAnimation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/lottie/splash.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}