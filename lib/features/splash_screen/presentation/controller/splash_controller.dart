import 'package:flutter/material.dart';

class SplashController {
  
  void navigateToHome(BuildContext context, {String? nome}) {
    Navigator.pushReplacementNamed(
      context, 
      '/home',
      arguments: nome,
    );
  }

  void navigateToForm(BuildContext context) {
    Navigator.pushNamed(context, '/form');
  }
}