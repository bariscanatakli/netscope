import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50), // Add space above the logo
        Image.asset('assets/logo2-removebg.png', height: 100), // Logo
        const SizedBox(height: 50), // Add space below the logo
      ],
    );
  }
}
