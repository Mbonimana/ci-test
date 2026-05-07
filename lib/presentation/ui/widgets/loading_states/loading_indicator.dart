import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animation/loading_animation.json',
        width: 950,
        height: 950,
        repeat: true,
        fit: BoxFit.contain,
      ),
    );
  }
}