import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telemung/pages/dashboard.dart';
import 'package:telemung/pages/pesanan.dart';


class PembayaranScreen extends StatefulWidget {
  final int totalPrice;
  final List<QueryDocumentSnapshot> cartItems;

  PembayaranScreen({required this.totalPrice, required this.cartItems});

  @override
  _PembayaranScreenState createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String? _selectedPaymentMethod;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isButtonEnabled = false;

  Widget _buildPaymentMethodRadio(String method, String asset) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Image.asset(asset, width: 50, height: 50),
          SizedBox(width: 10),
          Text(
            method,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      value: method,
      groupValue: _selectedPaymentMethod,
      onChanged: (String? value) {
        setState(() {
          _selectedPaymentMethod = value;
        });
        _checkButtonEnabled();
      },
    );
  }


  void _navigateToDashboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sukses!"),
          content: Text(
              "Yeay, Kamu berhasil menyelesaikan pembayaran cek pesanan kamu di tab pesanan."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _checkButtonEnabled() {
    setState(() {
      _isButtonEnabled = _selectedPaymentMethod != null &&
          _nameController.text.isNotEmpty;
    });
  }

  Future<void> _saveOrder() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String uid = _auth.currentUser!.uid;

    final orderData = {
      'totalPrice': widget.totalPrice,
      'paymentMethod': _selectedPaymentMethod,
      'address': _addressController.text,
      'name': _nameController.text,
      'status': 'Pending',
      'items': widget.cartItems.map((item) => item.data()).toList(),
      'orderDateTime':
          DateTime.now(), // Tambahkan tanggal dan jam order saat ini
    };

    final DocumentReference orderRef = await FirebaseFirestore.instance
        .collection('pembelian')
        .doc(uid)
        .collection('orders')
        .add(orderData);

    final String orderId = orderRef.id;

    final cartRef = FirebaseFirestore.instance
        .collection('keranjang')
        .doc(uid)
        .collection('items');
    final cartDocs = await cartRef.get();
    for (var doc in cartDocs.docs) {
      await doc.reference.delete();
    }
    _navigateToDashboard(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Text('Pembayaran', style: TextStyle(color: Colors.black)),
                SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ringkasan Pesanan',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Column(
                children: widget.cartItems.map((item) {
                  final name = item['name'];
                  final price = item['price'];
                  final quantity = item['quantity'];
                  final image = item['image'];
                  return Card(
                    child: ListTile(
                      leading: Image.network(image, width: 50, height: 50),
                      title: Text(name),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rp $price'),
                          Text('x$quantity'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Text(
                'Pilih Metode Pembayaran',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  _buildPaymentMethodRadio('DANA', 'assets/dana.png'),
                  _buildPaymentMethodRadio('GOPAY', 'assets/gopay.png'),
                  _buildPaymentMethodRadio('SHOPEEPAY', 'assets/shopeepay.png'),
                  _buildPaymentMethodRadio('CASH', 'assets/cash.png'),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Penerima',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (_) {
                  _checkButtonEnabled();
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Total Harga: Rp ${widget.totalPrice}',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () async {
                        await _saveOrder();
                      }
                    : null,
                child: Text('Bayar', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
