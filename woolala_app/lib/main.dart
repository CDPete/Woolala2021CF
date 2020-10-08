import 'package:flutter/material.dart';
import 'package:woolala_app/screens/login_screen.dart';

void main() {
  runApp(WooLaLa());
}

class WooLaLa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WooLaLa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        // This makes the visual density adapt to the platform that you run the app on. For desktop platforms, the controls will be smaller and closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
