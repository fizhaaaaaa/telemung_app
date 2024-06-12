import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:telemung/pages/dashboard.dart';
import 'package:telemung/pages/create_account.dart'; // Import halaman Create Account
import 'package:telemung/pages/forgotpasswordpage.dart';
import 'package:telemung/pages/loginadmin.dart';
import 'package:telemung/widget/Auth.dart'; // Import AuthService
import 'package:firebase_core/firebase_core.dart'; // Impor firebase_core untuk inisialisasi Firebase
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Inisiasi AuthService
  bool _isPasswordHidden = true;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden =
          !_isPasswordHidden; // Membalikkan visibilitas kata sandi
    });
  }

  Future<bool> _isEmailRegistered(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == "admin@telemung.com" && password == "admin123") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "You are trying to log in as an admin account. Use admin login."),
        ),
      );
      return;
    }

    // Cek apakah email terdaftar di Firestore
    bool isRegistered = await _isEmailRegistered(email);
    if (!isRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Email not registered in the system. Please create an account or contact support."),
        ),
      );
      return;
    }

    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _authService.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "User not registered in the system. Please contact support."),
            ),
          );
          return;
        }

        if (user.emailVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Your email has not been verified. Please check your email for the verification link."),
            ),
          );
          await user.sendEmailVerification();
          await _authService.signOut();
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 32),
                const SizedBox(width: 8),
                Text(
                  "Login Failed",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            content: Text(
              "Double check your email/password.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Try again",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _navigateToCreateAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const CreateAccountPage()), // Navigasi ke halaman Create Account
    );
  }

  void _navigateToAdminLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginAdmin()), // Navigasi ke halaman Create Account
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/telemung.png',
                        height:
                            screenWidth * 0.4, // Sesuaikan dengan ukuran layar
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isPasswordHidden,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize:
                              Size(double.infinity, 48), // Tombol penuh
                          backgroundColor: Color.fromARGB(255, 15, 134, 21),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              "Login",
                              style: TextStyle(color: Colors.black), // Set the text color to black
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToCreateAccount,
                        child: const Text(
                          "Don't have account? Create Account here",
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToAdminLogin,
                        child: const Text(
                          "Admin Login",
                          style: TextStyle(
                            color: Colors.blue,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
