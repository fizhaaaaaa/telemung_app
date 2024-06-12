import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telemung/pages/dashbordadmin.dart';
import 'package:telemung/pages/login.dart';
import 'package:telemung/pages/dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserStatus(context); // Pastikan ini berjalan di dalam initState
  }

  // Fungsi untuk memeriksa status pengguna dan menavigasi berdasarkan ID
  void checkUserStatus(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Menggunakan penundaan 2 detik sebelum pemeriksaan
    Future.delayed(const Duration(seconds: 2), () {
      if (user != null) {
        if (user.uid == 'siUxAFIN2oMnCJqvbX86HdS94Zq2') {
          // Jika user ID adalah admin, arahkan ke DashboardAdmin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardAdmin()),
          );
        } else {
          // Jika bukan admin, arahkan ke Dashboard biasa
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        }
      } else {
        // Jika pengguna tidak masuk, arahkan ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/telemung.png',
              width: 500, // Ukuran lebar
              height: 500, // Ukuran tinggi
            ),
          ],
        ),
      ),
    );
  }
}
