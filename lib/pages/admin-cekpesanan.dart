import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:telemung/pages/login.dart';

class AdminCekPesananPage extends StatefulWidget {
  const AdminCekPesananPage({Key? key}) : super(key: key);

  @override
  _AdminCekPesananPageState createState() => _AdminCekPesananPageState();
}

class _AdminCekPesananPageState extends State<AdminCekPesananPage> {
  late Future<List<DocumentSnapshot>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _getOrders();
  }

  Future<List<DocumentSnapshot>> _getOrders() async {
    final QuerySnapshot orderSnapshot =
        await FirebaseFirestore.instance.collectionGroup('orders').get();

    return orderSnapshot.docs;
  }

  Future<void> _updateOrderStatus(
      String orderId, String parentCollectionPath) async {
    try {
      // Lakukan pembaruan status pesanan di Firestore
      await FirebaseFirestore.instance
          .collection(parentCollectionPath) // Koleksi induk dari dokumen
          .doc(orderId)
          .update({'status': 'On Progress'});

      // Setel ulang FutureBuilder untuk memperbarui tampilan
      setState(() {
        _ordersFuture = _getOrders();
      });
    } catch (error) {
      // Tangani kesalahan jika ada
      print('Error updating order status: $error');
      // Tampilkan pesan kesalahan kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order status'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cek Pesanan', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index].data() as Map<String, dynamic>;
                // Dapatkan jalur induk dari dokumen
                final parentCollectionPath =
                    orders[index].reference.parent.path;
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Order ID: ${orders[index].id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Price: ${order['totalPrice']}'),
                        Text('Payment Method: ${order['paymentMethod']}'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (order['items'] as List<dynamic>).map((item) {
                            return Text('${item['name']}, Qty: ${item['quantity']}');
                          }).toList(),
                        ),
                        Text('Status: ${order['status']}'),
                      ],
                    ),
                    trailing: Visibility(
                      visible: order['status'] == 'Pending',
                      child: ElevatedButton(
                        onPressed: () {
                          _updateOrderStatus(
                              orders[index].id, parentCollectionPath);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black, // Warna teks
                          textStyle: GoogleFonts.poppins(), // Jenis font
                        ),
                        child: Text('Buat Pesanan'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
