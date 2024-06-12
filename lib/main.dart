import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Penting untuk inisialisasi Firebase
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TELEMUNG',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const SplashScreen(), // Mengarah ke SplashScreen
    );
  }
}
