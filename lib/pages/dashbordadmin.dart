import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:telemung/pages/admin-addmenu.dart';
import 'package:telemung/pages/admin-cekpesanan.dart';
import 'package:telemung/pages/admin-deletemenu.dart';
import 'package:telemung/pages/admin-readmenu.dart';
import 'package:telemung/pages/admin-updatemenu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telemung/pages/login.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard(
      {required String title,
      required IconData icon,
      required Function() onPressed}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 25, color: Colors.black),
              const SizedBox(height: 5),
              Text(
                title,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMenuCard(
                  title: 'Tambah Menu',
                  icon: Icons.add_circle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddMenuPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Lihat Data Menu',
                  icon: Icons.view_list,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReadMenuPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Edit Menu',
                  icon: Icons.edit,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateMenuPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Hapus Menu',
                  icon: Icons.delete,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DeleteMenuPage()),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Cek Pesanan',
                  icon: Icons.assignment,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminCekPesananPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
