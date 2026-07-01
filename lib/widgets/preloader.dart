import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class Preloader extends StatefulWidget {
  const Preloader({super.key, required this.onAutoHide});

  final VoidCallback onAutoHide;

  @override
  State<Preloader> createState() => _PreloaderState();
}

class _PreloaderState extends State<Preloader> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 1), widget.onAutoHide);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xF2FFFFFF),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(AppConstants.orangeValue),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading…',
            style: TextStyle(
              fontSize: 15,
              color: Color(AppConstants.orangeValue),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}