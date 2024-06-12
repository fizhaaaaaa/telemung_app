import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PesananScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  PesananScreen({Key? key}) : super(key: key);

  Future<void> _completeOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('pembelian')
          .doc(user!.uid)
          .collection('orders')
          .doc(orderId)
          .update({'status': 'Selesai'});
      // Tambahkan logika lain yang mungkin Anda perlukan di sini
    } catch (error) {
      print('Error completing order: $error');
      // Handle error jika diperlukan
    }
  }

  void _showOrderDetails(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Menampilkan semua item pesanan dari nama
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: order['items'].length,
                  itemBuilder: (context, index) {
                    var item = order['items'][index];
                    var menuItem = item['name'];
                    var quantity = item['quantity'];

                    return Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${index + 1}. $menuItem',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'x$quantity',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildOrderDetailItem(
                      'Metode Pembayaran:',
                      order['paymentMethod'],
                    ),
                    _buildOrderDetailItem(
                      'Total Harga:',
                      'Rp ${order['totalPrice']}',
                    ),
                    _buildOrderDetailItem(
                      'Alamat:',
                      order['address'],
                    ),
                    _buildOrderDetailItem(
                      'Waktu Pesanan:',
                      order['orderDateTime'].toDate().toString(),
                    ),
                    _buildOrderDetailItem(
                      'Status:',
                      order['status'],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              'Riwayat Pesanan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('pembelian')
                  .doc(user!.uid)
                  .collection('orders')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image.asset('assets/pesanankosong.jpg'),
                        SizedBox(height: 20),
                        Text(
                          'Pesanan kamu masih kosong nih',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    var items = order['items'];
                    var totalPrice = order['totalPrice'];
                    var address = order['address'];
                    var orderDateTime = order['orderDateTime'] as Timestamp;
                    var formattedDateTime = orderDateTime.toDate();
                    var status = order['status'];
                    var paymentMethod = order['paymentMethod'];
                    var name = order['name'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.grey[200],
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showOrderDetails(context, order);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Metode Pembayaran:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                            width:
                                                8), // Memberikan jarak antara teks dan gambar
                                        // Widget untuk menampilkan gambar sesuai dengan metode pembayaran
                                        if (paymentMethod == 'DANA')
                                          Image.asset(
                                            'assets/dana.png',
                                            width:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                            height:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                          )
                                        else if (paymentMethod == 'GOPAY')
                                          Image.asset(
                                            'assets/gopay.png',
                                            width:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                            height:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                          )
                                        else if (paymentMethod == 'COD')
                                          Image.asset(
                                            'assets/cash.png',
                                            width:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                            height:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                          )
                                        else if (paymentMethod == 'SHOPEEPAY')
                                          Image.asset(
                                            'assets/shopeepay.png',
                                            width:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                            height:
                                                50, // Sesuaikan dengan kebutuhan Anda
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Menampilkan sedikit informasi pesanan di card
                              ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        var menuItem = items[index]['name'];
                                        var quantity = items[index]['quantity'];
                                        var image = items[index]['image'];

                                        // Menambahkan nomor urut di depan setiap item
                                        var itemNumber = index + 1;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '$itemNumber. $menuItem',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  '  x$quantity',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.moneyBill,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Total : Rp $totalPrice',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.infoCircle,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Status: $status',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (status == 'On Progress')
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await _completeOrder(order
                                                  .id); // Ganti order.id dengan cara Anda mengakses ID pesanan
                                            },
                                            icon: Icon(Icons.done),
                                            label: Text('Pesanan Selesai'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors
                                                  .red, // Warna latar merah
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
