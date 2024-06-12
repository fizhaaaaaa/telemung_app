import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore

  // Metode untuk login menggunakan email dan password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Kembalikan pengguna setelah login berhasil
    } catch (e) {
      rethrow; // Lempar pengecualian untuk penanganan lebih lanjut
    }
  }

  // Metode untuk membuat akun baru dengan email dan password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Kembalikan pengguna setelah akun dibuat
    } catch (e) {
      rethrow; // Lempar pengecualian untuk penanganan lebih lanjut
    }
  }

  // Metode untuk mengirim tautan reset kata sandi ke email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email); // Kirim email reset
    } catch (e) {
      rethrow; // Lempar pengecualian untuk penanganan lebih lanjut
    }
  }

  // Fungsi untuk memeriksa metode login untuk email tertentu
  Future<List<String>> fetchSignInMethodsForEmail(String email) async {
    try {
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods;
    } catch (e) {
      // Jika ada kesalahan, cetak pesan dan kembalikan daftar kosong
      print("Error fetching sign-in methods: $e");
      return [];
    }
  }

  // Metode untuk memperbarui nama pengguna di Firebase Auth dan Firestore
  Future<void> updateUserName(String uid, String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name); // Perbarui nama di Auth
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': _auth.currentUser?.email,
      }); // Simpan ke Firestore
    } catch (e) {
      rethrow; // Lempar pengecualian untuk penanganan lebih lanjut
    }
  }

  // Mengambil pengguna yang sedang login
  User? get currentUser => _auth.currentUser;

  // Metode untuk keluar dari akun
  Future<void> signOut() async {
    await _auth.signOut(); // Logout
  }
}
